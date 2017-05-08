defmodule Relay.LocationService.Supervisor do
  use Supervisor

  @moduledoc """
  Supervises the supervisors for each location involved in a given pipeline
  """

  alias Data.{Location, Pipeline}
  alias Relay.LocationService

  @doc "Starts the supervision tree process for a given pipeline"
  @spec start_link(Data.Pipeline.t) :: {:ok, pid}
  def start_link(pipeline) do
    Supervisor.start_link(__MODULE__, pipeline, name: supervisor_name(pipeline))
  end

  @doc false
  def init(pipeline) do
    {:ok, _} = Relay.Registry.Pipelines.register_pipeline(pipeline, self())

    start_monitor(pipeline)
    supervise(get_children(pipeline), strategy: :one_for_one)
  end

  @doc false
  def start_monitor(pipeline) do
    Relay.ProcessMonitor.start(self(), fn -> Relay.Registry.Pipelines.deregister_pipeline(pipeline) end)
  end

  @doc "Returns a list of child specs for child processes that must be supervised for a given pipeline"
  @spec get_children(Data.Pipeline.t) :: [Supervisor.Spec.spec]
  def get_children(pipeline) do
    pipeline
    |> children_for_pipeline()
    |> List.flatten()
  end

  @doc false
  defp children_for_pipeline(%Pipeline{type: "dual", source: source, destination: destination}) do
    [source, destination] |> Enum.map(&child_for_location/1)
  end

  @doc false
  defp child_for_location(location = %Location{type: "slack"}) do
    [worker(Relay.LocationService.Slack.Supervisor, [location])]
  end

  @doc false
  defp child_for_location(location = %Location{type: "irc"}) do
    [worker(LocationService.Irc.Supervisor, [location])]
  end

  @doc false
  defp supervisor_name(pipeline) do
    :"LocationService.Supervisor.#{pipeline.id}"
  end
end
