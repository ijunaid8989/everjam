defmodule Broadcasting do
  def stream(camera_name, image, timestamp) do
    EverjamWeb.Endpoint.broadcast(
      "stream:" <> camera_name,
      "new_image",
      %{
        image: Base.encode64(image),
        timestamp: timestamp,
        camera_name: camera_name
      }
    )
  end

  def any_one_wacthing?(camera_name) do
    Registry.lookup(Everjam.PubSub, "stream:#{camera_name}")
    |> Enum.count()
    |> case do
      0 -> false
      _ -> true
    end
  end
end
