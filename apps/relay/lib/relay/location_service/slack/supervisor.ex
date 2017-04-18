defmodule Relay.LocationService.Slack.Supervisor do
  use Supervisor

  def start_link(location = %Relay.Location.Slack{}) do
    Supervisor.start_link(__MODULE__, location, name: supervisor_name(location))
  end

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

  def start_monitor(location, sup_pid, client_pid) do
    {:ok, _} = Relay.ProcessMonitor.start(self(), fn -> Relay.Registry.Locations.deregister_location(location, sup_pid, client_pid) end)
  end

  def supervisor_name(%Relay.Location.Slack{id: id}) do
    :"Slack.Supervisor.#{id}"
  end

  def child_name(location, child_descriptor) do
    :"#{supervisor_name(location)}.#{child_descriptor}"
  end

  def dispatch(location = %Relay.Location.Slack{}, dispatch_pid, event = %{}) when is_pid(dispatch_pid) do
    {_, pid, _, _} = Supervisor.which_children(dispatch_pid)
                     |> Enum.find(fn {id, _, :worker, _} -> id == Slack.Bot end)

    send pid, { :message, event }
  end
end