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

  # vv query from fun2ms
  # [{{%{source: %{id: :"$1"}}, :"$2"}, [{:andalso, {:==, :"$1", 1}, {:is_pid, :"$2"}}], [:"$_"]}]
  # def find_pipeline do
  # end
end