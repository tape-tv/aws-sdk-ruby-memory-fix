require_relative "../minitest_helper"
require "seahorse/stringio"

module StringIOTest
  def test_that_it_returns_the_number_of_bytes_written
    assert_equal 4, @io.write("foß")
  end

  def test_that_it_read_data
    @io.write("foo")
    assert_equal "", @io.read

    @io.rewind
    assert_equal "f", @io.read(1)
    assert_equal "oo", @io.read
  end

  def test_that_it_reads_to_buffer
    @io.write("foo")
    @io.rewind
    output = ""

    @io.read(1, output)
    assert_equal "f", output

    @io.read(nil, output)
    assert_equal "oo", output
  end

  def test_that_it_reports_bytesize
    @io.write("foß")
    assert_equal 4, @io.size
  end

  def test_that_it_truncates_data
    @io.write("foo")
    @io.truncate(2)

    @io.rewind
    assert_equal "fo", @io.read
  end
end

class TestSeahorseStringIO < Minitest::Test
  include StringIOTest
  def setup
    @io = Seahorse::StringIO.new("")
  end
end

class TestStringIO < Minitest::Test
  include StringIOTest
  def setup
    @io = ::StringIO.new("")
  end
end
