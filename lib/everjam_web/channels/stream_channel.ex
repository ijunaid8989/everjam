defmodule EverjamWeb.StreamChannel do
  use EverjamWeb, :channel

  @impl true
  def join("stream:" <> camera_name, _payload, socket) do
    IO.inspect("User Joined")
    send(self(), {:after_join, camera_name})
    {:ok, socket}
  end

  @impl true
  def handle_info({:after_join, camera_name}, socket) do
    # start streaming
    Streamer.start(camera_name)
    IO.inspect(camera_name)
    {:noreply, socket}
  end
end
