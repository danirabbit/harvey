project('com.github.danrabbit.harvey', ['vala', 'c'],
    version: '0.1.4'
)

gnome = import('gnome')
i18n = import('i18n')

asresources = gnome.compile_resources(
    'as-resources', 'data/css.gresource.xml',
    source_dir: 'data',
    c_name: 'as'
)

conf = configuration_data()
conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
configure_file(output: 'config.h', configuration: conf)
config_h_dir = include_directories('.')

c_args = [
  '-include', 'config.h'
]

cc = meson.get_compiler('c')
m_dep = cc.find_library('m', required : false)

executable(
    meson.project_name(),
    'src/Application.vala',
    'src/GradeLabel.vala',
    'src/MainWindow.vala',
    asresources,
    c_args: c_args,
    dependencies: [
        dependency('glib-2.0'),
        dependency('gobject-2.0'),
        dependency('gtk+-3.0'),
        m_dep
    ],
    install: true
)
subdir('data')
subdir('po')

meson.add_install_script('meson/post_install.py')
