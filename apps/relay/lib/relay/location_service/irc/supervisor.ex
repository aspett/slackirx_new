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
      name: location.bot_name,
      channel: location.channel
    }

    irc_client = child_name(location, :irc_client)

    children = [
      worker(ExIrc.Client,      [[],                           [name: irc_client]]),
      worker(ConnectionHandler, [irc_client, state,            [name: child_name(location, :connection_handler)]]),
      worker(EventHandler,      [irc_client, location,         [name: child_name(location, :event_handler)]]),
      worker(DispatchHandler,   [irc_client, location.channel, [name: child_name(location, :dispatch_handler)]])
    ]

    :ok = Relay.Registry.Locations.register_location(location, self())

    start_monitor(location)
    supervise(children, strategy: :one_for_all)
  end

  def start_monitor(location) do
    Relay.ProcessMonitor.start(self(), fn -> Relay.Registry.Locations.deregister_location(location) end)
  end

  def supervisor_name(%Relay.Location.Irc{id: id}) do
    :"Irc.Supervisor.#{id}"
  end

  def child_name(location, child_descriptor) do
    :"#{supervisor_name(location)}.#{child_descriptor}"
  end

  # def irc_client_name(location = %Relay.Location.Irc{}) do
  #   :"#{supervisor_name(location)}.irc_client"
  # end

  def dispatch(%Relay.Location.Irc{}, dispatch_pid, event) when is_pid(dispatch_pid) do
    {_, pid, _, _} = Supervisor.which_children(dispatch_pid)
                     |> Enum.find(fn {id, _, :worker, _} -> id == Relay.LocationService.Irc.DispatchHandler end)
    Relay.LocationService.Irc.DispatchHandler.dispatch(pid, { :message, event })
  end
end
