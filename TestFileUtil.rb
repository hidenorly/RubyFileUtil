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

	@tmpCount = 0
	def _createTmpFile(basePath)
		@tmpCount = 0 if !@tmpCount
		@tmpCount = @tmpCount.to_i + 1
		path = "#{basePath}/#{@tmpCount.to_s}"
		FileUtil.writeFile(path, ["tempFile"] )
		return File.exist?(path) ? path : nil
	end

	def test_removeDirectoryIfNoFile
		puts "test_removeDirectoryIfNoFile"
		setup()
		FileUtil.ensureDirectory(DEF_ENSUREDIRECTORY_TEST_PATH)
		assert_equal true, Dir.exist?(DEF_ENSUREDIRECTORY_TEST_PATH)
		FileUtil.removeDirectoryIfNoFile(DEF_ENSUREDIRECTORY_TEST_PATH)
		assert_equal false, Dir.exist?(DEF_ENSUREDIRECTORY_TEST_PATH)

		FileUtil.ensureDirectory(DEF_ENSUREDIRECTORY_TEST_PATH)
		assert_equal true, Dir.exist?(DEF_ENSUREDIRECTORY_TEST_PATH)
		_createTmpFile(DEF_ENSUREDIRECTORY_TEST_PATH)
		FileUtil.removeDirectoryIfNoFile(DEF_ENSUREDIRECTORY_TEST_PATH)
		assert_equal true, Dir.exist?(DEF_ENSUREDIRECTORY_TEST_PATH)

		teardown()
	end

	DEF_ENSUREDIRECTORY_TEST_PATH2="#{DEF_ENSUREDIRECTORY_TEST_PATH}/ruby2"

	def test_cleanupDirectory
		puts "test_cleanupDirectory"
		setup()
		FileUtil.cleanupDirectory(DEF_ENSUREDIRECTORY_TEST_PATH)
		assert_equal true, Dir.exist?(DEF_ENSUREDIRECTORY_TEST_PATH)

		_createTmpFile(DEF_ENSUREDIRECTORY_TEST_PATH)
		FileUtil.cleanupDirectory(DEF_ENSUREDIRECTORY_TEST_PATH, true, true)
		assert_equal true, Dir.exist?(DEF_ENSUREDIRECTORY_TEST_PATH)

		FileUtil.ensureDirectory(DEF_ENSUREDIRECTORY_TEST_PATH2)
		FileUtil.cleanupDirectory(DEF_ENSUREDIRECTORY_TEST_PATH, true, true)
		assert_equal true, Dir.exist?(DEF_ENSUREDIRECTORY_TEST_PATH)
		assert_equal false, Dir.exist?(DEF_ENSUREDIRECTORY_TEST_PATH2)

		#TODO: check file existence in the path

		teardown()
	end


	def test_iteratePath
		puts "test_iteratePath"
		setup()

		FileUtil.cleanupDirectory(DEF_ENSUREDIRECTORY_TEST_PATH, true, true)
		assert_equal true, Dir.exist?(DEF_ENSUREDIRECTORY_TEST_PATH)

		tmpFiles = []
		tmpFiles << _createTmpFile(DEF_ENSUREDIRECTORY_TEST_PATH)
		tmpFiles << _createTmpFile(DEF_ENSUREDIRECTORY_TEST_PATH)

		results = []
		FileUtil.iteratePath(DEF_ENSUREDIRECTORY_TEST_PATH, nil, results, true, false)
		assert_equal results, tmpFiles

		#TODO: should have recursive=false case, dirOnly=true case

		teardown()
	end

	def test_getFilenameFromPath
		puts "test_getFilenameFromPath"
		assert_equal "hoge", FileUtil.getFilenameFromPath("/folder/hoge")
		assert_equal "hoge", FileUtil.getFilenameFromPath("/hoge")
		assert_equal "hoge", FileUtil.getFilenameFromPath("hoge")
	end

	def test_getFilenameFromPathWithoutExt
		puts "test_getFilenameFromPathWithoutExt"
		assert_equal "hoge", FileUtil.getFilenameFromPathWithoutExt("/folder/hoge.so")
		assert_equal "hoge", FileUtil.getFilenameFromPathWithoutExt("/hoge.so")
		assert_equal "hoge", FileUtil.getFilenameFromPathWithoutExt("hoge")
	end

	def test_getDirectoryFromPath
		puts "test_getDirectoryFromPath"
		assert_equal "/folder", FileUtil.getDirectoryFromPath("/folder/hoge.so")
		assert_equal "/", FileUtil.getDirectoryFromPath("/hoge.so")
		assert_equal ".", FileUtil.getDirectoryFromPath("hoge")
		assert_equal "./hoge", FileUtil.getDirectoryFromPath("hoge/hoge2")
		assert_equal "./hoge", FileUtil.getDirectoryFromPath("./hoge/hoge2")

		assert_equal "/folder", FileUtil.getDirectoryFromPath("//folder/hoge.so")
		assert_equal "/", FileUtil.getDirectoryFromPath("//hoge.so")
		assert_equal "./hoge", FileUtil.getDirectoryFromPath("hoge//hoge2")
		assert_equal "./hoge", FileUtil.getDirectoryFromPath(".///hoge//hoge2")
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