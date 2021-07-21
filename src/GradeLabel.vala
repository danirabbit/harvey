/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2017-2021 Daniel Foré (https://github.com/danrabbit)
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
