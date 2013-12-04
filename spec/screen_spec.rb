$:.unshift('lib')
require 'ansisys'
unless defined?(:SGR)
	class SGR
	end
end

include AnsiSys
describe Screen, "when rendered as a plain text" do
	before do
		@screen = Screen.new
		@sgr = SGR.new
	end

	it "should store character at the given location" do
		@screen.write('t', 1, 3, 5, @sgr)
		@screen.instance_variable_get(:@lines)[5][3].should == ['t', 1, SGR.new]
	end
	
	it "should overwrite character at the same location" do
		@screen.write('t', 1, 3, 5, @sgr)
		@screen.write('u', 1, 3, 5, @sgr)
		@screen.instance_variable_get(:@lines)[5][3].should == ['u', 1, SGR.new]
	end
end

describe Screen, "when rendered" do
	before do
		@screen = Screen.new
		@sgr = SGR.new
	end

	it "should render Ascii characters" do
		@screen.write('h', 1, 3, 2, @sgr)
		@screen.write('e', 1, 4, 2, @sgr)
		@screen.write('l', 1, 5, 2, @sgr)
		@screen.write('l', 1, 6, 2, @sgr)
		@screen.write('o', 1, 7, 2, @sgr)
		@screen.render(:text).should == <<_SCREEN.chomp

  hello
_SCREEN
	end

	it "should render wide characters" do
		@screen.write('h-', 2, 3, 2, @sgr)
		@screen.write('e-', 2, 5, 2, @sgr)
		@screen.write('l-', 2, 7, 2, @sgr)
		@screen.write('l-', 2, 9, 2, @sgr)
		@screen.write('o-', 2, 11, 2, @sgr)
		@screen.render(:text).should == <<_SCREEN.chomp

  h-e-l-l-o-
_SCREEN
	end
end

describe Screen, "when rendered as an HTML fragment" do
	before do
		@screen = Screen.new
		@sgr = SGR.new
		@screen.write('h', 1, 3, 1, @sgr)
		@screen.write('e', 1, 4, 1, @sgr)
		@screen.write('l', 1, 5, 1, @sgr)
		@screen.write('l', 1, 6, 1, @sgr)
		@screen.write('o', 1, 7, 1, @sgr)
	end

	it "should be surrounded with <pre>" do
		@screen.render(:html).should == <<_SCREEN.chomp
<pre class="screen">\n  hello</pre>
_SCREEN
	end

	it "should change colors" do
		@sgr.apply_code!('m', 32)
		@screen.write(':', 1, 1, 1, @sgr)
		@screen.write(')', 1, 2, 1, @sgr)
		@screen.render(:html).should == <<_SCREEN.chomp
<pre class="screen">\n<span style="color: green">:)</span>hello</pre>
_SCREEN
	end
end

describe "screen with default colors set", :shared => true do
	it "should only specify colors of special color letters when rendered as HTML" do
		@screen.render(:html).should == <<_SCREEN.chomp
<pre class="screen">\n<span style="color: green">:)</span>hello</pre>
_SCREEN
	end
end

describe Screen, "with default colors" do
	before do
		@screen = Screen.new
		@sgr = SGR.new
		@screen.write('h', 1, 3, 1, @sgr)
		@screen.write('e', 1, 4, 1, @sgr)
		@screen.write('l', 1, 5, 1, @sgr)
		@screen.write('l', 1, 6, 1, @sgr)
		@screen.write('o', 1, 7, 1, @sgr)
		@sgr.apply_code!('m', 32)
		@screen.write(':', 1, 1, 1, @sgr)
		@screen.write(')', 1, 2, 1, @sgr)
	end

	it_should_behave_like "screen with default colors set"

	it "should have default css style with silver letters on black background" do
		css = @screen.css_style
		css.should include('color: silver;')
		css.should include('background-color: black;')
	end
end

describe Screen, "with inverted colors" do
	before do
		@screen = Screen.new(Screen.default_css_colors(true))
		@sgr = SGR.new
		@screen.write('h', 1, 3, 1, @sgr)
		@screen.write('e', 1, 4, 1, @sgr)
		@screen.write('l', 1, 5, 1, @sgr)
		@screen.write('l', 1, 6, 1, @sgr)
		@screen.write('o', 1, 7, 1, @sgr)
		@sgr.apply_code!('m', 32)
		@screen.write(':', 1, 1, 1, @sgr)
		@screen.write(')', 1, 2, 1, @sgr)
	end

	it_should_behave_like "screen with default colors set"

	it "should have default css style with black letters on white background" do
		css = @screen.css_style
		css.should include('color: black;')
		css.should include('background-color: silver;')
	end
end

describe Screen, "with bright colors" do
	before do
		@screen = Screen.new(Screen.default_css_colors(false, true))
		@sgr = SGR.new
		@screen.write('h', 1, 3, 1, @sgr)
		@screen.write('e', 1, 4, 1, @sgr)
		@screen.write('l', 1, 5, 1, @sgr)
		@screen.write('l', 1, 6, 1, @sgr)
		@screen.write('o', 1, 7, 1, @sgr)
		@sgr.apply_code!('m', 32)
		@screen.write(':', 1, 1, 1, @sgr)
		@screen.write(')', 1, 2, 1, @sgr)
	end

	it "should have colors as specified" do
		@screen.render(:html).should == <<_SCREEN.chomp
<pre class="screen">\n<span style="color: lime">:)</span>hello</pre>
_SCREEN
	end

	it "should have default css style with black letters on white background" do
		css = @screen.css_style
		css.should include('color: white;')
		css.should include('background-color: black;')
	end
end
