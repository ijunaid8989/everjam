defmodule Bank do
  @moduledoc false

  defmacro __using__(_opts \\ []) do
    quote generated: true, location: :keep do
      use GenServer

      def start_link(name \\ __MODULE__) do
        GenServer.start_link(
          __MODULE__,
          [],
          name: name
        )
      end

      def init(state), do: {:ok, state}

      def all(pid),
        do: GenServer.call(pid, :get)

      def add(pid, cash),
        do: GenServer.cast(pid, {:add, cash})

      def handle_call(:get, _from, state),
        do: {:reply, state, state}

      def handle_cast({:add, cash}, state),
        do: {:noreply, [cash | state]}
    end
  end
end
