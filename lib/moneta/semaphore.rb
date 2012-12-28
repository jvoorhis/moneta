module Moneta
  class Semaphore
    def initialize(store, counter, max = 1)
      @store, @counter, @max = store, counter, max
      @store.increment(@counter, 0) # Ensure that counter exists
    end

    def enter
      until @store.increment(@counter) <= @max
        @store.decrement(@counter)
        sleep 0.01
      end
    end

    def leave
      @store.decrement(@counter)
    end

    def synchronize
      enter
      yield
    ensure
      leave
    end
  end
end
