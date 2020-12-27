defmodule Everjam do
  def cameras() do
    CamBank.start_link()
    |> case do
      {:error, {:already_started, cam_bank}} ->
        CamBank.all(cam_bank)
        |> Enum.map(fn(cam_pid) -> Camera.details(cam_pid) end) |> IO.inspect()
      {:ok, _cam_bank} -> []
    end
  end
end
