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
    supervise(children, strategy: :one_for_one)
  end

  def supervisor_name(%Relay.Location.Slack{id: id}) do
    :"Slack.Supervisor.#{id}"
  end

  def client_name(location = %Relay.Location.Slack{id: id}) do
    :"#{supervisor_name(location)}.slack_client"
  end
end