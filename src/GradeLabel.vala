/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2017-2024 Danielle Foré (https://github.com/danirabbit)
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
        Object (level: level);
    }

    construct {
        var level = new Gtk.Label ("<small><b>%s</b></small>".printf (level)) {
            margin_top = 20,
            width_request = 76,
            use_markup = true
        };

        icon = new Gtk.Image () {
            icon_name = "object-select-symbolic",
            pixel_size = 24
        };

        height_request = 76;
        width_request = 76;
        margin_top = 12;
        margin_end = 12;
        margin_bottom = 24;
        margin_start = 12;
        add_css_class ("grade");
        attach (level, 0, 0);
        attach (icon, 0, 1);
    }
}
