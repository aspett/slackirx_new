defmodule Relay.Registry.Pipelines do
  use GenServer

  @moduledoc """
  Registry for registering pipelines to their supervisor pids
  """

  alias Data.{Location, Pipeline}

  @table :pipeline_registry

  @doc "Start the registry process"
  @spec start_link() :: {:ok, pid}
  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc false
  def init(:ok) do
    :ets.new(@table, [:named_table, :duplicate_bag])

    {:ok, nil}
  end

  @doc false
  def handle_call({:register_pipeline, pipeline, pid}, _from, _state) do
    :ets.insert(@table, { pipeline, pid })
    IO.puts("Register pipeline")

    {:reply, { :ok, pid }, nil}
  end

  @doc false
  def handle_call({:deregister_pipeline, pipeline}, _from, _state) do
    :ets.delete(@table, pipeline)
    IO.puts("Deregister pipeline")

    {:reply, :ok, nil}
  end

  @doc "Add an entry to the registry"
  @spec register_pipeline(Data.Pipeline.t, pid()) :: {:ok, pid()} | {:error, :invalid}
  def register_pipeline(pipeline, pid)
  def register_pipeline(pipeline = %Pipeline{type: "dual"}, pid) when is_pid(pid) do
    GenServer.call(__MODULE__, { :register_pipeline, pipeline, pid })
  end

  def register_pipeline(_, _) do
    { :error, :invalid }
  end

  @doc "Remove an entry from the registry"
  @spec deregister_pipeline(Data.Pipeline.t) :: :ok
  def deregister_pipeline(pipeline) do
    GenServer.call(__MODULE__, { :deregister_pipeline, pipeline })
  end

  @doc "Finds the entry of a pipeline and it's pid by pipeline"
  @spec find_by_pipeline(Data.Pipeline.t) :: { Data.Pipeline.t, pid }
  def find_by_pipeline(pipeline)
  def find_by_pipeline(pipeline = %Pipeline{id: id}) do
    query = [{{%{id: :"$1"}, :_}, [{:==, :"$1", id}], [:"$_"]}]
    [{pipeline, pid}] = :ets.select(@table, query)

    {pipeline, pid}
  end

  # def find_pipeline(locations = [_ | _]) do
  #   :ets.select(@table, query)
  # end

  # vv query from fun2ms
  #:ets.fun2ms(fn {%{source: %{id: source_id}, destination: %{id: destination_id}}, pid} when source_id == 1 or destination_id == 1 -> pid end)
  # [{{%{destination: %{id: :"$2"}, source: %{id: :"$1"}}, :"$3"}, [{:orelse, {:==, :"$1", 1}, {:==, :"$2", 1}}], [:"$3"]}]
  # [{{%{source: %{id: :"$1"}}, :"$2"}, [{:andalso, {:==, :"$1", 1}, {:is_pid, :"$2"}}], [:"$_"]}]
  # def find_pipeline do
  # end
end