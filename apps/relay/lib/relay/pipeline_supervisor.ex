defmodule Relay.PipelineSupervisor do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    get_pipelines()
    |> Enum.map(&supervisor_for_pipeline/1)
    |> supervise(strategy: :one_for_one)
  end

  defp get_pipelines() do
    Relay.Repo.all(Relay.Location.Pipeline)
  end

  def supervisor_for_pipeline(pipeline = %Relay.Location.Pipeline{}) do
    supervisor(Relay.LocationService.Supervisor, [pipeline], [id: pipeline.pipe_id])
  end
end