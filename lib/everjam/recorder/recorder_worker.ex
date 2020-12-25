defmodule Recording.Worker do
  use GenServer

  def start_link(opts) do
    {id, opts} = Map.pop!(opts, :id)
    GenServer.start_link(__MODULE__, opts, name: id)
  end

  def init(state) do
    schedule_fetch_call(state.sleep)
    {:ok, state}
  end

  def handle_info(:jpeg_fetch, state) do
    schedule_fetch_call(state.sleep)
    {:noreply, Map.put(state, :run, {DateTime.utc_now(), %{}})}
  end

  defp schedule_fetch_call(sleep),
    do: Process.send_after(self(), :jpeg_fetch, sleep)
end
