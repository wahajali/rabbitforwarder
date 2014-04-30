require 'yajl'
require 'vine'
require_relative 'connection_pool'

module Rabbit
  class RabbitHandler 
    def receive_data(data, timestamp)
=begin
        File.open('logs/data.logs', 'a') do |file| 
          file.write(data.to_s + "\n") 
        end
=end

      body = Yajl::Encoder.encode(process_data(data, timestamp))
      http = ConnectionPool.instance.get_connection.post body: body, keepalive: true, headers: {"Content-type" => "application/json"}

      http.errback do
        ::Collector::Config.logger.warn('http.response.failed to kairos: ' + http.error)
      end

        http.callback do
          #NOTE: do nothing. why waste time logging success?
          #::Collector::Config.logger.warn('http.response.success' + http.error)
        end
    end

    ITEMS = %W[messages consumers active_consumers memory messages_details.rate messages_ready_details.rate messages_unacknowledged_details.rate messages_stats.rate backing_queue_status.avg_ingress_rate backing_queue_status.avg_egress_rate backing_queue_status.avg_ack_ingress_rate backing_queue_status.avg_ack_egress_rate].freeze
    TAGS = %W[vhost].freeze

    def process_data(data, timestamp)
      kairos_data = Array.new
      data.each do |queue|
        ITEMS.each do |item|
          publish_data = {}
          tags = {}
          TAGS.each do |t|
            tags[t] = queue[t]
          end
          tags["name"] = item
          publish_data[:value] = queue.access(item)
          publish_data[:name] = queue["name"]
          publish_data[:timestamp] = timestamp
          publish_data[:tags] = tags
          kairos_data.push publish_data unless publish_data[:value].nil?
        end
      end
      kairos_data
    end
  end
end
