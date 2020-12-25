defmodule Camera do
  use GenServer

  defmodule Attributes do
    defstruct ~w|name url password port username id|a
  end

  def start_link(state \\ %Attributes{} ) do
    GenServer.start_link(__MODULE__, %Attributes{state | id: make_ref()})
  end

  def init(state) do
    {:ok, state}
  end

  def details(pid) do
    GenServer.call(pid, :get)
  end

  def update(pid, map) do
    GenServer.cast(pid, {:save, map})
  end

  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:save, map}, state) do
    {:noreply, Map.merge(map, state)}
  end
end
