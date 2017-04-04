defmodule Relay.LocationService.Irc.Supervisor do
  use Supervisor

  alias Relay.LocationService.Irc.{ConnectionHandler, EventHandler, DispatchHandler}

  def start_link(location = %Relay.Location.Irc{}) do
    state = %ConnectionHandler.State{
      host: location.server,
      port: location.port,
      pass: "",
      nick: location.bot_name,
      user: location.bot_name,
      name: location.bot_name
    }

    Supervisor.start_link(__MODULE__, state)
  end

  def init(state = %ConnectionHandler.State{}) do
    {:ok, irc_client} = ExIrc.Client.start!

    children = [
      worker(ConnectionHandler, [irc_client, state]),
      worker(EventHandler, [irc_client]),
      worker(DispatchHandler, [irc_client])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
