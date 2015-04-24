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
    begin
      Seahorse.send(:remove_const, :StringIO)
      leaking_results = measure_sqs(1000)
    ensure
      load File.expand_path("../lib/seahorse/stringio.rb", __dir__)
    end

    nonleak_results = measure_sqs(1000)

    if ENV["DEBUG"]
      puts "Leaking: #{leaking_results}"
      puts "NonLeak: #{nonleak_results}"
    end

    assert leaking_results[:leaks] > nonleak_results[:leaks]
    assert leaking_results[:memory] > nonleak_results[:memory]
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
