defmodule Streamer.StreamStarter do
  use GenServer

  require Logger

  def start_link(opts) do
    IO.inspect("Started Streamer.StreamStarter")
    {id, opts} = Map.pop!(opts, :id)
    GenServer.start_link(__MODULE__, opts, name: id) |> IO.inspect()
  end

  def init(state) do
    schedule_fetch_call(state.sleep)
    {:ok, state}
  end

  def handle_info(:stream, state) do
    schedule_fetch_call(state.sleep)
    run_or_not(state)
    start_streaming(state.streaming, state)
    {:noreply, state}
  end

  def update_state(pid, state) do
    GenServer.cast(pid, {:update_state, state})
  end

  def handle_cast({:update_state, state}, _old_state) do
    {:noreply, state}
  end

  def get_state(pid) do
    GenServer.call(pid, :get)
  end

  def handle_call(:get, _from, state),
    do: {:reply, state, state}

  defp run_or_not(state) do
    Process.whereis(String.to_atom(state.camera.name))
    |> Recording.WorkerStarter.am_running?()
    |> put_streamer_to_rest(state)
  end

  defp put_streamer_to_rest(truthy, state) do
    Process.whereis(String.to_atom("#{state.camera.name <> "_streamer"}"))
    |> update_state(%{state | streaming: !truthy})
  end

  defp start_streaming(true, state) do
    Logger.debug("Stremaing")
  end

  defp start_streaming(false, state) do
    Logger.debug("Stremaing not")
  end

  defp schedule_fetch_call(sleep) do
    Process.send_after(self(), :stream, sleep)
  end
end
