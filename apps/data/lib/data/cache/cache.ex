defmodule Data.Cache do
  @pipeline_lookup :location_pipelines

  @moduledoc false

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    :ets.new(@pipeline_lookup, [:named_table, :set])

    {:ok, nil}
  end

  def cache_pipeline_lookups(pipelines) do
    :ok = GenServer.call(__MODULE__, { :cache_pipeline_lookups, pipelines })
    pipelines
  end

  def pipeline_for_location(location) do
    lookup = GenServer.call(__MODULE__, { :pipeline_for_location, location })

    case lookup do
      [pipeline | _] -> pipeline
      _              -> nil
    end
  end

  def handle_call({ :cache_pipeline_lookups, pipelines }, _from, _state) do
    :ets.delete_all_objects(@pipeline_lookup)

    Enum.each(pipelines, fn pipeline ->
      :ets.insert(@pipeline_lookup, { pipeline.source.id, pipeline })
      :ets.insert(@pipeline_lookup, { pipeline.destination.id, pipeline })
    end)

    { :reply, :ok, nil }
  end

  def handle_call({ :pipeline_for_location, location}, _from, _state) do
    result = :ets.lookup(@pipeline_lookup, location.id)

    {:reply, result, nil}
  end
end