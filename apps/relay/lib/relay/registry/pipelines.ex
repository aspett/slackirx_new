defmodule Relay.Registry.Pipelines do
  use GenServer

  alias Relay.Location

  @table :pipeline_registry

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    :ets.new(@table, [:named_table, :duplicate_bag])

    {:ok, nil}
  end

  def handle_call({:register_pipeline, pipeline, pid}, _from, _state) do
    :ets.insert(@table, { pipeline, pid })

    {:reply, { :ok, pid }, nil}
  end

  @spec register_pipeline(%Relay.Location.Pipeline{}, pid()) :: {:ok, pid()} | {:error, :invalid}
  def register_pipeline(pipeline = %Location.Pipeline{type: :dual}, pid) when is_pid(pid) do
    GenServer.call(__MODULE__, { :register_pipeline, pipeline, pid })
  end

  def register_pipeline(_, _) do
    { :error, :invalid }
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