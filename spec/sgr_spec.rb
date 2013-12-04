$:.unshift('lib')
require 'ansisys'

include AnsiSys
describe SGR, 'when initialized' do
  before do
    @sgr = SGR.new
  end

  it "should have normal intensity" do @sgr.intensity.should == :normal; end
  it "should have italic off" do @sgr.italic.should == :off; end
  it "should have no underline" do @sgr.underline.should == :none; end
  it "should have blink off" do @sgr.blink.should == :off; end
  it "should have positive image" do @sgr.image.should == :positive; end
  it "should have conceal off" do @sgr.conceal.should == :off; end
  it "should have white foreground color" do @sgr.foreground.should == :white; end
  it "should have black background color" do @sgr.background.should == :black; end
end

describe SGR, 'when two are initialized' do
  before do
    @sgr1 = SGR.new
    @sgr2 = SGR.new
  end

  it 'should be equal when initialized' do @sgr1.should == @sgr2; end
  it 'should be different after a code is executed' do
    @sgr2.apply_code!('m', 1)
    @sgr1.should_not == @sgr2
  end
end

describe SGR, 'when a code is executed' do
  before do
    @sgr = SGR.new
  end

  class Object
    def change_only(accessor, expected, &block)
      yield(self)
      self.send(accessor).should == expected
      other = self.class.new
      other.instance_variable_set("@#{accessor}", expected)
      other.should == self
    end
  end

	it 'should treat empty parameter as a code 0' do
		@sgr.apply_code!('m')
		@sgr.should == SGR.new
	end
  it 'should have bold intensity with a code 1' do
    @sgr.change_only(:intensity, :bold){|x| x.apply_code!('m', 1)}
  end
  it 'should have faint intensity with a code 2' do
    @sgr.change_only(:intensity, :faint){|x| x.apply_code!('m', 2)}
  end
  it 'should be italic with a code 3' do
    @sgr.change_only(:italic, :on){|x| x.apply_code!('m', 3)}
  end
  it 'should have single underline with a code 4' do
    @sgr.change_only(:underline, :single){|x| x.apply_code!('m', 4)}
  end
  it 'should be concealed with a code 8' do
    @sgr.change_only(:conceal, :on){|x| x.apply_code!('m', 8)}
  end
  it 'should be revealed with a code 28' do
    @sgr.change_only(:conceal, :off) do |x|
			x.apply_code!('m', 8)
			x.apply_code!('m', 28)
		end
  end
  it 'should have green foreground with normal intensity with a code 32' do
    @sgr.apply_code!('m', 1)
    @sgr.apply_code!('m', 32)
    @sgr.foreground.should == :green
    @sgr.intensity.should == :normal
  end
  it 'should have white foreground with normal intensity with a code 39' do
    @sgr.apply_code!('m', 32)
    @sgr.apply_code!('m', 1)
    @sgr.apply_code!('m', 39)
    @sgr.foreground.should == :white
    @sgr.intensity.should == :normal
  end
  it 'should have yellow background with normal intensity with a code 43' do
    @sgr.apply_code!('m', 1)
    @sgr.apply_code!('m', 43)
    @sgr.background.should == :yellow
    @sgr.intensity.should == :normal
  end
  it 'should have blue foreground with bold intensity with a code 94' do
    @sgr.apply_code!('m', 1)
    @sgr.apply_code!('m', 94)
    @sgr.foreground.should == :blue
    @sgr.intensity.should == :bold
  end
  it 'should have magenta background with bold intensity with a code 105' do
    @sgr.apply_code!('m', 1)
    @sgr.apply_code!('m', 105)
    @sgr.background.should == :magenta
    @sgr.intensity.should == :bold
  end
  it 'should have white background with bold intensity with a code 107' do
    @sgr.apply_code!('m', 1)
    @sgr.apply_code!('m', 107)
    @sgr.background.should == :white
    @sgr.intensity.should == :bold
  end
end

describe SGR, 'when an invalid code is executed' do
  before do
    @sgr = SGR.new
  end

  [10, -1, 108].each do |invalid_code|
    it "should raise an error with a code #{invalid_code}" do
      lambda{@sgr.apply_code!([invalid_code, 'm'])}.should raise_error(AnsiSysError)
    end
  end
end

describe SGR, 'to be rendered in HTML' do
	before do
		@sgr = SGR.new
	end

	it "should make no CSS with defalt properties" do
		@sgr.css_style.should == nil
	end

	it "should change foreground color" do
    @sgr.apply_code!('m', 32)
    @sgr.css_styles.should == {'color' => ['green']}
	end

	it "shuold show underline for ANSI single underline" do
    @sgr.apply_code!('m', 4)
    @sgr.css_styles.should == {'text-decoration' => ['underline']}
	end

	it "shuold show underline for ANSI double underline" do
    @sgr.apply_code!('m', 4)
    @sgr.css_styles.should == {'text-decoration' => ['underline']}
	end

	it "should switch foreground and background colors with reverse video" do
		@sgr.apply_code!('m', 7)
    @sgr.css_styles.should == {'color' => ['black'], 'background-color' => ['silver']}
	end

	it "should blink for ANSI slow blink" do
		@sgr.apply_code!('m', 5)
    @sgr.css_styles.should == {'text-decoration' => ['blink']}
	end

	it "should blink for ANSI fast blink" do
		@sgr.apply_code!('m', 6)
    @sgr.css_styles.should == {'text-decoration' => ['blink']}
	end

	it "should be able to be italic" do
		@sgr.apply_code!('m', 3)
    @sgr.css_styles.should == {'font-style' => ['italic']}
	end
	
	it "should be able to be invisible" do
		@sgr.apply_code!('m', 8)
    @sgr.css_styles.should == {'color' => ['black']}
	end
end
