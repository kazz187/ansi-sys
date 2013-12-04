$:.unshift('lib')
require 'ansisys'

include AnsiSys
describe Cursor, 'when initialized' do
  before do
    @cursor = Cursor.new
  end

  it "should be at (1,1) on screen" do
		@cursor.cur_col.should == 1
		@cursor.cur_row.should == 1
	end

	it "should be in (80,25) screen" do
		@cursor.max_col.should == 80
		@cursor.max_row.should == 25
	end
end

describe Cursor, 'when moved normally' do
	before do
		@cursor = Cursor.new
		@cursor.instance_variable_set('@cur_col', 5)
		@cursor.instance_variable_set('@cur_row', 5)
	end

	it "should move up with code CUU" do
		lambda{@cursor.apply_code!('A')}.should change(@cursor, :cur_row).by(-1)
		lambda{@cursor.apply_code!('A', 1)}.should change(@cursor, :cur_row).by(-1)
		lambda{@cursor.apply_code!('A', 2)}.should change(@cursor, :cur_row).by(-2)
	end

	it "should move down with code CUD" do
		lambda{@cursor.apply_code!('B')}.should change(@cursor, :cur_row).by(1)
		lambda{@cursor.apply_code!('B', 1)}.should change(@cursor, :cur_row).by(1)
		lambda{@cursor.apply_code!('B', 2)}.should change(@cursor, :cur_row).by(2)
	end

	it "should move to right with code CUF" do
		lambda{@cursor.apply_code!('C')}.should change(@cursor, :cur_col).by(1)
		lambda{@cursor.apply_code!('C', 1)}.should change(@cursor, :cur_col).by(1)
		lambda{@cursor.apply_code!('C', 2)}.should change(@cursor, :cur_col).by(2)
	end

	it "should move to left with code CUB" do
		lambda{@cursor.apply_code!('D')}.should change(@cursor, :cur_col).by(-1)
		lambda{@cursor.apply_code!('D', 1)}.should change(@cursor, :cur_col).by(-1)
		lambda{@cursor.apply_code!('D', 2)}.should change(@cursor, :cur_col).by(-2)
	end

	it "should move to beggining of lower line with code CNL" do
		[[1, 'E'], [1, ['E', 1]], [2, ['E', 2]]].each do |d, code|
			lambda{@cursor.apply_code!(*code)}.should change(@cursor, :cur_row).by(d)
			@cursor.cur_col.should == 1
		end
	end

	it "should move to beggining of upper line with code CPL" do
		[[-1, ['F']], [-1, ['F', 1]], [-2, ['F', 2]]].each do |d, code|
			lambda{@cursor.apply_code!(*code)}.should change(@cursor, :cur_row).by(d)
			@cursor.cur_col.should == 1
		end
	end

	it "should move to specified column with code CHA" do
		[[1, ['G']], [1, ['G', 1]], [2, ['G', 2]]].each do |c, code|
			lambda{@cursor.apply_code!(*code)}.should_not change(@cursor, :cur_row)
			@cursor.cur_col.should == c
		end
	end

	it "should move to specified position with codes CUP and HVP" do
		%w(H f).each do |letter|
			[
				# row, column, pars
				[1, 5, [nil, 5]],
				[1, 5, [1, 5]],
				[17, 1, [17, nil]],
				[17, 1, [17, 1]],
				[9, 8, [9, 8]],
			].each do |r, c, pars|
				@cursor.apply_code!(letter, *pars)
				@cursor.cur_col.should == c
				@cursor.cur_row.should == r
			end
		end
	end

end

describe Cursor, 'when tried to be moved beyond edge' do
	before do
		@cursor = Cursor.new
	end

	it "should not move with code CUU" do
		@cursor.instance_variable_set('@cur_row', 1)
		lambda{@cursor.apply_code!('A', 1)}.should_not change(@cursor, :cur_row)
	end

	it "should not move with code CUD" do
		@cursor.instance_variable_set('@cur_row', @cursor.max_row)
		lambda{@cursor.apply_code!('B', 1)}.should_not change(@cursor, :cur_row)
	end

	it "should not move with code CUF" do
		@cursor.instance_variable_set('@cur_col', @cursor.max_col)
		lambda{@cursor.apply_code!('C', 1)}.should_not change(@cursor, :cur_col)
	end

	it "should not move with code CUB" do
		@cursor.instance_variable_set('@cur_col', 1)
		lambda{@cursor.apply_code!('D', 1)}.should_not change(@cursor, :cur_col)
	end

	it "should make screen longer with code CNL" do
		@cursor.instance_variable_set('@cur_row', @cursor.max_row)
		lambda{@cursor.apply_code!('E', 1)}.should change(@cursor, :max_row).by(1)
	end

	it "should not change row with code CNL" do
		@cursor.instance_variable_set('@cur_row', 1)
		lambda{@cursor.apply_code!('F', 1)}.should_not change(@cursor, :cur_row)
	end

	it "should move to edge column with code CHA" do
		lambda{@cursor.apply_code!('G', 99)}.should change(@cursor, :cur_col).to(@cursor.max_col)
	end

end

describe Cursor, 'when advanced' do
	it "should move to the next column usually" do
		cursor = Cursor.new(1, 1, 80, 25)
		lambda{cursor.advance!}.should change(cursor, :cur_col).by(1)
		[1, 2, 3].each do |w|
			lambda{cursor.advance!(w)}.should change(cursor, :cur_col).by(w)
		end
		cursor = Cursor.new(79, 1, 80, 25)
		lambda{cursor.advance!}.should change(cursor, :cur_col).by(1)
	end

	it "should move to the next row from the right edge" do
		cursor = Cursor.new(80, 1, 80, 25)
		lambda{cursor.advance!(1)}.should change(cursor, :cur_row).by(1)
		cursor.cur_col.should == 1
	end

	it "should return nil for a usual move" do
		cursor = Cursor.new(1, 1, 80, 25)
		[1, 2, 3].each do |w|
			cursor.advance!(w).should == nil
		end
	end
	
	it "should return \"\\n\" going beyond the right edge" do
		cursor = Cursor.new(80, 1, 80, 25)
		cursor.advance!(1).should == "\n"
	end
	
end

