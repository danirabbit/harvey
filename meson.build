project('io.github.danirabbit.harvey', 'vala', 'c')

gnome = import('gnome')
i18n = import('i18n')

add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name()), language:'c')

asresources = gnome.compile_resources(
    'as-resources', 'data/css.gresource.xml',
    source_dir: 'data',
    c_name: 'as'
)

config_data = configuration_data()
config_data.set_quoted('GETTEXT_PACKAGE', meson.project_name())
config_data.set_quoted('LOCALEDIR', get_option('prefix') / get_option('localedir'))
config_file = configure_file(
    input: 'src/Config.vala.in',
    output: 'Config.vala',
    configuration: config_data
)

executable(
    meson.project_name(),
    config_file,
    'src/Application.vala',
    'src/GradeLabel.vala',
    'src/MainWindow.vala',
    asresources,
    dependencies: [
        dependency('glib-2.0'),
        dependency('gobject-2.0'),
        dependency('gtk4', version: '>= 4.10.0'),
        dependency('granite-7', version: '>= 7.0.0'),
        meson.get_compiler('c').find_library('m', required : false)
    ],
    install: true
)
subdir('data')
subdir('po')

meson.add_install_script('meson/post_install.py')
