defmodule Everjam.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      EverjamWeb.Telemetry,
      {Phoenix.PubSub, name: Everjam.PubSub},
      {ConCache,
       [ttl_check_interval: :timer.seconds(0.1), global_ttl: :timer.seconds(2.5), name: :cache]},
      Supervisor.child_spec(
        {ConCache,
         [
           ttl_check_interval: :timer.seconds(0.1),
           global_ttl: :timer.minutes(1),
           name: :camera_lock
         ]},
        id: :camera_lock
      ),
      Supervisor.child_spec(
        {ConCache,
         [
           ttl_check_interval: :timer.seconds(1),
           global_ttl: :timer.hours(1),
           name: :do_camera_request
         ]},
        id: :do_camera_request
      ),
      EverjamWeb.Endpoint,
      {Finch, name: Everjamer},
      {DynamicSupervisor, strategy: :one_for_one, name: General.Supervisor}
    ]

    opts = [strategy: :one_for_one, name: Everjam.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    EverjamWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
