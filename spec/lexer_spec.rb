$:.unshift('lib')
require 'ansisys'

include AnsiSys
describe Lexer::PARAMETER_AND_LETTER, "a regexp for parameters and a letter" do
	it 'should not match partial code' do
		m = Lexer::PARAMETER_AND_LETTER.match("32")
		m.should == nil
	end

	it 'should match a code without parameter' do
		m = Lexer::PARAMETER_AND_LETTER.match("m")
		m.should_not == nil
		m[2].should == 'm'
	end

	it 'should match a code with a parameter' do
		m = Lexer::PARAMETER_AND_LETTER.match("32m")
		m.should_not == nil
		m[1].should == '32'
		m[2].should == 'm'
	end

	it 'should match a code with two parameters' do
		m = Lexer::PARAMETER_AND_LETTER.match("32;0m")
		m.should_not == nil
		m[1].should == '32;0'
		m[2].should == 'm'
	end

	it 'should match a code with three parameters' do
		m = Lexer::PARAMETER_AND_LETTER.match("32;0;1m")
		m.should_not == nil
		m[1].should == '32;0;1'
		m[2].should == 'm'
	end

	it 'should match a code with three and omitted parameters' do
		m = Lexer::PARAMETER_AND_LETTER.match("32;;1m")
		m.should_not == nil
		m[1].should == '32;;1'
		m[2].should == 'm'
	end
end

describe Lexer do
	before do
		@lexer = Lexer.new(["\x1b["])
	end

	it 'should return usual string as it is' do
		x = 'Usual string.'
		@lexer.push(x)
		@lexer.buffer.should == x
		@lexer.lex!.should == [[:string, x]]
		@lexer.buffer.should be_empty
	end

	it 'should return nothing if a code is not complete' do
		@lexer.push("\x1b[32")
		@lexer.lex!.should be_empty
		@lexer.buffer.should_not be_empty
	end

	it 'should return string and complete code' do
		@lexer.push("string one\x1b[32mstring two")
		@lexer.lex!.should == [[:string, 'string one'], [:code, '32m'], [:string, 'string two']]
		@lexer.buffer.should be_empty
	end

	it 'should translate LF to a code E' do
		@lexer.push("line one\nline two\n")
		@lexer.lex!.should == [[:string, 'line one'], [:code, 'E'], [:string, 'line two'], [:code, 'E']]
		@lexer.buffer.should be_empty
	end

	it 'should translate CRLF to a code E' do
		@lexer.push("line one\r\nline two\r\n")
		@lexer.lex!.should == [[:string, 'line one'], [:code, 'E'], [:string, 'line two'], [:code, 'E']]
		@lexer.buffer.should be_empty
	end

	it 'should translate LFCR to a code E' do
		@lexer.push("line one\n\rline two\n\r")
		@lexer.lex!.should == [[:string, 'line one'], [:code, 'E'], [:string, 'line two'], [:code, 'E']]
		@lexer.buffer.should be_empty
	end

	it 'should translate CR to a code B' do
		@lexer.push("line one\rline two\r")
		@lexer.lex!.should == [[:string, 'line one'], [:code, 'B'], [:string, 'line two'], [:code, 'B']]
		@lexer.buffer.should be_empty
	end

end
