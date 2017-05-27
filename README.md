# Harvey

The hero that Gotham needs

## Building, Testing, and Installation


You'll need the following dependencies to build:
* libgtk-3-dev
* meson
* valac

Run `meson build` to configure the build environment and then change to the build directory and run `ninja` to build

    meson build
    cd build
    mesonconf -Dprefix=/usr
    ninja

To install, use `ninja install`, then execute with `com.github.danrabbit.harvey`

    sudo ninja install
    com.github.danrabbit.harvey