defmodule Everjam.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      EverjamWeb.Telemetry,
      {Phoenix.PubSub, name: Everjam.PubSub},
      EverjamWeb.Endpoint,
      {Finch, name: Everjamer},
      {DynamicSupervisor, strategy: :one_for_one, name: Recording.Supervisor}
    ]

    opts = [strategy: :one_for_one, name: Everjam.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    EverjamWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
