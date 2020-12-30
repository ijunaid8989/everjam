defmodule Recording.WorkerStarter do
  use GenServer

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
    ping_time_state = Map.put(state, :running, %{datetime: DateTime.utc_now()}) |> IO.inspect
    DynamicSupervisor.start_child(General.Supervisor, {Recording.Worker, ping_time_state})
    {:noreply, ping_time_state}
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

  defp schedule_fetch_call(sleep) do
    Process.send_after(self(), :request, sleep)
  end
end
