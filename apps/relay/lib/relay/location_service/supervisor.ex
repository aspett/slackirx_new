defmodule Relay.LocationService.Supervisor do
  alias Relay.Location
  alias Relay.LocationService

  use Supervisor

  def start_link(pipeline) do
    Supervisor.start_link(__MODULE__, pipeline, name: supervisor_name(pipeline))
  end

  def init(pipeline) do
    {:ok, _} = Relay.Registry.Pipelines.register_pipeline(pipeline, self())

    start_monitor(pipeline)
    supervise(get_children(pipeline), strategy: :one_for_one)
  end

  def start_monitor(pipeline) do
    Relay.ProcessMonitor.start(self(), fn -> Relay.Registry.Pipelines.deregister_pipeline(pipeline) end)
  end

  def get_children(pipeline) do
    pipeline
    |> children_for_pipeline()
    |> List.flatten()
  end

  defp children_for_pipeline(%Location.Pipeline{type: :dual, source: source, destination: destination}) do
    [source, destination] |> Enum.map(&child_for_location/1)
  end

  defp child_for_location(location = %Location.Slack{}) do
    [worker(Relay.LocationService.Slack.Supervisor, [location])]
  end

  defp child_for_location(location = %Location.Irc{}) do
    [worker(LocationService.Irc.Supervisor, [location])]
  end

  defp supervisor_name(pipeline) do
    :"LocationService.Supervisor.#{pipeline.pipe_id}"
  end
end
