module Collector
  # Singleton config used throughout
  class Config
    class << self
      attr_accessor :kairos_host, :kairos_port, :rabbit_host, :rabbit_port, :rabbit_user, :rabbit_pwd, :connection_pool, :interval

      def logger
        raise "logger was used without being configured" unless @logging_configured
        @logger 
      end

      def setup_logging(config={})
        @logger = Logger.new(config["file"])
        @logging_configured = true
        logger.info("collector.started")
      end

      # Configures the various attributes
      #
      # @param [Hash] config the config Hash
      def configure(config)
        setup_logging(config["logging"])

        @kairos_host = config["kairos_host"]

        @kairos_port = config["kairos_port"]

        @rabbit_host = config["rabbit_host"]
        @rabbit_user = config["rabbit_user"]
        @rabbit_port = config["rabbit_port"]
        @rabbit_pwd = config["rabbit_pwd"]

        @connection_pool = config["connection_pool"]

        @interval = config["interval"]
      end
    end
  end
end
