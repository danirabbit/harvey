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

        .output-header,
        .results {
            transition: all 250ms ease-in-out;
        }
    """;

    private Gdk.RGBA gdk_color;
    private Gtk.Entry bg_entry;
    private Gtk.Entry fg_entry;
    private Gtk.Image results_info;
    private Gtk.Label results_label;
    private Gtk.Label results_primary;

    private string? prev_foreground_entry = null;
    private string? prev_background_entry = null;

    public MainWindow (Gtk.Application application) {
        Object (
            application: application,
            icon_name: "com.github.danrabbit.harvey",
            title: _("Harvey")
        );
    }

    construct {
        var fg_label = new Gtk.Label (_("Foreground Color"));
        fg_label.get_style_context ().add_class ("h4");
        fg_label.xalign = 0;

        var bg_label = new Gtk.Label (_("Background Color"));
        bg_label.get_style_context ().add_class ("h4");
        bg_label.margin_top = 12;
        bg_label.xalign = 0;

        fg_entry = new Gtk.Entry ();
        fg_entry.placeholder_text = "#333";
        fg_entry.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        fg_entry.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, "media-eq-symbolic");

        bg_entry = new Gtk.Entry ();
        bg_entry.placeholder_text = "rgb (110, 200, 230)";
        bg_entry.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        bg_entry.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, "media-eq-symbolic");

        var input_grid = new Gtk.Grid ();
        input_grid.halign = Gtk.Align.START;
        input_grid.orientation = Gtk.Orientation.VERTICAL;
        input_grid.get_style_context ().add_class ("input");
        input_grid.add (fg_label);
        input_grid.add (fg_entry);
        input_grid.add (bg_label);
        input_grid.add (bg_entry);

        results_primary = new Gtk.Label (_("GREAT"));
        results_primary.get_style_context ().add_class ("h1");
        results_primary.hexpand = true;
        results_primary.valign = Gtk.Align.END;
        results_primary.vexpand = true;

        results_label = new Gtk.Label ("12:1");
        results_label.get_style_context ().add_class ("h3");
        results_label.selectable = true;
        results_label.valign = Gtk.Align.START;
        results_label.vexpand = true;

        results_info = new Gtk.Image.from_icon_name ("dialog-information-symbolic", Gtk.IconSize.MENU);
        results_info.halign = Gtk.Align.END;
        results_info.margin = 12;

        var results_spacer = new Gtk.Grid ();

        var results_grid = new Gtk.Grid ();
        results_grid.get_style_context ().add_class ("results");
        results_grid.attach (results_spacer, 0, 0, 1, 3);
        results_grid.attach (results_primary, 1, 0);
        results_grid.attach (results_label, 1, 1);
        results_grid.attach (results_info, 1, 2);

        var overlay = new Gtk.Overlay ();
        overlay.add (results_grid);
        overlay.add_overlay (input_grid);

        var input_header = new Gtk.HeaderBar ();
        input_header.halign = Gtk.Align.START;
        input_header.decoration_layout = "close:";
        input_header.show_close_button = true;

        var input_header_context = input_header.get_style_context ();
        input_header_context.add_class ("input");
        input_header_context.add_class ("titlebar");
        input_header_context.add_class ("default-decoration");
        input_header_context.add_class (Gtk.STYLE_CLASS_FLAT);

        var output_header = new Gtk.HeaderBar ();
        output_header.hexpand = true;

        var output_header_context = output_header.get_style_context ();
        output_header_context.add_class ("output-header");
        output_header_context.add_class ("titlebar");
        output_header_context.add_class ("default-decoration");
        output_header_context.add_class (Gtk.STYLE_CLASS_FLAT);

        var header_overlay = new Gtk.Overlay ();
        header_overlay.add (output_header);
        header_overlay.add_overlay (input_header);

        var sizegroup = new Gtk.SizeGroup (Gtk.SizeGroupMode.HORIZONTAL);
        sizegroup.add_widget (input_grid);
        sizegroup.add_widget (input_header);
        sizegroup.add_widget (results_spacer);

        add (overlay);
        get_style_context ().add_class ("rounded");
        set_default_size (542, 308);
        set_titlebar (header_overlay);

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

        Harvey.settings.bind ("fg-color", fg_entry, "text", GLib.SettingsBindFlags.DEFAULT);
        Harvey.settings.bind ("bg-color", bg_entry, "text", GLib.SettingsBindFlags.DEFAULT);
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


            if (contrast_ratio >= 7) {
                results_primary.label = _("GREAT");
                results_label.label = "%.2f AAA".printf (contrast_ratio);
                results_info.tooltip_markup = "<big><b>%s</b></big>\n%s".printf (_("Greater or Equal to 7:1"), _("Compensates for the loss in contrast sensitivity usually experienced by users with about 20/80 vision. People with more than this degree of vision loss usually use assistive technologies."));
            } else if (contrast_ratio >= 4.5) {
                results_primary.label = _("GOOD");
                results_label.label = "%.2f AA".printf (contrast_ratio);
                results_info.tooltip_markup = "<big><b>%s</b></big>\n%s".printf (_("Greater or Equal to 4.5:1"), _("Compensates for the loss in contrast that results from moderately low visual acuity, color deficiencies, or aging."));
            } else if (contrast_ratio >= 3) {
                results_primary.label = _("PASS");
                results_label.label = "%.2f A".printf (contrast_ratio);
                results_info.tooltip_markup = "<big><b>%s</b></big>\n%s".printf (_("Greater or Equal to 3:1"), _("The minimum level recommended by ISO-9241-3 and ANSI-HFES-100-1988 for standard text and vision"));
            } else {
                results_primary.label = _("FAIL");
                results_label.label = "%.2f".printf (contrast_ratio);
                results_info.tooltip_markup = "<big><b>%s</b></big>\n%s".printf (_("Less Than 3:1"), _("Fails to meet the minimum level recommended by ISO-9241-3 and ANSI-HFES-100-1988 for standard text and vision"));
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

    public override bool configure_event (Gdk.EventConfigure event) {
        int root_x, root_y;
        get_position (out root_x, out root_y);
        Harvey.settings.set_int ("window-x", root_x);
        Harvey.settings.set_int ("window-y", root_y);

        return base.configure_event (event);
    }
}
