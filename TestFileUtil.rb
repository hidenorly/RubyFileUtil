require "minitest/autorun"
require_relative "FileUtil"

class TestFileUtil < Minitest::Test
	DEF_BASE_TEST_PATH=File.expand_path("~/.test")
	DEF_ENSUREDIRECTORY_TEST_PATH="#{DEF_BASE_TEST_PATH}/ruby"

	def setup
		FileUtils.rm_rf(DEF_BASE_TEST_PATH) if Dir.exist?(DEF_BASE_TEST_PATH)
	end

	def teardown
		FileUtils.rm_rf(DEF_BASE_TEST_PATH) if Dir.exist?(DEF_BASE_TEST_PATH)
	end

	def test_ensureDirectory
		puts "test_ensureDirectory"
		setup()
		FileUtil.ensureDirectory(DEF_ENSUREDIRECTORY_TEST_PATH)
		assert_equal true, Dir.exist?(DEF_ENSUREDIRECTORY_TEST_PATH)
		teardown()
	end

	def test_getFilenameFromPath
		puts "test_getFilenameFromPath"
		assert_equal "hoge", FileUtil.getFilenameFromPath("/folder/hoge")
		assert_equal "hoge", FileUtil.getFilenameFromPath("/hoge")
		assert_equal "hoge", FileUtil.getFilenameFromPath("hoge")
	end

	DEF_FILE_READ_WRITE_TEST_PATH="#{DEF_BASE_TEST_PATH}/test"

	def test_write_read_file
		puts "test_write_read_file"
		FileUtils.rm_f(DEF_FILE_READ_WRITE_TEST_PATH) if File.exist?(DEF_FILE_READ_WRITE_TEST_PATH)
		FileUtil.ensureDirectory(DEF_BASE_TEST_PATH)

		writeBody = ["hoge"]
		FileUtil.writeFile(DEF_FILE_READ_WRITE_TEST_PATH, writeBody)
		assert_equal true, File.exist?(DEF_FILE_READ_WRITE_TEST_PATH)

		readBody = FileUtil.readFile(DEF_FILE_READ_WRITE_TEST_PATH)
		assert_equal readBody.strip!, writeBody[0]

		FileUtils.rm_f(DEF_FILE_READ_WRITE_TEST_PATH) if File.exist?(DEF_FILE_READ_WRITE_TEST_PATH)
		teardown()
	end


	def test_write_read_file_array
		puts "test_write_read_file_array"
		FileUtils.rm_f(DEF_FILE_READ_WRITE_TEST_PATH) if File.exist?(DEF_FILE_READ_WRITE_TEST_PATH)
		FileUtil.ensureDirectory(DEF_BASE_TEST_PATH)

		writeBody = ["hoge"]
		FileUtil.writeFile(DEF_FILE_READ_WRITE_TEST_PATH, writeBody)
		assert_equal true, File.exist?(DEF_FILE_READ_WRITE_TEST_PATH)

		readBody = FileUtil.readFileAsArray(DEF_FILE_READ_WRITE_TEST_PATH)
		assert_equal readBody, writeBody

		FileUtils.rm_f(DEF_FILE_READ_WRITE_TEST_PATH) if File.exist?(DEF_FILE_READ_WRITE_TEST_PATH)
		teardown()
	end

	def test_appendLineToFile
		puts "test_appendLineToFile"
		FileUtils.rm_f(DEF_FILE_READ_WRITE_TEST_PATH) if File.exist?(DEF_FILE_READ_WRITE_TEST_PATH)
		FileUtil.ensureDirectory(DEF_BASE_TEST_PATH)

		writeBody = ["hoge"]
		FileUtil.writeFile(DEF_FILE_READ_WRITE_TEST_PATH, writeBody)
		append = "hoge2"
		FileUtil.appendLineToFile(DEF_FILE_READ_WRITE_TEST_PATH, append)
		writeBody << append

		readBody = FileUtil.readFileAsArray(DEF_FILE_READ_WRITE_TEST_PATH)
		assert_equal readBody, writeBody

		FileUtils.rm_f(DEF_FILE_READ_WRITE_TEST_PATH) if File.exist?(DEF_FILE_READ_WRITE_TEST_PATH)
		teardown()
	end

end