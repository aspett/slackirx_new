defmodule Relay.Application do
  require IEx
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    # Define workers and child supervisors to be supervised

    {:ok, client} = ExIrc.start_client!
    Process.register(client, :exirc_client)

    # IEx.pry

    children = [
      # Starts a worker by calling: Relay.Worker.start_link(arg1, arg2, arg3)
      # worker(Relay.Worker, [arg1, arg2, arg3]),
      # worker(Relay.Dispatch, []),
      # worker(Slack.Bot, [Relay.Slack, [], Application.get_env(:relay, :slack_token), %{name: :slack}]),
      # worker(Relay.Irc.EventHandler, [client]),
      # worker(Relay.Irc.ConnectionHandler, [client]),
      # worker(Relay.Irc.DispatchHandler, [client]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Relay.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
