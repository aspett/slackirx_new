defmodule Relay.LocationService.Irc.Supervisor do
  use Supervisor

  alias Relay.LocationService.Irc.{ConnectionHandler, EventHandler, DispatchHandler}

  @moduledoc """
  Supervisor that starts up and supervises a Relay.Location.Irc location.
  """

  @doc "Starts the supervisor"
  @spec start_link(Data.Location.t) :: {:ok, pid}
  def start_link(location = %Data.Location{type: "irc"}) do
    Supervisor.start_link(__MODULE__, location, name: supervisor_name(location))
  end

  @doc false
  @spec init(Data.Location.t) :: {:ok, pid}
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

    start_monitor(location, self())
    supervise(children, strategy: :one_for_all)
  end

  @doc "Dispatches the passed `event` to the DispatchHandler this supervisor supervises."
  @spec dispatch(Data.Location.t, pid, Relay.Dispatch.event) :: :ok
  def dispatch(%Data.Location{type: "irc"}, dispatch_pid, event) when is_pid(dispatch_pid) do
    {_, pid, _, _} = Supervisor.which_children(dispatch_pid)
    |> Enum.find(fn {id, _, :worker, _} -> id == Relay.LocationService.Irc.DispatchHandler end)
    Relay.LocationService.Irc.DispatchHandler.dispatch(pid, { :message, event })
  end

  @doc """
  Starts a process that monitors this supervisor, and deregisters the location from the Relay.Registry.Locations when
  it dies.
  """
  @spec start_monitor(Data.Location.t, pid) :: {:ok, pid}
  def start_monitor(location, supervisor_pid) do
    Relay.ProcessMonitor.start(self(), fn -> Relay.Registry.Locations.deregister_location(location, supervisor_pid) end)
  end

  @doc false
  defp supervisor_name(%Data.Location{type: "irc", id: id}) do
    :"Irc.Supervisor.#{id}"
  end

  @doc false
  defp child_name(location, child_descriptor) do
    :"#{supervisor_name(location)}.#{child_descriptor}"
  end
end
