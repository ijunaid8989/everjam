defmodule Central.FetchMeJpeg do
  def request(camera, requested_at) do
    headers = get_request_headers(camera.auth, camera.username, camera.password)

    Everjamer.request(:get, camera.url, headers)
    |> get_body_size(requested_at)
  end

  defp get_body_size({:ok, %Finch.Response{body: body, status: 200}}, requested_at) do
    {:ok, body, requested_at}
  end

  defp get_body_size(_error, requested_at), do: {:failed, requested_at}

  defp get_request_headers("true", username, password),
    do: [{"Authorization", "Basic #{Base.encode64("#{username}:#{password}")}"}]

  defp get_request_headers(_, _username, _password), do: []
end
