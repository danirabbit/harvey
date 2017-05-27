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
        .card {
            color: %s;
            background-color: %s;
            transition: all 600ms ease-in-out;
        }
    """;

    public MainWindow (Gtk.Application application) {
        Object (application: application,
                icon_name: "com.github.danrabbit.harvey",
                title: _("Harvey"),
                height_request: 272,
                width_request: 500);
    }

    construct {
        var fg_entry = new Gtk.Entry ();

        var bg_entry = new Gtk.Entry ();

        var results_label = new Gtk.Label ("Lorem Ipsum");
        results_label.expand = true;
        results_label.valign = Gtk.Align.CENTER;
        results_label.halign = Gtk.Align.CENTER;

        var results_grid = new Gtk.Grid ();
        results_grid.expand = true;
        results_grid.add (results_label);
        results_grid.get_style_context ().add_class ("card");

        var grid = new Gtk.Grid ();
        grid.margin = 12;
        grid.column_spacing = 12;
        grid.row_spacing = 12;
        grid.attach (fg_entry, 0, 0, 1, 1);
        grid.attach (bg_entry, 0, 1, 1, 1);
        grid.attach (results_grid, 1, 0, 1, 2);

        add (grid);
        get_style_context ().add_class ("rounded");
        show_all ();

        fg_entry.changed.connect (() => {
            style_results_pane (fg_entry.text, bg_entry.text);
        });

        bg_entry.changed.connect (() => {
            style_results_pane (fg_entry.text, bg_entry.text);
        });
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
    }
}
