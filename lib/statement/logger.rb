require 'logger'

module Statement
  class Logger
    class << self
      attr_accessor :logger

      def setup(log_level: ::Logger::INFO, output: $stdout)
        @logger = ::Logger.new(output)
        @logger.level = log_level
        @logger.formatter = proc do |severity, datetime, progname, msg|
          "[#{datetime.strftime('%Y-%m-%d %H:%M:%S')}] #{severity}: #{msg}\n"
        end
        @logger
      end

      def instance
        @logger ||= setup
      end

      def info(message)
        instance.info(message)
      end

      def warn(message)
        instance.warn(message)
      end

      def error(message)
        instance.error(message)
      end

      def debug(message)
        instance.debug(message)
      end

      def fatal(message)
        instance.fatal(message)
      end
    end
  end
end
