$:.unshift('lib')
require 'ansisys'

unless defined?(:SGR)
	class SGR
	end
end

include AnsiSys
describe "Characters echoed on a Screen" do
	before do
		@string = "Test string <HELLO>"
		@char = Characters.new(@string, SGR.new)
		@screen = Screen.new
		@cursor = Cursor.new
	end

	it "should usually be distributed as an identical string onto screen" do
		@char.echo_on(@screen, @cursor)
		@screen.render(:text).should == <<_SCREEN.chomp
Test string <HELLO>
_SCREEN
	end

	it "should be HTML escaped when rendered as an HTML fragment" do
		@char.echo_on(@screen, @cursor)
		@screen.render(:html).should == <<_SCREEN.chomp
<pre class="screen">\nTest string &lt;HELLO&gt;</pre>
_SCREEN
	end
end

describe "Wide-characters echoed on right edge of a Screen" do
	before do
		$KCODE = 'u'
		@string = "\346\227\245\346\234\254\350\252\236"	# `Nihongo' in UTF-8
		@char = Characters.new(@string, SGR.new)
		@screen = Screen.new(Screen.default_css_colors, 3)
		@cursor = Cursor.new(1, 1, 3)
		@char.echo_on(@screen, @cursor)
	end

	it "should fit in the width" do
		@screen.render(:text).should == <<_SCREEN.chomp
\346\227\245
\346\234\254
\350\252\236
_SCREEN
	end
end
