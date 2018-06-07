<img align="left" width="64" height="64" src="data/icons/64/com.github.danrabbit.harvey.svg">
<h1 class="rich-diff-level-zero">Harvey</h1>

The hero that Gotham needs. Harvey is a color contrast checker. It checks a given set of colors for WCAG contrast compliance.

![Harvey Screenshot](data/screenshot.png?raw=true)

[![Get it on AppCenter](https://appcenter.elementary.io/badge.svg)](https://appcenter.elementary.io/com.github.danrabbit.harvey)

## Building, Testing, and Installation


You'll need the following dependencies to build:
* libgtk-3-dev
* meson
* valac

Run `meson build` to configure the build environment and then change to the build directory and run `ninja test` to build and run automated tests

    meson build --prefix=/usr 
    cd build
    ninja test

To install, use `ninja install`, then execute with `com.github.danrabbit.harvey`

    sudo ninja install
    com.github.danrabbit.harvey
