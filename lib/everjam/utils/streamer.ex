defmodule Streamer do
  def start(camera_name) do
    camera = Everjam.get_camera_from_bank(camera_name) |> IO.inspect()
    DynamicSupervisor.start_child(Recording.Supervisor, {Recording.Worker, %{id: String.to_atom(camera_name), camera: camera, sleep: 1000}}) |> IO.inspect()
  end
end

# Registry.lookup(Everjam.PubSub, "stream:throbbing-fire")
