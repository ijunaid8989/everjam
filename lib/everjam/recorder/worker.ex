defmodule Recording.Worker do
  use GenServer, restart: :transient

  def start_link(state),
    do: GenServer.start_link(__MODULE__, state)

  def init(state) do
    send(self(), :fetch_and_process)
    {:ok, state}
  end

  def handle_info(:fetch_and_process, state) do
    case make_jpeg_request(state.camera, state.running.datetime) do
      {:failed, _requested_at} ->
        {:noreply, state}
      {body, file_size, requested_at} ->
        %{datetime: requested_at, image: body, file_size: file_size}
        |> put_it_in_jpeg_bank(state.camera.name)
        {:stop, :normal, state}
    end
  end

  defp make_jpeg_request(camera, requested_at) do
    headers = get_request_headers(camera.auth, camera.username, camera.password)
    Everjamer.request(:get, camera.url, headers)
    |> get_body_size(requested_at)
  end

  defp get_body_size({:ok, %Finch.Response{body: body, headers: _headers, status: 200}}, requested_at) do
    {body, "9", requested_at}
  end

  defp get_body_size(_error, requested_at), do: {:failed, requested_at}

  defp get_request_headers("true", username, password),
    do: [{"Authorization", "Basic #{Base.encode64("#{username}:#{password}")}"}]

  defp get_request_headers(_, _username, _password), do: []

  defp put_it_in_jpeg_bank(state, process) do
    String.to_atom("storage_#{process}")
    |> Process.whereis()
    |> JpegBank.add(state)
  end
end
