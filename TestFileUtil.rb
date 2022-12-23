require "minitest/autorun"
require_relative "FileUtil"

class TestFileUtil < Minitest::Test
	DEF_BASE_TEST_PATH=File.expand_path("~/.test")
	DEF_ENSUREDIRECTORY_TEST_PATH="#{DEF_BASE_TEST_PATH}/ruby"

	def setup
		puts "setup"
		FileUtils.rm_rf(DEF_BASE_TEST_PATH) if Dir.exist?(DEF_BASE_TEST_PATH)
	end

	def teardown
		puts "teardown"
		FileUtils.rm_rf(DEF_BASE_TEST_PATH) if Dir.exist?(DEF_BASE_TEST_PATH)
	end

	def test_ensureDirectory
		puts "test_ensureDirectory"
		setup()
		FileUtil.ensureDirectory(DEF_ENSUREDIRECTORY_TEST_PATH)
		assert_equal true, Dir.exist?(DEF_ENSUREDIRECTORY_TEST_PATH)
		teardown()
	end
end