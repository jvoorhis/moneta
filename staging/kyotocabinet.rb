require 'kyotocabinet'

module Moneta
  module Adapters
    # KyotoCabinet backend
    # @api public
    class KyotoCabinet < Memory
      # Constructor
      #
      # @param [Hash] options
      #
      # Options:
      # * :file - Database file
      # * :type - Database type (default :hdb, :bdb and :hdb possible)
      def initialize(options = {})
        file = options[:file]
        raise ArgumentError, 'Option :file is required' unless options[:file]
        if options[:type] == :bdb
          @memory = ::KyotoCabinet::BDB.new
          @memory.open(file, ::KyotoCabinet::BDB::OWRITER | ::KyotoCabinet::BDB::OCREAT)
        else
          @memory = ::KyotoCabinet::HDB.new
          @memory.open(file, ::KyotoCabinet::HDB::OWRITER | ::KyotoCabinet::HDB::OCREAT)
        end or raise @memory.errmsg(@memory.ecode)
      end

      def delete(key, options = {})
        value = load(key, options)
        if value
          @memory.delete(key)
          value
        end
      end

      def close
        @memory.close
        nil
      end
    end
  end
end
