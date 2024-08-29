/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2017-2024 Danielle Foré (https://github.com/danirabbit)
 */

public class MainWindow : Gtk.Window {
    private const string RESULTS_CSS = """
        @define-color colorForeground %s;
        @define-color colorBackground %s;
    """;

    private Gdk.RGBA gdk_color;
    private Gtk.Entry bg_entry;
    private Gtk.Entry fg_entry;
    private Gtk.Label results_label;
    private GradeLabel a_level;
    private GradeLabel aa_level;
    private GradeLabel aaa_level;

    private GLib.Settings settings;

    public MainWindow (Gtk.Application application) {
        Object (application: application);
    }

    construct {
        settings = new Settings ("io.github.danirabbit.harvey");

        var fg_label = new Granite.HeaderLabel (_("Foreground Color"));

        var bg_label = new Granite.HeaderLabel (_("Background Color"));

        fg_entry = new Gtk.Entry () {
            hexpand = true,
            placeholder_text = "#333",
            secondary_icon_name = "media-eq-symbolic",
            text = settings.get_string ("fg-color")
        };

        bg_entry = new Gtk.Entry () {
            hexpand = true,
            placeholder_text = "rgb (110, 200, 230)",
            secondary_icon_name = "media-eq-symbolic",
            text = settings.get_string ("bg-color"),
        };

        var fg_box = new Gtk.Box (VERTICAL, 0);
        fg_box.append (fg_label);
        fg_box.append (fg_entry);

        var bg_box = new Gtk.Box (VERTICAL, 0);
        bg_box.append (bg_label);
        bg_box.append (bg_entry);

        var inputs_box = new Gtk.Box (HORIZONTAL, 0);
        inputs_box.add_css_class ("inputs");
        inputs_box.append (fg_box);
        inputs_box.append (bg_box);

        results_label = new Gtk.Label ("12:1") {
            hexpand = true,
            vexpand = true,
            selectable = true,
            valign = CENTER,
            halign = CENTER
        };
        results_label.add_css_class (Granite.STYLE_CLASS_H1_LABEL);

        a_level = new GradeLabel ("WCAG A") {
            tooltip_markup = "<big><b>%s</b></big>\n%s".printf (
                _("3:1"),
                _("The minimum level recommended by ISO-9241-3 and ANSI-HFES-100-1988 for standard text and vision")
            )
        };

        aa_level = new GradeLabel ("WCAG AA") {
            tooltip_markup = "<big><b>%s</b></big>\n%s".printf (
                _("4.5:1"),
                _("Compensates for the loss in contrast that results from moderately low visual acuity, color deficiencies, or aging.")
            )
        };

        aaa_level = new GradeLabel ("WCAG AAA") {
            tooltip_markup = "<big><b>%s</b></big>\n%s".printf (
                _("7:1"),
                _("Compensates for the loss in contrast sensitivity usually experienced by users with about 20/80 vision. People with more than this degree of vision loss usually use assistive technologies.")
            )
        };

        var levels_box = new Gtk.Box (HORIZONTAL, 0) {
            halign = CENTER
        };
        levels_box.append (a_level);
        levels_box.append (aa_level);
        levels_box.append (aaa_level);

        var results_box = new Gtk.Box (VERTICAL, 0);
        results_box.add_css_class ("results");
        results_box.append (results_label);
        results_box.append (levels_box);

        var main_box = new Gtk.Box (VERTICAL, 0);
        main_box.append (inputs_box);
        main_box.append (results_box);

        var window_handle = new Gtk.WindowHandle () {
            child = main_box
        };

        titlebar = new Gtk.HeaderBar () {
            show_title_buttons = true,
            title_widget = new Gtk.Grid () { visible = false }
        };
        titlebar.add_css_class (Granite.STYLE_CLASS_FLAT);

        child = window_handle;
        default_height = 300;
        default_width = 400;
        icon_name = "io.github.danirabbit.harvey";
        title = _("Harvey");

        fg_entry.icon_press.connect ((pos) => {
            if (pos == Gtk.EntryIconPosition.SECONDARY) {
                on_entry_icon_press.begin (fg_entry);
            }
        });

        fg_entry.changed.connect (() => {
            on_entry_changed ();
        });

        bg_entry.icon_press.connect ((pos) => {
            if (pos == Gtk.EntryIconPosition.SECONDARY) {
                on_entry_icon_press.begin (bg_entry);
            }
        });

        bg_entry.changed.connect (() => {
            on_entry_changed ();
        });

        style_results_pane (fg_entry.text, bg_entry.text);
    }

    private async void on_entry_icon_press (Gtk.Entry entry) {
        gdk_color.parse (entry.text);

        var dialog = new Gtk.ColorDialog () {
            modal = true,
            with_alpha = false
        };

        try {
            var rgba = yield dialog.choose_rgba (this, gdk_color, null);
            entry.text = rgba.to_string ();
        } catch (Error e) {
            critical ("failed to get color");
        }
    }

    private void on_entry_changed () {
        if (fg_entry.text.length > 2 && bg_entry.text.length > 2) {
            style_results_pane (fg_entry.text, bg_entry.text);
        }
    }

    private void style_results_pane (string fg_color, string bg_color) {
            var colored_css = RESULTS_CSS.printf (fg_color, bg_color);

            var provider = new Gtk.CssProvider ();
            provider.load_from_string (colored_css);

            Gtk.StyleContext.add_provider_for_display (Gdk.Display.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

            settings.set_string ("fg-color", fg_entry.text);
            settings.set_string ("bg-color", bg_entry.text);

            gdk_color.parse (fg_color);
            var pango_fg_luminance = get_luminance (gdk_color);

            gdk_color.parse (bg_color);
            var pango_bg_luminance = get_luminance (gdk_color);

            double contrast_ratio;

            if (pango_bg_luminance > pango_fg_luminance) {
                contrast_ratio = (pango_bg_luminance + 0.05) / (pango_fg_luminance + 0.05);
            } else {
                contrast_ratio = (pango_fg_luminance + 0.05) / (pango_bg_luminance + 0.05);
            }

            results_label.label = "%.1f:1".printf (contrast_ratio);

            if (contrast_ratio >= 3) {
                a_level.pass = true;
            } else {
                a_level.pass = false;
            }

            if (contrast_ratio >= 4.5) {
                aa_level.pass = true;
            } else {
                aa_level.pass = false;
            }

            if (contrast_ratio >= 7) {
                aaa_level.pass = true;
            } else {
                aaa_level.pass = false;
            }

    }

    private double get_luminance (Gdk.RGBA color) {
        var red = sanitize_color (color.red) * 0.2126;
        var green = sanitize_color (color.green) * 0.7152;
        var blue = sanitize_color (color.blue) * 0.0722;

        return (red + green + blue);
    }

    private double sanitize_color (double color) {
        if (color <= 0.03928) {
            color = color / 12.92;
        } else {
            color = Math.pow ((color + 0.055) / 1.055, 2.4);
        }
        return color;
    }
}
