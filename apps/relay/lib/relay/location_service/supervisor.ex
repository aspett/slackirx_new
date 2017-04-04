defmodule Relay.LocationService.Supervisor do
  alias Relay.Location
  alias Relay.LocationService

  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    children = get_children()

    # IO.inspect(children)

    supervise(children, strategy: :one_for_one)
  end

  def get_children() do
    Relay.Repo.all
    |> Enum.map(&children_for_pipeline/1)
    |> List.flatten
  end

  defp children_for_pipeline(%Location.Pipeline{type: :dual, source: source, destination: destination}) do
    [source, destination] |> Enum.map(&child_for_location/1)
  end

  defp child_for_location(%Location.Slack{token: token}) do
    [worker(Slack.Bot, [LocationService.Slack, [], token, %{name: :slack}])]
  end

  defp child_for_location(location = %Location.Irc{}) do
    [worker(LocationService.Irc.Supervisor, [location])]
  end
end
