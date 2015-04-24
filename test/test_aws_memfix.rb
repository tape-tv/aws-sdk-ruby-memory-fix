require "minitest_helper"
require "aws-sdk"

class TestAwsMemfix < Minitest::Test
  def setup
    @sqs = Aws::SQS::Client.new(endpoint: "http://lvh.me:9324", access_key_id: "xxx", secret_access_key: "xxx", region: "us-east-1")
    @queue_url = begin
      @sqs.get_queue_url(queue_name: "test")[:queue_url]
    rescue Aws::SQS::Errors::NonExistentQueue
      @sqs.create_queue(queue_name: "test")[:queue_url]
    end.gsub("localhost", "lvh.me")
  end

  def test_memory_leaking
    results = measure_sqs(1000)
    puts "leaking: #{results}" if $DEBUG

    assert results[:memory] > 5000
    assert results[:leaks] > 500
  end

  def test_memory_not_leaking
    require "aws_memfix"
    results = measure_sqs(1000)
    puts "not leaking: #{results}" if $DEBUG

    assert results[:memory] < 2000
    assert results[:leaks] < 100
  end

  private
  def measure_sqs(iterations)
    perform_measurement do
      iterations.times { @sqs.send_message(queue_url: @queue_url, message_body: ?a * 1024) }
    end
  end

  def perform_measurement(&block)
    memory_before = get_memory
    leaks_before = get_leaks

    yield

    memory_after = get_memory
    leaks_after = get_leaks

    { memory: memory_after - memory_before, leaks: leaks_after - leaks_before }
  end

  def get_memory
    GC.start
    sleep(1)
    `ps -o rss -p #{Process.pid} | tail +2`.strip.to_i
  end

  def get_leaks
    `leaks #{Process.pid} | grep -c Leak`.strip.to_i
  end
end
