defmodule Streamer.StreamStarter do
  use GenServer

  require Logger

  def start_link(opts) do
    IO.inspect("Started Streamer.StreamStarter")
    {id, opts} = Map.pop!(opts, :id)
    GenServer.start_link(__MODULE__, opts, name: id)
  end

  def init(state) do
    schedule_fetch_call(state.sleep)
    {:ok, state}
  end

  def handle_info(:stream, state) do
    case Broadcasting.any_one_wacthing?(state.camera.name) do
      true ->
        schedule_fetch_call(state.sleep)
        run_or_not(state)

      false ->
        stop_streaming(state)
    end

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

  defp put_streamer_to_rest(true, state) do
    stop_streaming(state)
  end

  defp put_streamer_to_rest(false, state) do
    Logger.debug("request for jpeg")
  end

  defp stop_streaming(state) do
    General.Supervisor.terminate(String.to_atom("#{state.camera.name <> "_streamer"}"))
  end

  defp schedule_fetch_call(sleep) do
    Process.send_after(self(), :stream, sleep)
  end
end
