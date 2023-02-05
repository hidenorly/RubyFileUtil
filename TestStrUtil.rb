require "minitest/autorun"
require_relative "StrUtil"

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
end