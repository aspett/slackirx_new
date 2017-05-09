defmodule Data.Cache do
  @pipeline_lookup :location_pipelines

  def start_link() do
    Cachex.start_link(@pipeline_lookup, [])
  end

  def cache_pipeline_lookups(pipelines) do
    Cachex.clear(@pipeline_lookup)

    Enum.each(pipelines, fn pipeline ->
      Cachex.set!(@pipeline_lookup, pipeline.source.id, pipeline)
      Cachex.set!(@pipeline_lookup, pipeline.destination.id, pipeline)
    end)

    pipelines
  end

  def pipeline_for_location(location) do
    case Cachex.get(:location_pipelines, location.id) do
      {:ok, pipeline} -> pipeline
      _               -> nil
    end
  end
end