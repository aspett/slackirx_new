defmodule Data do
  def load_pipelines() do
    pipelines = Data.Repo.all(Data.Pipeline)
                |> Data.Repo.preload([source: [:source_pipeline, :destination_pipeline], destination: [:source_pipeline, :destination_pipeline]])

    cache_pipeline_lookups(pipelines)

    pipelines
  end

  def pipeline_for_location(%Data.Location{} = location, fresh_load \\ false) do
    case Cachex.get(:location_pipelines, location.id) do
      {:ok, pipeline} -> pipeline
      _               -> location |> Data.Location.get_pipeline()
    end
  end

  defp cache_pipeline_lookups(pipelines) do
    Cachex.clear(:location_pipelines)

    Enum.each(pipelines, fn pipeline ->
      Cachex.set!(:location_pipelines, pipeline.source.id, pipeline)
      Cachex.set!(:location_pipelines, pipeline.destination.id, pipeline)
    end)
  end
end
