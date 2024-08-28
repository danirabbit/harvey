/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2017-2024 Danielle Foré (https://github.com/danirabbit)
 */

public class GradeLabel : Gtk.Box {
    private Gtk.Image image;

    public string level { get; construct; }
    public bool pass {
        set {
            if (value) {
                image.icon_name = "object-select-symbolic";
            } else {
                image.icon_name = "window-close-symbolic";
            }
        }
    }

    public GradeLabel (string level) {
        Object (level: level);
    }

    class construct {
        set_css_name ("grade");
    }

    construct {
        var level = new Gtk.Label (level) {
            use_markup = true
        };
        level.get_style_context ().add_class (Granite.STYLE_CLASS_SMALL_LABEL);

        image = new Gtk.Image.from_icon_name ("object-select-symbolic", LARGE_TOOLBAR);

        orientation = VERTICAL;
        add (level);
        add (image);
    }
}
