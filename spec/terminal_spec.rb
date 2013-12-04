$:.unshift('lib')
require 'ansisys'

include AnsiSys

describe Terminal, "when normal ascii characters are echoed" do
  before do
		@terminal = Terminal.new
		@terminal.echo("Hello world")
  end

	it "should render an HTML as the original string" do
		@terminal.render.should == %Q|<pre class="screen">\nHello world</pre>|
	end

	it "should render a plain text as the original string" do
		@terminal.render(:text).should == 'Hello world'
	end
end

describe Terminal, 'when \n is echoed' do
  before do
		@terminal = Terminal.new
		@terminal.echo("Hello\nworld")
  end

	it "should render an HTML with two rows" do
		@terminal.render.should == %Q|<pre class="screen">\nHello\nworld</pre>|
	end

	it "should render a plain text with two rows" do
		@terminal.render(:text).should == %Q|Hello\nworld|
	end
end

describe Terminal, 'when SGR codes are echoed' do
  before do
		@terminal = Terminal.new
		@terminal.echo("Hello \e[32mworld")
  end

	it "should render an HTML with color in span" do
		@terminal.render.should == %Q|<pre class="screen">\nHello <span style="color: green">world</span></pre>|
	end

	it "should render a plain text without colors" do
		@terminal.render(:text).should == 'Hello world'
	end
end

describe Terminal, 'when SGR codes are echoed and non-standard colors are used' do
  before do
		@terminal = Terminal.new
		@terminal.echo("Hello \e[32mworld")
  end

	it "should render an HTML with color in span" do
		@terminal.render(:html, 80, 25, Screen.default_css_colors(false, true)).should == %Q|<pre class="screen">\nHello <span style="color: lime">world</span></pre>|
	end
end

describe Terminal do
	before do
		@terminal = Terminal.new
	end

	it "should give CSS style-let" do
		c = @terminal.css_style.split(/\n/)
		e = <<"_CSS".split(/\n/)
pre.screen {
\tcolor: silver;
\tbackground-color: black;
\twidth: 40.0em;
\tpadding: 0.5em;
}
_CSS
		c.size.should == e.size
		c.each do |line|
			e.should include(line)
		end
	end
end

describe Terminal, 'when code ED is sent' do
  before do
		@terminal = Terminal.new
		@terminal.echo("Hello\nand\ngood bye\nworld\e[2;2H")
  end

	it 'should clear from cursor to end of screen with a code J' do
		@terminal.echo("\e[J")
		@terminal.render(:text).should == "Hello\na"
	end

	it 'should clear from cursor to end of screen with a code 0J' do
		@terminal.echo("\e[0J")
		@terminal.render(:text).should == "Hello\na"
	end

	it 'should clear from cursor to beggining of screen with a code 1J' do
		@terminal.echo("\e[1J")
		@terminal.render(:text).should == "\n  d\ngood bye\nworld"
	end

	it 'should clear entier screen with a code 2J' do
		@terminal.echo("\e[2J")
		@terminal.render(:text).should == ""
	end

	it 'should move cursor to top left with a code 2J' do
		@terminal.echo("\e[2JX")
		@terminal.render(:text).should == "X"
	end
end

describe Terminal, 'when code EL is sent' do
  before do
		@terminal = Terminal.new
		@terminal.echo("red\ngreen\nrefactor\e[2;2H")
  end

	it 'should clear from cursor to end of line with a code K' do
		@terminal.echo("\e[K")
		@terminal.render(:text).should == "red\ng\nrefactor"
	end

	it 'should clear from cursor to end of line with a code K' do
		@terminal.echo("\e[0K")
		@terminal.render(:text).should == "red\ng\nrefactor"
	end

	it 'should clear from cursor to beginning of line with a code K' do
		@terminal.echo("\e[1K")
		@terminal.render(:text).should == "red\n  een\nrefactor"
	end

	it 'should clear entier line with a code 2K' do
		@terminal.echo("\e[2K")
		@terminal.render(:text).should == "red\n\nrefactor"
	end

	it 'should not move cursor with a code 2K' do
		@terminal.echo("\e[2KX")
		@terminal.render(:text).should == "red\n X\nrefactor"
	end
end

describe Terminal, 'when code SU is sent' do
	before do
		@terminal = Terminal.new
		@terminal.echo("red\ngreen\n\nrefactor\e[2;2H")
  end

	it 'shuold scroll down by one line with a code S' do
		@terminal.echo("\e[S")
		@terminal.render(:text).should == "green\n\nrefactor"
	end

	it 'shuold scroll down by one line with a code 1S' do
		@terminal.echo("\e[1S")
		@terminal.render(:text).should == "green\n\nrefactor"
	end

	it 'shuold scroll down by two lines with a code 2S' do
		@terminal.echo("\e[2S")
		@terminal.render(:text).should == "\nrefactor"
	end

	it 'shuold append a line at the bottom after S' do
		@terminal.echo("\e[2SX")
		@terminal.render(:text).should == "\nrefactor\nX"
	end
end

describe Terminal, 'when code SD is sent' do
	before do
		@terminal = Terminal.new
		@terminal.echo("red\ngreen\n\nrefactor\e[2;2H")
  end

	it 'shuold scroll up by one line with a code T' do
		@terminal.echo("\e[T")
		@terminal.render(:text).should == "\nred\ngreen\n\nrefactor"
	end

	it 'shuold scroll up by one line with a code 1T' do
		@terminal.echo("\e[1T")
		@terminal.render(:text).should == "\nred\ngreen\n\nrefactor"
	end

	it 'shuold scroll up by two lines with a code 2T' do
		@terminal.echo("\e[2T")
		@terminal.render(:text).should == "\n\nred\ngreen\n\nrefactor"
	end

	it 'shuold append a line at the top after T' do
		@terminal.echo("\e[2TX")
		@terminal.render(:text).should == "X\n\nred\ngreen\n\nrefactor"
	end
end

describe Terminal, 'when code SCP or RCP is sent' do
	before do
		@terminal = Terminal.new
		@terminal.echo("red\ngreen\nrefactor\e[2;2H")
  end

	it 'should save and restore the cursor position' do
		@terminal.echo("\e[sXX\nY\e[uZ")
		@terminal.render(:text).should == "red\ngZXen\nYefactor"
		@terminal.echo("\e[uz")
		@terminal.render(:text).should == "red\ngzXen\nYefactor"
	end
end

describe Terminal, 'when only code RCP is sent' do
	before do
		@terminal = Terminal.new
		@terminal.echo("red\ngreen\nrefactor\n\e[2;2H")
  end

	it 'should ignore the code' do
		@terminal.echo("\e[udone")
		@terminal.render(:text).should == "red\ngdone\nrefactor"
	end
end
