#  Copyright (C) 2023 hidenorly
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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

	def test_getEnsuredPath
		puts "test_getEnsuredPath"
		assert_equal "/", FileUtil.getEnsuredPath("/")
		assert_equal "/", FileUtil.getEnsuredPath("//")
		assert_equal ".", FileUtil.getEnsuredPath(".")
		assert_equal ".", FileUtil.getEnsuredPath("./")
		assert_equal "./hoge", FileUtil.getEnsuredPath("hoge")
		assert_equal "/hoge", FileUtil.getEnsuredPath("//hoge/")
		assert_equal "/hoge", FileUtil.getEnsuredPath("//hoge//")
		assert_equal "./hoge/hoge", FileUtil.getEnsuredPath("hoge//hoge")
		assert_equal "./hoge/hoge", FileUtil.getEnsuredPath("hoge//hoge//")
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
		_createTmpFile(DEF_ENSUREDIRECTORY_TEST_PATH)
		_createTmpFile(DEF_ENSUREDIRECTORY_TEST_PATH2)
		FileUtil.cleanupDirectory(DEF_ENSUREDIRECTORY_TEST_PATH, true, true)
		assert_equal true, Dir.exist?(DEF_ENSUREDIRECTORY_TEST_PATH)
		assert_equal false, Dir.exist?(DEF_ENSUREDIRECTORY_TEST_PATH2)

		#check file existence in the path
		results1 = []
		FileUtil.iteratePath(DEF_ENSUREDIRECTORY_TEST_PATH, nil, results1, true, false)
		results2 = []
		FileUtil.iteratePath(DEF_ENSUREDIRECTORY_TEST_PATH, nil, results2, true, true)
		assert_equal results1, results2

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

	def test_getRegExpFilteredFiles
		puts "test_getRegExpFilteredFiles"
		setup()

		FileUtil.cleanupDirectory(DEF_ENSUREDIRECTORY_TEST_PATH, true, true)
		assert_equal true, Dir.exist?(DEF_ENSUREDIRECTORY_TEST_PATH)

		tmpFiles = []
		tmpFiles << _createTmpFile(DEF_ENSUREDIRECTORY_TEST_PATH)
		tmpFiles << _createTmpFile(DEF_ENSUREDIRECTORY_TEST_PATH)

		results = FileUtil.getRegExpFilteredFiles(DEF_ENSUREDIRECTORY_TEST_PATH, nil)
		assert_equal tmpFiles, results
		results = FileUtil.getRegExpFilteredFiles(DEF_ENSUREDIRECTORY_TEST_PATH, "[0-9]+")
		assert_equal tmpFiles, results
		results = FileUtil.getRegExpFilteredFiles(DEF_ENSUREDIRECTORY_TEST_PATH, "[a-zA-Z]+")
		assert_equal true, results.empty?

		teardown()
	end

	def test_getRegExpFilteredFilesMT
		puts "test_getRegExpFilteredFilesMT"
		setup()

		targets = [ DEF_ENSUREDIRECTORY_TEST_PATH, DEF_ENSUREDIRECTORY_TEST_PATH2 ]
		tmpFiles = []
		targets.each do | aTarget |
			FileUtil.cleanupDirectory(aTarget, true, true)
			assert_equal true, Dir.exist?(aTarget)

			tmpFiles << _createTmpFile(aTarget)
			tmpFiles << _createTmpFile(aTarget)
		end
		tmpFiles.sort!

		results = FileUtil.getRegExpFilteredFilesMT(targets, nil)
		results.sort!
		assert_equal tmpFiles, results
		results = FileUtil.getRegExpFilteredFilesMT(targets, "[0-9]+")
		results.sort!
		assert_equal tmpFiles, results
		results = FileUtil.getRegExpFilteredFilesMT(targets, "[a-zA-Z]+")
		results.sort!
		assert_equal true, results.empty?

		teardown()
	end

	def test_getRegExpFilteredFilesMT2
		puts "test_getRegExpFilteredFilesMT2"
		setup()

		FileUtil.cleanupDirectory(DEF_ENSUREDIRECTORY_TEST_PATH, true, true)
		assert_equal true, Dir.exist?(DEF_ENSUREDIRECTORY_TEST_PATH)

		tmpFiles = []
		tmpFiles << _createTmpFile(DEF_ENSUREDIRECTORY_TEST_PATH)
		tmpFiles << _createTmpFile(DEF_ENSUREDIRECTORY_TEST_PATH)

		results = FileUtil.getRegExpFilteredFilesMT2(DEF_ENSUREDIRECTORY_TEST_PATH, nil)
		assert_equal tmpFiles, results
		results = FileUtil.getRegExpFilteredFilesMT2(DEF_ENSUREDIRECTORY_TEST_PATH, "[0-9]+")
		assert_equal tmpFiles, results
		results = FileUtil.getRegExpFilteredFilesMT2(DEF_ENSUREDIRECTORY_TEST_PATH, "[a-zA-Z]+")
		assert_equal true, results.empty?

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
		begin
			FileUtil.appendLineToFile(nil, nil)
		rescue => e
			assert_equal true, false
		end
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

	def test_ArrayStream
		puts "test_ArrayStream"
		testData = ["line1", "line2"]
		stream = ArrayStream.new( testData )
		testData.each do |aLine|
			assert_equal false, stream.eof?
			assert_equal aLine, stream.readline
		end
		assert_equal true, stream.eof?

		assert_equal testData, stream.readlines

		testData2 = ["ine1", "line2"]
		assert_equal testData2, stream.readlines(1)

		i = 0
		stream.each_line do |aLine|
			assert_equal aLine, testData[i]
			i = i + 1
		end

		testData3 = "line3"
		stream.writeline(testData3)
		testData.concat( [testData3] )
		stream.puts(testData3)
		testData.concat( [testData3] )
		assert_equal testData, stream.readlines

		testData4 = ["line4", "line5"]
		stream.writelines(testData4)
		testData.concat( testData4 )
		assert_equal testData, stream.readlines
		stream.close()
	end


	def test_FileStream
		puts "test_ArrayStream"
		testData = ["line1", "line2"]

		FileUtils.rm_f(DEF_FILE_READ_WRITE_TEST_PATH) if File.exist?(DEF_FILE_READ_WRITE_TEST_PATH)
		FileUtil.ensureDirectory(DEF_BASE_TEST_PATH)
		FileUtil.writeFile(DEF_FILE_READ_WRITE_TEST_PATH, testData)
		assert_equal true, File.exist?(DEF_FILE_READ_WRITE_TEST_PATH)

		stream = FileStream.new( DEF_FILE_READ_WRITE_TEST_PATH )
		testData.each do |aLine|
			assert_equal false, stream.eof?
			assert_equal aLine, stream.readline.strip
		end
		assert_equal true, stream.eof?

		assert_equal testData, stream.readlines

		testData2 = ["ine1", "line2"]
		assert_equal testData2, stream.readlines(1)

		i = 0
		stream.each_line do |aLine|
			assert_equal aLine, testData[i]
			i = i + 1
		end

		testData3 = "line3"
		stream.writeline(testData3)
		testData.concat( [testData3] )
		stream.puts(testData3)
		testData.concat( [testData3] )
		assert_equal testData, stream.readlines

		testData4 = ["line4", "line5"]
		stream.writelines(testData4)
		testData.concat( testData4 )
		assert_equal testData, stream.readlines
		stream.close()

		FileUtils.rm_f(DEF_FILE_READ_WRITE_TEST_PATH) if File.exist?(DEF_FILE_READ_WRITE_TEST_PATH)
		teardown()
	end

	def test_getFileType
		assert_equal FileClassifier::FORMAT_SCRIPT, FileClassifier.getFileType("hoge.sh")
		assert_equal FileClassifier::FORMAT_SCRIPT, FileClassifier.getFileType("hoge.rc")
		assert_equal FileClassifier::FORMAT_SCRIPT, FileClassifier.getFileType("hoge.mk")
		assert_equal FileClassifier::FORMAT_SCRIPT, FileClassifier.getFileType("hoge.te")
		assert_equal FileClassifier::FORMAT_SCRIPT, FileClassifier.getFileType("hoge.rb")
		assert_equal FileClassifier::FORMAT_SCRIPT, FileClassifier.getFileType("hoge.py")

		assert_equal FileClassifier::FORMAT_C, FileClassifier.getFileType("hoge.c")
		assert_equal FileClassifier::FORMAT_C, FileClassifier.getFileType("hoge.cxx")
		assert_equal FileClassifier::FORMAT_C, FileClassifier.getFileType("hoge.cpp")
		assert_equal FileClassifier::FORMAT_C, FileClassifier.getFileType("hoge.h")
		assert_equal FileClassifier::FORMAT_C, FileClassifier.getFileType("hoge.hpp")

		assert_equal FileClassifier::FORMAT_JAVA, FileClassifier.getFileType("hoge.java")

		assert_equal FileClassifier::FORMAT_JSON, FileClassifier.getFileType("hoge.json")
		assert_equal FileClassifier::FORMAT_JSON, FileClassifier.getFileType("hoge.bp")

		assert_equal FileClassifier::FORMAT_UNKNOWN, FileClassifier.getFileType("hoge.")
	end

	def test_isBinaryFile
		assert_equal true, FileClassifier.isBinaryFile("hoge.so")
		assert_equal true, FileClassifier.isBinaryFile("hoge.apk")
		assert_equal false, FileClassifier.isBinaryFile("hoge.txt")
		assert_equal false, FileClassifier.isBinaryFile("hoge.rb")
	end


	def test_isMeanlessLine
		assert_equal true, FileClassifier.isMeanlessLine?("\# comment", FileClassifier::FORMAT_SCRIPT)
		assert_equal false, FileClassifier.isMeanlessLine?("\# comment", FileClassifier::FORMAT_C)
		assert_equal false, FileClassifier.isMeanlessLine?("// comment", FileClassifier::FORMAT_SCRIPT)
		assert_equal true, FileClassifier.isMeanlessLine?("// comment", FileClassifier::FORMAT_C)
	end
end