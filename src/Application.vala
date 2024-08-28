/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2017-2024 Danielle Foré (https://github.com/danirabbit)
 */

public class Harvey : Gtk.Application {
    public Harvey () {
        Object (application_id: "io.github.danirabbit.harvey",
        flags: ApplicationFlags.FLAGS_NONE);
    }

    protected override void startup () {
        base.startup ();

        Hdy.init ();

        Intl.setlocale (LocaleCategory.ALL, "");
        Intl.bindtextdomain (GETTEXT_PACKAGE, LOCALEDIR);
        Intl.bind_textdomain_codeset (GETTEXT_PACKAGE, "UTF-8");
        Intl.textdomain (GETTEXT_PACKAGE);

        // Follow elementary OS-wide dark preference
        var granite_settings = Granite.Settings.get_default ();
        var gtk_settings = Gtk.Settings.get_default ();

        granite_settings.bind_property ("prefers-color-scheme", gtk_settings, "gtk-application-prefer-dark-theme",
            BindingFlags.DEFAULT | BindingFlags.SYNC_CREATE,
            ((binding, granite_prop, ref gtk_prop) => {
                gtk_prop.set_boolean ((Granite.Settings.ColorScheme) granite_prop == Granite.Settings.ColorScheme.DARK);
                return true;
            })
        );

        var quit_action = new SimpleAction ("quit", null);

        add_action (quit_action);
        set_accels_for_action ("app.quit", {"<Control>q"});

        var provider = new Gtk.CssProvider ();
        provider.load_from_resource ("io/github/danirabbit/harvey/Application.css");
        Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        quit_action.activate.connect (quit);
    }

    protected override void activate () {
        if (active_window == null) {
            add_window (new MainWindow (this));
        }

        active_window.present ();
    }

    public static int main (string[] args) {
        return new Harvey ().run (args);
    }
}
