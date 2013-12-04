= Ruby-ANSI.SYS readme
Ruby-ANSI.SYS is a Ruby library to render texts with ANSI escape
sequences. It can also be used as a plugin for Hiki.

== Installation
As a Ruby library:

  $ ruby setup.rb config
  $ ruby setup.rb setup
  # ruby setup.rb install

As a Hiki plugin, copy the file lib/ansisys.rb into the
misc/plugin directory and configure Hiki to enable the plugin.

== Usage
As a Ruby library:

  require 'ansisys'
  terminal = AnsiSys::Terminal.new
  terminal.echo("Hello \e[32mWorld\e[m")
  terminal.render #=> HTML fragment

to show with the default ANSI colors or

  terminal.render(:html, 80, nil, AnsiSys::Screen.default_css_colors(false, true))

to show with brigher colors.

As a Hiki plugin:
  {{ansi_screen(attach_file_name)}}

== Specs
You can run through spec files:
  $ ruby setup.rb spec -fs -c

== Copyright
Read the License.txt file.
