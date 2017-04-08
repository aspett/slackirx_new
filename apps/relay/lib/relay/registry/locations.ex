defmodule Relay.Registry.Locations do
  use GenServer

  alias Relay.Location

  @table :location_registry

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    :ets.new(@table, [:named_table, :set])

    {:ok, nil}
  end

  def handle_call({:register_location, location, dispatch_pid, location_pid}, _from, _state) do
    :ets.insert(@table, { location, dispatch_pid, location_pid })

    {:reply, :ok, nil}
  end

  @spec register_location(%Relay.Location.Irc{} | %Relay.Location.Slack{}, pid(), pid() | nil) :: {:ok, pid()} | {:error, :invalid}
  def register_location(location, dispatch_pid, location_pid \\ nil)

  def register_location(location = %Location.Irc{}, dispatch_pid, location_pid) when is_pid(dispatch_pid) and (is_pid(location_pid) or is_nil(location_pid)) do
    GenServer.call(__MODULE__, { :register_location, location, dispatch_pid, nil })
  end

  def register_location(location = %Location.Slack{}, dispatch_pid, location_pid) when is_pid(dispatch_pid) and (is_pid(location_pid) or is_atom(location_pid)) do
    GenServer.call(__MODULE__, { :register_location, location, dispatch_pid, location_pid })
  end

  def register_location(_, _, _) do
    { :error, :invalid }
  end

  def find_by_location_pid(pid) when is_atom(pid) do
    find_by_location_pid(Process.whereis(pid))
  end

  def find_by_location_pid(pid) do
    [result] = :ets.match(@table, :"$1")
               |> Enum.find(fn [{location, dispatch_pid, location_pid}] -> Process.whereis(location_pid) == pid end)

    result
  end

  def find_dispatch_pid_by_location(location) do
    query = [{{%{__struct__: :"$1", id: :"$2"}, :"$3", :"$4"}, [{:andalso, {:==, :"$1", location.__struct__}, {:==, :"$2", location.id}}], [:"$3"]}]
    [pid] = :ets.select(@table, query)

    pid
  end
end
