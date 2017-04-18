defmodule Relay.LocationService.Slack.Supervisor do
  use Supervisor

  @moduledoc """
  Supervises the Slack client and monitoring process
  """

  @doc "Start the supervisor process which will automatically start it's children"
  @spec start_link(Relay.Location.t) :: {:ok, pid}
  def start_link(location)
  def start_link(location = %Relay.Location.Slack{}) do
    Supervisor.start_link(__MODULE__, location, name: supervisor_name(location))
  end

  @doc false
  def init(location) do
    supervisor_pid = self()

    children = [
      worker(Slack.Bot, [Relay.LocationService.Slack, [], location.token, %{name: child_name(location, :slack_client)}]),
      worker(Task, [fn -> send child_name(location, :slack_client), { :start_monitor, supervisor_pid } end], [restart: :temporary])
    ]

    :ok = Relay.Registry.Locations.register_location(location, self(), child_name(location, :slack_client))
    start_monitor(location, self(), child_name(location, :slack_client))

    supervise(children, strategy: :one_for_all)
  end

  @doc false
  def start_monitor(location, sup_pid, client_pid) do
    {:ok, _} = Relay.ProcessMonitor.start(self(), fn -> Relay.Registry.Locations.deregister_location(location, sup_pid, client_pid) end)
  end

  @doc false
  def supervisor_name(%Relay.Location.Slack{id: id}) do
    :"Slack.Supervisor.#{id}"
  end

  @doc false
  def child_name(location, child_descriptor) do
    :"#{supervisor_name(location)}.#{child_descriptor}"
  end

  @doc "Dispatch a event to the Slack client"
  @spec dispatch(%Relay.Location.Slack{}, pid, Relay.Dispatch.event) :: :ok
  def dispatch(location, dispatch_pid, event)
  def dispatch(location = %Relay.Location.Slack{}, dispatch_pid, event = %{}) when is_pid(dispatch_pid) do
    {_, pid, _, _} = Supervisor.which_children(dispatch_pid)
                     |> Enum.find(fn {id, _, :worker, _} -> id == Slack.Bot end)

    send pid, { :message, event }
    :ok
  end
end