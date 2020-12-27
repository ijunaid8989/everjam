defmodule CamBank do
  use GenServer

  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(state) do
    {:ok, state}
  end

  def all(pid) do
    GenServer.call(pid, :get)
  end

  def add(pid, map) do
    GenServer.cast(pid, {:add, map})
  end

  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:add, pid}, state) do
    {:noreply, [pid | state]}
  end
end
