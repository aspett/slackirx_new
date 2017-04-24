defmodule Relay.Application do
  require IEx
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # Define workers and child supervisors to be supervised
    import Supervisor.Spec

    # IEx.pry

    children =
      case Mix.env do
        :dev ->
          [
            worker(Relay.Registry.Pipelines, []),
            worker(Relay.Registry.Locations, []),
            worker(Relay.PipelineSupervisor, [])
          ]
         _ -> []
      end

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Relay.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
