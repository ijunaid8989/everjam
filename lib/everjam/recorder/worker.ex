defmodule Recording.Worker do
  use GenServer, restart: :transient
  require Logger

  alias Central.{BroadcastMe, FetchMeJpeg, SeaweedMe}

  def start_link(state),
    do: GenServer.start_link(__MODULE__, state)

  def init(state) do
    send(self(), :fetch_and_process)
    {:ok, state}
  end

  def handle_info(:fetch_and_process, state) do
    case FetchMeJpeg.request(state.camera, state.running.datetime) do
      {:failed, _requested_at} ->
        ConCache.put(:do_camera_request, state.camera.name, true)
        {:stop, :shutdown, state}

      {:ok, body, requested_at} ->
        SeaweedMe.post(state.camera.name, body, requested_at)

        BroadcastMe.push(state.camera.name, body, requested_at)

        ConCache.put(:do_camera_request, state.camera.name, true)
        {:stop, :normal, state}
    end
  end

  def terminate(me, _state) do
    Logger.debug("I am terminated as #{me}")
  end
end
