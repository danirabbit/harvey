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

public class GradeLabel : Gtk.Grid {
    private Gtk.Image icon;

    public string level { get; construct; }
    public bool pass {
        set {
            if (value) {
                icon.icon_name = "object-select-symbolic";
            } else {
                icon.icon_name = "window-close-symbolic";
            }
        }
    }

    public GradeLabel (string level) {
        Object (
            height_request: 76,
            width_request: 76,
            level: level,
            margin: 12,
            margin_bottom: 24
        );
    }

    construct {
        var level = new Gtk.Label ("<small><b>%s</b></small>".printf (level));
        level.margin_top = 20;
        level.width_request = 76;
        level.use_markup = true;

        icon = new Gtk.Image ();
        icon.icon_size = Gtk.IconSize.LARGE_TOOLBAR;
        icon.icon_name = "object-select-symbolic";

        orientation = Gtk.Orientation.VERTICAL;
        get_style_context ().add_class ("grade");
        add (level);
        add (icon);
    }
}
