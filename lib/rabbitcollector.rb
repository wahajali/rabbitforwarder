#require "rabbitcollector/version"
require "eventmachine"
require "em-http-request"
require_relative "rabbitcollector/config"
require_relative "rabbitcollector/rabbithandler"
require "json"
require "pry"

module Rabbit
  class RabbitCollector
    def start
      EM.run do
        rabbit_handler = Rabbit::RabbitHandler.new
        EventMachine.add_periodic_timer(Collector::Config.interval) {
          http = EventMachine::HttpRequest.new("#{Collector::Config.rabbit_host}:#{Collector::Config.rabbit_port}/api/queues").get :head => {'authorization' => [Collector::Config.rabbit_user, Collector::Config.rabbit_pwd]}
          http.callback{
            timestamp = (Time.now.to_f * 1000).to_i
            rabbit_handler.receive_data(JSON.parse(http.response), timestamp)
          }
        }
      end
    end
  end
end
