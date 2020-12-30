defmodule Recording.Worker do
  use GenServer
  require Logger

  def start_link(opts) do
    {id, opts} = Map.pop!(opts, :id)
    GenServer.start_link(__MODULE__, opts, name: id)
  end

  def init(state) do
    schedule_fetch_call(state.sleep)
    {:ok, state}
  end

  def handle_info(:jpeg_fetch, state) do
    schedule_fetch_call(state.sleep)
    {for_jpeg_bank, running} =
      make_jpeg_request(state.camera)
      |> running_map()

    IO.inspect("request")
    IO.inspect(DateTime.utc_now())
    put_it_in_jpeg_bank(for_jpeg_bank, state.camera.name)
    {:noreply, Map.put(state, :running, running)}
  end

  def get_state(pid) do
    GenServer.call(pid, :get)
  end

  def handle_call(:get, _from, state),
    do: {:reply, state, state}

  defp schedule_fetch_call(sleep),
    do: Process.send_after(self(), :jpeg_fetch, sleep)

  defp make_jpeg_request(camera) do
    headers = get_request_headers(camera.auth, camera.username, camera.password)
    requested_at = DateTime.utc_now()
    Everjamer.request(:get, camera.url, headers)
    |> get_body_size(requested_at)
  end

  defp get_body_size({:ok, %Finch.Response{body: body, headers: headers, status: 200}}, requested_at) do
    IO.inspect(headers)
    {body, "9", requested_at}
  end

  defp get_body_size(_error, requested_at), do: {:failed, requested_at}

  defp running_map({body, file_size, requested_at}),
    do:
      {%{datetime: requested_at, image: body, file_size: file_size},
       %{datetime: requested_at}}

  defp running_map({:failed, requested_at}), do: {%{}, %{datetime: requested_at}}

  defp get_request_headers("true", username, password),
    do: [{"Authorization", "Basic #{Base.encode64("#{username}:#{password}")}"}]

  defp get_request_headers(_, _username, _password), do: []

  defp put_it_in_jpeg_bank(state, process) do
    String.to_atom("storage_#{process}")
    |> Process.whereis()
    |> JpegBank.add(state)
  end
end
