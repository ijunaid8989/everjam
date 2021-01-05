defmodule Central.BroadcastMe do
  def push(camera_name, body, timestamp) do
    Broadcasting.any_one_wacthing?(camera_name)
    |> Broadcasting.stream(camera_name, body, timestamp)
  end
end
