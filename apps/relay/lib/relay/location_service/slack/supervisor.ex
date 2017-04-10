defmodule Relay.LocationService.Slack.Supervisor do
  use Supervisor

  def start_link(location = %Relay.Location.Slack{}) do
    Supervisor.start_link(__MODULE__, location, name: supervisor_name(location))
  end

  def init(location) do
    children = [
      worker(Slack.Bot, [Relay.LocationService.Slack, [], location.token, %{name: client_name(location)}])
    ]

    :ok = Relay.Registry.Locations.register_location(location, self(), client_name(location))

    start_monitor(location)
    supervise(children, strategy: :one_for_one)
  end

  def start_monitor(location) do
    Relay.ProcessMonitor.start(self(), fn -> Relay.Registry.Locations.deregister_location(location) end)
  end

  def supervisor_name(%Relay.Location.Slack{id: id}) do
    :"Slack.Supervisor.#{id}"
  end

  def client_name(location = %Relay.Location.Slack{id: id}) do
    :"#{supervisor_name(location)}.slack_client"
  end

  def dispatch(location = %Relay.Location.Slack{}, dispatch_pid, event = %{}) when is_pid(dispatch_pid) do
    {_, pid, _, _} = Supervisor.which_children(dispatch_pid)
                     |> Enum.find(fn {id, _, :worker, _} -> id == Slack.Bot end)

    send pid, { :message, event }
  end
end