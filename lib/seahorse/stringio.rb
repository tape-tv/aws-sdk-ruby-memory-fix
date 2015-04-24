module Seahorse
  class StringIO
    def initialize(data = '')
      @data = data
      @offset = 0
    end

    def write(data)
      @data << data
      @offset += data.bytesize
      data.bytesize
    end

    def read(bytes = nil, output_buffer = nil)
      if bytes
        data = partial_read(bytes)
      else
        data = full_read
      end
      output_buffer ? output_buffer.replace(data || '') : data
    end

    def rewind
      @offset = 0
    end

    def truncate(bytes)
      @data = @data[0,bytes]
      bytes
    end

    def size
      @data.bytesize
    end

    def eof
      @offset == @data.bytesize
    end
    alias_method :eof?, :eof

    private

    def partial_read(bytes)
      if @offset >= @data.bytesize
        nil
      else
        data = @data[@offset,@offset+bytes]
        bump_offset(bytes)
        data
      end
    end

    def full_read
      data = @offset == 0 ? @data : @data[@offset..-1]
      @offset = @data.bytesize
      data || ''
    end

    def bump_offset(bytes)
      @offset = [@data.bytesize, @offset + bytes].min
    end
  end
end
