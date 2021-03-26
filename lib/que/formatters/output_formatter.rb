# frozen_string_literal: true

require 'active_support/logger'

module Que
  module Formatters
    class OutputFormatter < ::Logger::Formatter
      # This method is invoked when a log event occurs
      def call(severity, timestamp, progname, msg)
        # Check to see if the string is a json message first
        if msg.is_a?(String)
          begin
            msg = JSON.parse(msg, symbolize_names: true)
          rescue JSON::ParserError => _e
            # Do nothing as the message will be processed as a string
          end
        end

        defaults =
          { program: progname, severity: severity, timestamp: timestamp }

        if msg.is_a?(Hash) || msg.is_a?(JSON) # msg is a hash or JSON
          msg.merge(defaults).to_json + "\n"
        elsif msg.is_a?(Exception)
          defaults.merge(
            msg: msg.message,
            class: msg.class,
            backtrace: msg.backtrace
          ).to_json + "\n"
        else
          defaults.merge(
            msg: (msg.is_a?(String) ? msg : msg.inspect).to_s
          ).to_json + "\n"
        end
      end
    end
  end
end
