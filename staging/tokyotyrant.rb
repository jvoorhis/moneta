require 'tokyotyrant'

module Moneta
  module Adapters
    class TokyoTyrant < Base
      def initialize(options = {})
        raise 'Option :host is required' unless options[:host]
        raise 'Option :port is required' unless options[:port]
        @store = ::TokyoTyrant::RDB.new
        unless @store.open(options[:host], options[:port])
          raise @hash.errmsg(@hash.ecode)
        end
      end

      def key?(key, options = {})
        !!self[key]
      end

      def store(key, value, options = {})
        @store.put(key_for(key), serialize(value))
      end

      def delete(key, options = {})
        value = self[key]
        @hash.delete(key_for(key))
        value
      end
    end
  end
end
