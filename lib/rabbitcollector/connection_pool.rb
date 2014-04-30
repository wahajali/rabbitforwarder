require 'singleton'
module Rabbit
  class ConnectionPool
    include Singleton

    def get_connection
      conn = @@connections[@@index]
      @@index += 1
      @@index = @@index % @@pool_size 
      conn
    end

    private

    def initialize
      @@pool_size = ::Collector::Config.connection_pool
      @@connections = Array.new
      @@index = 0
      (0..@@pool_size - 1).each do |i|
        @@connections.push EventMachine::HttpRequest.new(::Collector::Config.kairos_host)
      end
    end
  end
end
