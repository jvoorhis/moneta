# Generated by generate-specs
require 'helper'

describe_moneta "cache_memory_null" do
  def log
    @log ||= File.open(File.join(make_tempdir, 'cache_memory_null.log'), 'a')
  end

  def new_store
    Moneta.build do
      use(:Cache) do
        backend(Moneta::Adapters::Memory.new)
        cache(Moneta::Adapters::Null.new)
      end
    end
  end

  def load_value(value)
    Marshal.load(value)
  end

  include_context 'setup_store'
  it_should_behave_like 'increment'
  it_should_behave_like 'not_persist'
  it_should_behave_like 'null_stringkey_stringvalue'
  it_should_behave_like 'returnsame_stringkey_stringvalue'
  it_should_behave_like 'store_stringkey_stringvalue'
end
