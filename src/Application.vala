/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2017-2021 Daniel Foré (https://github.com/danrabbit)
 */

public class Harvey : Gtk.Application {
    public static GLib.Settings settings;

    public Harvey () {
        Object (application_id: "com.github.danrabbit.harvey",
        flags: ApplicationFlags.FLAGS_NONE);
    }

    static construct {
        settings = new Settings ("com.github.danrabbit.harvey");
    }

    protected override void activate () {
        if (get_windows ().length () > 0) {
            get_windows ().data.present ();
            return;
        }

        var app_window = new MainWindow (this);
        app_window.present ();

        var quit_action = new SimpleAction ("quit", null);

        add_action (quit_action);
        set_accels_for_action ("app.quit", {"<Control>q"});

        var provider = new Gtk.CssProvider ();
        provider.load_from_resource ("com/github/danrabbit/harvey/Application.css");
        Gtk.StyleContext.add_provider_for_display (Gdk.Display.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        quit_action.activate.connect (() => {
            if (app_window != null) {
                app_window.destroy ();
            }
        });
    }

    public static int main (string[] args) {
        var app = new Harvey ();
        return app.run (args);
    }
}
