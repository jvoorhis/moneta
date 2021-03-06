require 'dm-core'
require 'dm-migrations'

module Moneta
  module Adapters
    # Datamapper backend
    # @api public
    class DataMapper
      include Defaults

      class Store
        include ::DataMapper::Resource
        property :k, Text, :key => true
        property :v, Text, :lazy => false
      end

      # @param [Hash] options
      # @option options [String] :setup Datamapper setup string
      # @option options [String/Symbol] :repository (:moneta) Repository name
      # @option options [String/Symbol] :table (:moneta) Table name
      def initialize(options = {})
        raise ArgumentError, 'Option :setup is required' unless options[:setup]
        @repository = (options.delete(:repository) || :moneta).to_sym
        Store.storage_names[@repository] = (options.delete(:table) || :moneta).to_s
        ::DataMapper.setup(@repository, options[:setup])
        context { Store.auto_upgrade! }
      end

      # (see Proxy#key?)
      def key?(key, options = {})
        context { Store.get(key) != nil }
      end

      # (see Proxy#load)
      def load(key, options = {})
        context do
          record = Store.get(key)
          record && record.v
        end
      end

      # (see Proxy#store)
      def store(key, value, options = {})
        context do
          if record = Store.get(key)
            record.update(:k => key, :v => value)
          else
            Store.create(:k => key, :v => value)
          end
          value
        end
      end

      # (see Proxy#delete)
      def delete(key, options = {})
        context do
          if record = Store.get(key)
            value = record.v
            record.destroy!
            value
          end
        end
      end

      # (see Proxy#clear)
      def clear(options = {})
        context { Store.all.destroy! }
        self
      end

      private

      def context
        ::DataMapper.repository(@repository) { yield }
      end
    end
  end
end
