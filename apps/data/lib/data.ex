defmodule Data do
  @doc "Load all pipelines from the database, and cache them by location id"
  @spec load_pipelines() :: [Data.Pipeline.t]
  def load_pipelines() do
    Data.Repo.all(Data.Pipeline)
    |> Data.Repo.preload([source: [:source_pipeline, :destination_pipeline], destination: [:source_pipeline, :destination_pipeline]])
    |> Data.Cache.cache_pipeline_lookups()
  end

  @doc "Retrieve the pipeline for a given location"
  @spec pipeline_for_location(Data.Location.t) :: Data.Pipeline.t | nil
  def pipeline_for_location(location)
  def pipeline_for_location(%Data.Location{} = location) do
    case Data.Cache.pipeline_for_location(location) do
      %Data.Pipeline{} = pipeline -> pipeline
      _                           -> location |> Data.Location.get_pipeline()
    end
  end
end
