require 'nkf'

describe "As a Hiki plugin" do
	before do
		include 'webrick'
		class String
			def escape
				WEBrick::HTTPUtils.escape(self)
			end

			def to_euc
				NKF::nkf('-m0 -e', self)
			end
		end

		module Hiki
			class Conf
				def cache_path
					'./spec'
				end
			end

			class PluginError < StandardError; end

			class Plugin
				def initialize
					@page = '.'
					@conf = Conf.new
				end

				def load_plugin
					lib = 'lib/ansisys.rb'
					instance_eval(File.read(lib), lib, 1)
				end
			end
		end

		@plugin = Hiki::Plugin.new
		@plugin.load_plugin
	end

	it "should render an HTML fragment as expected" do
		@plugin.ansi_screen('test_data.txt').should == File.read('spec/attach/test_data.html')
	end

	it "should convert charset to EUC-JP" do
		@plugin.ansi_screen('test_utf8.txt').should include("\306\374\313\334\270\354")	# `nihongo' in EUC-JP
		@plugin.ansi_screen('test_sjis.txt').should include("\306\374\313\334\270\354")
		@plugin.ansi_screen('test_euc.txt').should include("\306\374\313\334\270\354")
	end
end
