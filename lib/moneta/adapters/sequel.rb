require 'sequel'

module Moneta
  module Adapters
    # Sequel backend
    # @api public
    class Sequel
      include Defaults
      include IncrementSupport

      # @param [Hash] options
      # @option options [String] :db Sequel database
      # @option options [String/Symbol] :table (:moneta) Table name
      # @option options All other options passed to `Sequel#connect`
      def initialize(options = {})
        raise ArgumentError, 'Option :db is required' unless db = options.delete(:db)
        table = options.delete(:table) || :moneta
        @db = ::Sequel.connect(db, options)
        @db.create_table?(table) do
          String :k, :null => false, :primary_key => true
          String :v
        end
        @table = @db[table]
      end

      # (see Proxy#key?)
      def key?(key, options = {})
        @table[:k => key] != nil
      end

      # (see Proxy#load)
      def load(key, options = {})
        record = @table[:k => key]
        record && record[:v]
      end

      # (see Proxy#store)
      def store(key, value, options = {})
        @db.transaction do
          if key?(key, options)
            @table.update(:k => key, :v => value)
          else
            @table.insert(:k => key, :v => value)
          end
          value
        end
      end

      # (see Proxy#increment)
      def increment(key, amount = 1, options = {})
        @db.transaction do
          locked_table = @table.for_update
          if record = locked_table[:k => key]
            value = convert_for_increment(record[:v]) + amount
            locked_table.update(:k => key, :v => value.to_s)
            value
          else
            locked_table.insert(:k => key, :v => amount.to_s)
            amount
          end
        end
      end

      # (see Proxy#delete)
      def delete(key, options = {})
        @db.transaction do
          if value = load(key, options)
            @table.filter(:k => key).delete
            value
          end
        end
      end

      # (see Proxy#clear)
      def clear(options = {})
        @table.delete
        self
      end
    end
  end
end
