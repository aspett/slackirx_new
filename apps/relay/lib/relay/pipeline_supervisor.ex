defmodule Relay.PipelineSupervisor do
  use Supervisor

  @moduledoc """
  Supverises a child per pipeline
  """

  @doc "Starts the supervisor and children which will run each pipeline"
  @spec start_link() :: {:ok, pid}
  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc false
  def init([]) do
    get_pipelines()
    |> Enum.map(&supervisor_for_pipeline/1)
    |> supervise(strategy: :one_for_one)
  end

  @doc false
  defp get_pipelines() do
    Relay.Repo.all(Relay.Location.Pipeline)
  end

  @doc false
  defp supervisor_for_pipeline(pipeline = %Relay.Location.Pipeline{}) do
    supervisor(Relay.LocationService.Supervisor, [pipeline], [id: pipeline.pipe_id])
  end
end