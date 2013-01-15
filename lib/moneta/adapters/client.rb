require 'socket'

module Moneta
  module Adapters
    # Moneta client backend
    # @api public
    class Client
      include Net
      include Defaults

      # @param [Hash] options
      # @option options [Integer] :port (9000) TCP port
      # @option options [String] :host ('127.0.0.1') Hostname
      # @option options [String] :file Unix socket file name as alternative to `:port` and `:host`
      def initialize(options = {})
        @socket = options[:file] ? UNIXSocket.open(options[:file]) :
          TCPSocket.open(options[:host] || '127.0.0.1', options[:port] || DEFAULT_PORT)
      end

      # (see Proxy#key?)
      def key?(key, options = {})
        write(@socket, [:key?, key, options])
        read_result
      end

      # (see Proxy#load)
      def load(key, options = {})
        write(@socket, [:load, key, options])
        read_result
      end

      # (see Proxy#load_multi)
      def load_multi(keys, options = {})
        write(@socket, [:load_multi, keys, options])
        read_result
      end

      # (see Proxy#store)
      def store(key, value, options = {})
        write(@socket, [:store, key, value, options])
        read_result
        value
      end

      # (see Proxy#store_multi)
      def store_multi(entries, options = {})
        write(@socket, [:store_multi, entries, options])
        read_result
        entries
      end

      # (see Proxy#delete)
      def delete(key, options = {})
        write(@socket, [:delete, key, options])
        read_result
      end

      # (see Proxy#delete_multi)
      def delete_multi(keys, options = {})
        write(@socket, [:delete_multi, keys, options])
        read_result
      end

      # (see Proxy#increment)
      def increment(key, amount = 1, options = {})
        write(@socket, [:increment, key, amount, options])
        read_result
      end

      # (see Proxy#clear)
      def clear(options = {})
        write(@socket, [:clear, options])
        read_result
        self
      end

      # (see Proxy#close)
      def close
        @socket.close
        nil
      end

      private

      def read_result
        result = read(@socket)
        raise result if Error === result
        result
      end
    end
  end
end
