require 'test/unit'

$:.unshift('./lib', '../lib')
require 'ansisys'

class TestRender < Test::Unit::TestCase
	def test_render
		terminal = AnsiSys::Terminal.new
		terminal.echo("Normal\x1B[31mRed\x1B[0mNormal")
		assert_equal(%Q|<pre class="screen">\nNormal<span style="color: maroon">Red</span>Normal</pre>|, terminal.render)
	end
end
