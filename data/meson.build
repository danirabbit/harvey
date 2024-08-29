icon_sizes = ['48', '64', '128']

foreach i : icon_sizes
    install_data(
        join_paths('icons', i, meson.project_name() + '.svg'),
        install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', i + 'x' + i, 'apps')
    )
    install_data(
        join_paths('icons', i, meson.project_name() + '.svg'),
        install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', i + 'x' + i + '@2', 'apps')
    )
endforeach

install_data(
    'harvey.gschema.xml',
    rename: meson.project_name() + '.gschema.xml',
    install_dir: get_option('datadir') / 'glib-2.0' / 'schemas'
)

i18n.merge_file(
    input: 'harvey.desktop.in',
    output: meson.project_name() + '.desktop',
    po_dir: meson.source_root() / 'po' / 'extra',
    type: 'desktop',
    install: true,
    install_dir: get_option('datadir') / 'applications'
)

i18n.merge_file(
    input: 'harvey.metainfo.xml.in',
    output: meson.project_name() + '.metainfo.xml',
    po_dir: meson.source_root() / 'po' / 'extra',
    install: true,
    install_dir: get_option('datadir') / 'metainfo'
)

