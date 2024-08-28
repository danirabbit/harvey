/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2017-2024 Danielle Foré (https://github.com/danirabbit)
 */

public class MainWindow : Gtk.Window {
    private const string RESULTS_CSS = """
        @define-color colorForeground %s;
        @define-color colorBackground %s;

        .results {
            transition: all 250ms ease-in-out;
        }
    """;

    private Gdk.RGBA gdk_color;
    private Gtk.Entry bg_entry;
    private Gtk.Entry fg_entry;
    private Gtk.Label results_label;
    private GradeLabel a_level;
    private GradeLabel aa_level;
    private GradeLabel aaa_level;

    private string? prev_foreground_entry = null;
    private string? prev_background_entry = null;

    public MainWindow (Gtk.Application application) {
        Object (
            application: application,
            height_request: 500,
            icon_name: "io.github.danirabbit.harvey",
            resizable: false,
            title: _("Harvey"),
            width_request: 700
        );
    }

    construct {
        var fg_label = new Gtk.Label (_("Foreground Color")) {
            xalign = 0
        };
        fg_label.add_css_class ("h4");

        var bg_label = new Gtk.Label (_("Background Color")) {
            margin_top = 12,
            xalign = 0
        };
        bg_label.add_css_class ("h4");

        fg_entry = new Gtk.Entry () {
            placeholder_text = "#333",
            text = Harvey.settings.get_string ("fg-color")
        };
        fg_entry.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, "media-eq-symbolic");

        bg_entry = new Gtk.Entry () {
            placeholder_text = "rgb (110, 200, 230)",
            text = Harvey.settings.get_string ("bg-color")
        };
        bg_entry.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, "media-eq-symbolic");

        var input_grid = new Gtk.Grid () {
            margin_top = 12,
            margin_end = 12,
            margin_bottom = 12,
            margin_start = 12,
            vexpand = true
        };
        input_grid.attach (fg_label, 0, 0);
        input_grid.attach (fg_entry, 0, 1);
        input_grid.attach (bg_label, 0, 2);
        input_grid.attach (bg_entry, 0, 3);

        results_label = new Gtk.Label ("12:1") {
            hexpand = true,
            vexpand = true,
            selectable = true,
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER
        };
        results_label.add_css_class ("h1");

        a_level = new GradeLabel ("WCAG A") {
            halign = Gtk.Align.CENTER
        };
        a_level.tooltip_markup = "<big><b>%s</b></big>\n%s".printf (_("3:1"), _("The minimum level recommended by ISO-9241-3 and ANSI-HFES-100-1988 for standard text and vision"));

        aa_level = new GradeLabel ("WCAG AA") {
            halign = Gtk.Align.CENTER
        };
        aa_level.tooltip_markup = "<big><b>%s</b></big>\n%s".printf (_("4.5:1"), _("Compensates for the loss in contrast that results from moderately low visual acuity, color deficiencies, or aging."));

        aaa_level = new GradeLabel ("WCAG AAA") {
            halign = Gtk.Align.CENTER
        };
        aaa_level.tooltip_markup = "<big><b>%s</b></big>\n%s".printf (_("7:1"), _("Compensates for the loss in contrast sensitivity usually experienced by users with about 20/80 vision. People with more than this degree of vision loss usually use assistive technologies."));

        var results_grid = new Gtk.Grid () {
            row_spacing = 12
        };
        results_grid.add_css_class ("results");
        results_grid.attach (results_label, 0, 0, 3, 1);
        results_grid.attach (a_level, 0, 1);
        results_grid.attach (aa_level, 1, 1);
        results_grid.attach (aaa_level, 2, 1);

        var input_header = new Gtk.HeaderBar () {
           decoration_layout = "close:",
           show_title_buttons = true
        };
        input_header.add_css_class ("input-header");
        input_header.add_css_class ("default-decoration");
        input_header.add_css_class ("flat");

        var grid = new Gtk.Grid ();
        grid.attach (input_header, 0, 0);
        grid.attach (input_grid, 0, 1);
        grid.attach (results_grid, 1, 0, 1, 2);

        var window_handle = new Gtk.WindowHandle () {
            child = grid
        };

        child = window_handle;

        // We need to hide the title area for the split headerbar
        var null_title = new Gtk.Grid () {
            visible = false
        };
        set_titlebar (null_title);

        fg_entry.icon_press.connect ((pos) => {
            if (pos == Gtk.EntryIconPosition.SECONDARY) {
                on_entry_icon_press (fg_entry);
            }
        });

        fg_entry.changed.connect (() => {
            on_entry_changed ();
        });

        bg_entry.icon_press.connect ((pos) => {
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

        var dialog = new Gtk.ColorChooserDialog ("", this) {
            deletable = false,
            rgba = gdk_color,
            show_editor = true
        };
        dialog.present ();


        dialog.color_activated.connect (() => {
            if (entry == fg_entry && prev_foreground_entry == null) {
                prev_foreground_entry = entry.text;
            } else if (entry == bg_entry && prev_background_entry == null) {
                prev_background_entry = entry.text;
            }

           entry.text = dialog.rgba.to_string ();
        });

        // if (dialog.run () == Gtk.ResponseType.OK) {
        //     entry.text = widget.current_rgba.to_string ();
        // } else {
        //     if (prev_foreground_entry != null) {
        //         fg_entry.text = prev_foreground_entry;
        //     }

        //     if (prev_background_entry != null) {
        //         bg_entry.text = prev_background_entry;
        //     }
        // }

        prev_foreground_entry = null;
        prev_background_entry = null;
    }

    private void on_entry_changed () {
        if (fg_entry.text.length > 2 && bg_entry.text.length > 2) {
            style_results_pane (fg_entry.text, bg_entry.text);
        }
    }

    private void style_results_pane (string fg_color, string bg_color) {
            var provider = new Gtk.CssProvider ();
            // try {
            //     var colored_css = RESULTS_CSS.printf (fg_color, bg_color);
            //     provider.load_from_data (colored_css, colored_css.length);

            //     Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
            // } catch (GLib.Error e) {
            //     return;
            // }

            Harvey.settings.set_string ("fg-color", fg_entry.text);
            Harvey.settings.set_string ("bg-color", bg_entry.text);

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
