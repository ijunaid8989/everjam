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
    Everjam.get_camera_from_bank(camera_name)
    |> should_start()

    {:noreply, socket}
  end

  defp should_start(nil), do: :noop

  defp should_start(camera) do
    General.Supervisor.start_child(Streamer.StreamStarter, %{
      id: String.to_atom("#{camera.name <> "_streamer"}"),
      camera: camera,
      sleep: 1000,
      streaming: true
    })
    |> IO.inspect()
  end
end
