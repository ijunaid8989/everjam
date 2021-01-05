defmodule Central.SeaweedMe do
  def post(camera_name, body, timestamp) do
    timestamp
    |> Calendar.strftime("#{camera_name}/snapshots/%Y/%m/%d/%H_%M_%S.jpg")
    |> Everjamer.post("http://localhost:8888/", body)
  end
end
