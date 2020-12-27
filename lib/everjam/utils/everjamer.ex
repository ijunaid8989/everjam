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
end
