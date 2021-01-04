defmodule Recording.WorkerStarter do
  use GenServer

  require Logger

  def start_link(opts) do
    IO.inspect("Started Recording.WorkerStarter")
    {id, opts} = Map.pop!(opts, :id)
    GenServer.start_link(__MODULE__, opts, name: id)
  end

  def init(state) do
    schedule_fetch_call(state.sleep)
    {:ok, state}
  end

  def handle_info(:request, state) do
    schedule_fetch_call(state.sleep)
    ping_time_state = Map.put(state, :running, %{datetime: DateTime.utc_now(), worker: true})

    ConCache.get(:do_camera_request, state.camera.name)
    |> shoot_a_request(ping_time_state, Recording.Worker)

    {:noreply, ping_time_state}
  end

  def shoot_a_request(true, state, worker) do
    ConCache.put(:do_camera_request, state.camera.name, false)
    DynamicSupervisor.start_child(General.Supervisor, {worker, state})
  end

  def shoot_a_request(false, _state, _worker) do
    Logger.debug("Don't send a request.")
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

  def am_running?(nil), do: false

  def am_running?(pid) do
    %{
      running: %{worker: running}
    } = GenServer.call(pid, :get)

    running
  end

  defp schedule_fetch_call(sleep) do
    Process.send_after(self(), :request, sleep)
  end
end
