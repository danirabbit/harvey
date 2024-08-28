/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2017-2024 Danielle Foré (https://github.com/danirabbit)
 */

public class MainWindow : Hdy.Window {
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

    private string? prev_foreground_entry = null;
    private string? prev_background_entry = null;

    public MainWindow (Gtk.Application application) {
        Object (application: application);
    }

    construct {
        settings = new Settings ("io.github.danirabbit.harvey");

        var fg_label = new Granite.HeaderLabel (_("Foreground Color"));

        var bg_label = new Granite.HeaderLabel (_("Background Color"));

        fg_entry = new Gtk.Entry () {
            placeholder_text = "#333",
            secondary_icon_name = "media-eq-symbolic",
            text = settings.get_string ("fg-color")
        };

        bg_entry = new Gtk.Entry () {
            placeholder_text = "rgb (110, 200, 230)",
            secondary_icon_name = "media-eq-symbolic",
            text = settings.get_string ("bg-color"),
        };

        var input_box = new Gtk.Box (VERTICAL, 0) {
            margin_top = 12,
            margin_end = 12,
            margin_bottom = 12,
            margin_start = 12,
            vexpand = true
        };
        input_box.add (fg_label);
        input_box.add (fg_entry);
        input_box.add (bg_label);
        input_box.add (bg_entry);

        results_label = new Gtk.Label ("12:1") {
            hexpand = true,
            vexpand = true,
            selectable = true,
            valign = CENTER,
            halign = CENTER
        };
        results_label.get_style_context ().add_class (Granite.STYLE_CLASS_H1_LABEL);

        a_level = new GradeLabel ("WCAG A") {
            halign = CENTER,
            tooltip_markup = "<big><b>%s</b></big>\n%s".printf (
                _("3:1"),
                _("The minimum level recommended by ISO-9241-3 and ANSI-HFES-100-1988 for standard text and vision")
            )
        };

        aa_level = new GradeLabel ("WCAG AA") {
            halign = CENTER,
            tooltip_markup = "<big><b>%s</b></big>\n%s".printf (
                _("4.5:1"),
                _("Compensates for the loss in contrast that results from moderately low visual acuity, color deficiencies, or aging.")
            )
        };

        aaa_level = new GradeLabel ("WCAG AAA") {
            halign = CENTER,
            tooltip_markup = "<big><b>%s</b></big>\n%s".printf (
                _("7:1"),
                _("Compensates for the loss in contrast sensitivity usually experienced by users with about 20/80 vision. People with more than this degree of vision loss usually use assistive technologies.")
            )
        };

        var results_grid = new Gtk.Grid () {
            row_spacing = 12
        };
        results_grid.get_style_context ().add_class ("results");
        results_grid.attach (results_label, 0, 0, 3, 1);
        results_grid.attach (a_level, 0, 1);
        results_grid.attach (aa_level, 1, 1);
        results_grid.attach (aaa_level, 2, 1);

        var input_header = new Hdy.HeaderBar () {
           decoration_layout = "close:",
           show_close_button = true
        };

        var input_header_context = input_header.get_style_context ();
        input_header_context.add_class ("input-header");
        input_header_context.add_class ("default-decoration");
        input_header_context.add_class (Gtk.STYLE_CLASS_FLAT);

        var grid = new Gtk.Grid ();
        grid.attach (input_header, 0, 0);
        grid.attach (input_box, 0, 1);
        grid.attach (results_grid, 1, 0, 1, 2);

        var window_handle = new Hdy.WindowHandle () {
            child = grid
        };

        child = window_handle;
        default_height = 500;
        default_width = 700;
        icon_name = "io.github.danirabbit.harvey";
        title = _("Harvey");

        show_all ();

        fg_entry.icon_press.connect ((pos, event) => {
            if (pos == Gtk.EntryIconPosition.SECONDARY) {
                on_entry_icon_press (fg_entry);
            }
        });

        fg_entry.changed.connect (() => {
            on_entry_changed ();
        });

        bg_entry.icon_press.connect ((pos, event) => {
            if (pos == Gtk.EntryIconPosition.SECONDARY) {
                on_entry_icon_press (bg_entry);
            }
        });

        bg_entry.changed.connect (() => {
            on_entry_changed ();
        });

        style_results_pane (fg_entry.text, bg_entry.text);
    }

    private void on_entry_icon_press (Gtk.Entry entry) {
        gdk_color.parse (entry.text);

        var dialog = new Gtk.ColorSelectionDialog ("");
        dialog.deletable = false;
        dialog.transient_for = this;

        unowned Gtk.ColorSelection widget = dialog.get_color_selection ();
        widget.current_rgba = gdk_color;

        widget.color_changed.connect (() => {
            if (entry == fg_entry && prev_foreground_entry == null) {
                prev_foreground_entry = entry.text;
            } else if (entry == bg_entry && prev_background_entry == null) {
                prev_background_entry = entry.text;
            }

           entry.text = widget.current_rgba.to_string ();
        });

        if (dialog.run () == Gtk.ResponseType.OK) {
            entry.text = widget.current_rgba.to_string ();
        } else {
            if (prev_foreground_entry != null) {
                fg_entry.text = prev_foreground_entry;
            }

            if (prev_background_entry != null) {
                bg_entry.text = prev_background_entry;
            }
        }

        prev_foreground_entry = null;
        prev_background_entry = null;

        dialog.close ();
    }

    private void on_entry_changed () {
        if (fg_entry.text.length > 2 && bg_entry.text.length > 2) {
            style_results_pane (fg_entry.text, bg_entry.text);
        }
    }

    private void style_results_pane (string fg_color, string bg_color) {
            var provider = new Gtk.CssProvider ();
            try {
                var colored_css = RESULTS_CSS.printf (fg_color, bg_color);
                provider.load_from_data (colored_css, colored_css.length);

                Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
            } catch (GLib.Error e) {
                return;
            }

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
