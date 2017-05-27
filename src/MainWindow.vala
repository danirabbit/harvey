/*
* Copyright (c) 2017 Daniel Foré (http://danielfore.com)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*/

public class MainWindow : Gtk.Window {
    private const string RESULTS_CSS = """
        @define-color colorForeground %s;
        @define-color colorBackground %s;

        .results {
            transition: all 600ms ease-in-out;
        }
    """;

    private Gdk.RGBA gdk_color;
    private Gtk.Label results_label;

    public MainWindow (Gtk.Application application) {
        Object (application: application,
                icon_name: "com.github.danrabbit.harvey",
                title: _("Harvey"),
                height_request: 500,
                width_request: 700);
    }

    construct {
        var fg_entry = new Gtk.Entry ();
        fg_entry.placeholder_text = _("Foreground Color");
        fg_entry.text = "red";

        var bg_entry = new Gtk.Entry ();
        bg_entry.placeholder_text = _("Background Color");
        bg_entry.text = "#fff";

        results_label = new Gtk.Label ("Lorem Ipsum");
        results_label.expand = true;
        results_label.get_style_context ().add_class ("h1");
        results_label.valign = Gtk.Align.CENTER;
        results_label.halign = Gtk.Align.CENTER;

        var input_grid = new Gtk.Grid ();
        input_grid.margin = 12;
        input_grid.row_spacing = 12;
        input_grid.attach (fg_entry, 0, 0, 1, 1);
        input_grid.attach (bg_entry, 0, 1, 1, 1);

        var results_grid = new Gtk.Grid ();
        results_grid.expand = true;
        results_grid.get_style_context ().add_class ("results");
        results_grid.add (results_label);

        var grid = new Gtk.Grid ();
        grid.add (input_grid);
        grid.add (results_grid);

        add (grid);
        get_style_context ().add_class ("rounded");
        show_all ();

        fg_entry.changed.connect (() => {
            style_results_pane (fg_entry.text, bg_entry.text);
        });

        bg_entry.changed.connect (() => {
            style_results_pane (fg_entry.text, bg_entry.text);
        });

        style_results_pane (fg_entry.text, bg_entry.text);
    }

    private void style_results_pane (string fg_color, string bg_color) {
            var provider = new Gtk.CssProvider ();
            try {
                var colored_css = RESULTS_CSS.printf (fg_color, bg_color);
                provider.load_from_data (colored_css, colored_css.length);

                Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
            } catch (GLib.Error e) {
                critical (e.message);
            }

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

            results_label.label = "%f".printf (contrast_ratio);          
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
