require "minitest/autorun"
require_relative "StrUtil"
require "json"

class TestStrUtil < Minitest::Test
	def setup
	end

	def teardown
	end

	def test_getBlacket
		puts "test_getBlacket"
		theStr= "(abc(def(g(h)())))"
		assert_equal "abc(def(g(h)()))", StrUtil.getBlacket(theStr, "(", ")", 0)
		assert_equal "def(g(h)())", StrUtil.getBlacket(theStr, "(", ")", 1)
		assert_equal "def(g(h)())", StrUtil.getBlacket(theStr, "(", ")", 4)
		assert_equal "g(h)()", StrUtil.getBlacket(theStr, "(", ")", 5)
		assert_equal "h", StrUtil.getBlacket(theStr, "(", ")", 9)
	end

	def test_ensureJson
		puts "test_ensureJson"
		theStr= "hoge:{key1:val1, key2:val2, key3:[1,2,3,4]}"
		ensuredJson = StrUtil.ensureJson(theStr)
		assert_equal "{\"hoge\":{\"key1\":\"val1\", \"key2\":\"val2\", \"key3\":[1,2,3,4]}}", ensuredJson
		theJson = {}
		begin
			theJson = JSON.parse(ensuredJson)
		rescue => ex
		end
		assert_equal true, theJson.has_key?("hoge")
		assert_equal true, theJson["hoge"].has_key?("key1")
		assert_equal "val1", theJson["hoge"]["key1"]
		assert_equal true, theJson["hoge"].has_key?("key2")
		assert_equal "val2", theJson["hoge"]["key2"]
		assert_equal true, theJson["hoge"].has_key?("key3")
		assert_equal 4, theJson["hoge"]["key3"].length
	end
end