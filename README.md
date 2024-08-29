<img align="left" width="64" height="64" src="data/icons/64/io.github.danirabbit.harvey.svg">
<h1 class="rich-diff-level-zero">Harvey</h1>

The hero that Gotham needs. Harvey is a color contrast checker. It checks a given set of colors for WCAG contrast compliance.

![Harvey Screenshot](data/screenshot.png?raw=true)

[![Get it on AppCenter](https://appcenter.elementary.io/badge.svg)](https://appcenter.elementary.io/io.github.danirabbit.harvey)

## Building, Testing, and Installation

Run `flatpak-builder` to configure the build environment, download dependencies, build, and install

```bash
    flatpak-builder build io.github.danirabbit.harvey.yml --user --install --force-clean --install-deps-from=appcenter
```

Then execute with

```bash
    flatpak run io.github.danirabbit.harvey
```
