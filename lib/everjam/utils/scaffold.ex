defmodule Scaffold do
  @moduledoc false

  defmacro __using__(opts) do
    quote generated: true, location: :keep do
      use GenServer

      defmodule Attributes, do: defstruct(unquote(opts))

      def start_link(state \\ %Attributes{}) do
        GenServer.start_link(
          __MODULE__,
          %Attributes{state | id: make_ref()}
        )
      end

      def init(state), do: {:ok, state}

      def details(pid),
        do: GenServer.call(pid, :get)

      def update(pid, map),
        do: GenServer.cast(pid, {:update, map})

      def handle_call(:get, _from, state),
        do: {:reply, state, state}

      def handle_cast({:update, map}, state),
        do: {:noreply, Map.merge(map, state)}
    end
  end
end
