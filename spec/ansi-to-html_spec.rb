script = File.join('bin', 'ansi-to-html')
source = File.join('spec', 'attach', 'test_utf8_wide.txt')
target = File.join('spec', 'attach', 'test_utf8_wide.rendered.txt')

describe "when rendering a UTF-8 text" do
	it "should fold characters as expected" do
		`ruby -Ilib #{script} #{source}`.should include(File.read(target).chomp)
	end
end
