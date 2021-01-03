defmodule Everjamer do
  def request(method, url, headers \\ [], body \\ nil, opts \\ []) do
    Finch.build(method, url, headers, body)
    |> Finch.request(__MODULE__, opts)
    |> case do
      {:ok, %Finch.Response{} = response} ->
        {:ok, response}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def post(file_path, url, image) do
    multipart =
      Multipart.new()
      |> Multipart.add_file_content(image, file_path, headers: [{"content-type", "image/jpeg"}])

    headers = Multipart.headers(multipart)
    body = Multipart.body(multipart)

    request(
      :post,
      url <> file_path,
      headers,
      {:stream, body}
    )
  end
end
