defmodule General.Supervisor do
  use DynamicSupervisor

  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def start_child(module, opts),
    do: DynamicSupervisor.start_child(__MODULE__, {module, opts})

  @impl DynamicSupervisor
  def init(opts),
    do: DynamicSupervisor.init(strategy: :one_for_one, extra_arguments: [opts])
end
