defmodule Relay.LocationService.Irc.Supervisor do
  use Supervisor

  alias Relay.LocationService.Irc.{ConnectionHandler, EventHandler, DispatchHandler}

  def start_link(location = %Relay.Location.Irc{}) do
    Supervisor.start_link(__MODULE__, location, name: supervisor_name(location))
  end

  def init(location) do
    state = %ConnectionHandler.State{
      host: location.server,
      port: location.port,
      pass: "",
      nick: location.bot_name,
      user: location.bot_name,
      name: location.bot_name
    }

    irc_client = irc_client_name(location)

    children = [
      worker(ExIrc.Client, [[], [name: irc_client]]),
      worker(ConnectionHandler, [irc_client, state]),
      worker(EventHandler, [irc_client]),
      worker(DispatchHandler, [irc_client, location.channel])
    ]

    supervise(children, strategy: :one_for_all)
  end

  def supervisor_name(%Relay.Location.Irc{id: id}) do
    :"Irc.Supervisor.#{id}"
  end

  def irc_client_name(location = %Relay.Location.Irc{}) do
    :"#{supervisor_name(location)}.irc_client"
  end
end
