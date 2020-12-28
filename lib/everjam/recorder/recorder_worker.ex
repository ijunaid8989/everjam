defmodule Recording.Worker do
  use GenServer
  require Logger

  def start_link(opts) do
    {id, opts} = Map.pop!(opts, :id)
    GenServer.start_link(__MODULE__, opts, name: id)
  end

  def init(state) do
    IO.inspect(state)
    IO.inspect("In worker")
    schedule_fetch_call()
    {:ok, state}
  end

  def handle_info(:jpeg_fetch, state) do
    IO.inspect(state)
    any_one_wacthing?(state.camera.name)
    |> case do
      true -> EverjamWeb.Endpoint.broadcast!("stream:" <> state.camera.name, "new_msg", %{time: DateTime.utc_now()})
      _ -> Logger.debug("Shuting down the streamer.")
    end
    schedule_fetch_call()
    {:noreply, Map.put(state, :run, {DateTime.utc_now(), %{}})}
  end

  defp schedule_fetch_call(),
    do: Process.send_after(self(), :jpeg_fetch, 1000)

  def any_one_wacthing?(camera_name) do
    Registry.lookup(Everjam.PubSub, "stream:#{camera_name}")
    |> Enum.count()
    |> case do
      0 -> false
      _ -> true
    end
  end
end
