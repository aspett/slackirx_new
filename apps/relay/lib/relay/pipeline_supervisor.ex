defmodule Relay.PipelineSupervisor do
  use Supervisor

  alias Data.Pipeline

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

  @doc "Dynamically starts and supervises a pipeline's supervision tree"
  @spec start_pipeline(%Pipeline{}) :: {:ok, pid}
  def start_pipeline(pipeline)
  def start_pipeline(pipeline = %Pipeline{}) do
    {:ok, pid} = Supervisor.start_child(__MODULE__, supervisor_for_pipeline(pipeline))
  end

  @doc "Stops a pipeline's supervision tree, and removes it from this supervisor"
  @spec stop_pipeline(%Pipeline{}) :: {:ok, term}
  def stop_pipeline(pipeline)
  def stop_pipeline(pipeline = %Pipeline{}) do
    {^pipeline, pid} = Relay.Registry.Pipelines.find_by_pipeline(pipeline)

    {child_id, _, _, _} =
      Supervisor.which_children(__MODULE__)
      |> Enum.find(fn {_, child_pid, _, _} -> child_pid == pid end)

    Supervisor.terminate_child(__MODULE__, child_id)
    Supervisor.delete_child(__MODULE__, child_id)

    {:ok, child_id}
  end

  @doc false
  defp get_pipelines() do
    Data.load_pipelines()
  end

  @doc false
  defp supervisor_for_pipeline(pipeline = %Pipeline{}) do
    supervisor(Relay.LocationService.Supervisor, [pipeline], [id: pipeline.id])
  end
end