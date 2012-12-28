module Moneta
  # Adds expiration support to the underlying store
  #
  # `#store`, `#load` and `#key?` support the `:expires` option to set/update
  # the expiration time.
  #
  # @api public
  class Expires < Proxy
    include ExpiresSupport

    # @param [Moneta store] adapter The underlying store
    # @param [Hash] options
    # @option options [String] :expires Default expiration time
    def initialize(adapter, options = {})
      super
      self.default_expires = options[:expires]
    end

    # (see Proxy#key?)
    def key?(key, options = {})
      # Transformer might raise exception
      load_entry(key, options) != nil
    rescue Exception
      options.include?(:expires) && (options = options.dup; options.delete(:expires))
      super(key, options)
    end

    # (see Proxy#load)
    def load(key, options = {})
      return super if options.include?(:raw)
      value, expires = load_entry(key, options)
      value
    end

    # (see Proxy#load_multi)
    def load_multi(keys, options = {})
      return super if options.include?(:raw)
      now = Time.now.to_i
      new_expires = options.include?(:expires) && (options = options.dup; options.delete(:expires))
      new_expires += now if new_expires
      result = super(keys, options)
      delete = []
      store = {}
      result.each do |key, entry|
        next if entry == nil
        value, expires = entry
        if expires && now > expires
          delete << key
          result[key] = nil
        else
          store[key] = [value, new_expires] if new_expires
          result[key] = value
        end
      end
      @adapter.delete_multi(delete, options) unless delete.empty?
      @adapter.store_multi(store, options) unless store.empty?
      result
    end

    # (see Proxy#store)
    def store(key, value, options = {})
      return super if options.include?(:raw)
      expires = expires_at(options)
      if options.include?(:expires)
        options = options.dup
        options.delete(:expires)
      end
      store_entry(key, value, expires, options)
      value
    end

    # (see Proxy#store_multi)
    def store_multi(entries, options = {})
      return super if options.include?(:raw)
      expires = options.include?(:expires) && (options = options.dup; options.delete(:expires))
      if expires ||= @expires
        expires += Time.now.to_i
        e = {}
        entries.each {|key, value| e[key] = [value, expires] }
        super(e, options)
      else
        e = {}
        entries.each {|key, value| e[key] = Array === value || value == nil ? [value] : value }
        super(e, options)
      end
      entries
    end

    # (see Proxy#delete)
    def delete(key, options = {})
      return super if options.include?(:raw)
      value, expires = super
      value if !expires || Time.now.to_i <= expires
    end

    # (see Proxy#delete_multi)
    def delete_multi(keys, options = {})
      return super if options.include?(:raw)
      now = Time.now.to_i
      result = super(keys, options)
      result.each do |key, entry|
        next if entry == nil
        value, expires = entry
        if expires && now > expires
          result[key] = nil
        else
          result[key] = value
        end
      end
      result
    end

    private

    def load_entry(key, options)
      new_expires = expires_at(options, nil)
      if options.include?(:expires)
        options = options.dup
        options.delete(:expires)
      end
      entry = @adapter.load(key, options)
      if entry != nil
        value, expires = entry
        if expires && Time.now.to_i > expires
          delete(key)
          nil
        elsif new_expires != nil
          store_entry(key, value, new_expires, options)
          entry
        else
          entry
        end
      end
    end

    def store_entry(key, value, expires, options)
      entry =
        if expires
          [value, expires.to_i]
        elsif Array === value || value == nil
          [value]
        else
          value
        end
      @adapter.store(key, entry, options)
    end
  end
end
