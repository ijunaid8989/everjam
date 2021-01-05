defmodule CacheOps do
  def put(atom, name, boolean) do
    ConCache.put(atom, name, boolean)
  end

  def get(atom, name) do
    ConCache.get(atom, name)
  end
end
