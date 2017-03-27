defmodule Relay.LocationService.Supervisor do
  alias Relay.Location
  alias Relay.LocationService

  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    {:ok, irc_client} = ExIrc.start_client!

    children = get_children(irc_client)

    # IO.inspect(children)

    supervise(children, strategy: :one_for_one)
  end

  def get_children(irc_client \\ %{}) do
    Relay.Repo.all
    |> Enum.map(&children_for_pipeline(&1, irc_client))
    |> List.flatten
  end

  defp children_for_pipeline(%Location.Pipeline{type: :dual, source: source, destination: destination}, irc_client) do
    [source, destination] |> Enum.map(&child_for_location(&1, irc_client))
  end

  defp child_for_location(%Location.Slack{token: token}, _irc_client) do
    [worker(Slack.Bot, [LocationService.Slack, [], token, %{name: :slack}])]
  end

  defp child_for_location(location = %Location.Irc{}, irc_client) do
    alias LocationService.Irc.ConnectionHandler

    state = %ConnectionHandler.State{
      host: location.server,
      port: location.port,
      pass: "",
      nick: location.bot_name,
      user: location.bot_name,
      name: location.bot_name
    }

    [worker(ConnectionHandler, [irc_client, state])]
  end
end
