defmodule Relay.LocationService.Irc.ConnectionHandler do
  @moduledoc """
  Handles connecting to the IRC client, and logging in the user
  """

  defmodule State do
    defstruct [:host, :port, :pass, :nick, :user, :name, :client, :channel]
  end

  @doc "Starts the process"
  @spec start_link(pid(), %State{}, list(any())) :: {:ok, pid()}
  def start_link(client, state, opts \\ []) do
    GenServer.start_link(__MODULE__, %{state | client: client}, opts)
  end

  @doc false
  def init(state) do
    ExIrc.Client.add_handler state.client, self()
    ExIrc.Client.connect! state.client, state.host, state.port
    {:ok, state}
  end

  @doc false
  def handle_info({:connected, server, port}, state) do
    debug "Connected to #{server}:#{port}"
    ExIrc.Client.logon state.client, state.pass, state.nick, state.user, state.name
    {:noreply, state}
  end

  @doc false
  def handle_info(:logged_in, state) do
    state
    |> autojoin_channels()
    |> Enum.each(fn channel ->
         ExIrc.Client.join(state.client, channel)
       end)

    {:noreply, state}
  end

  # Catch-all for messages you don't care about
  @doc false
  def handle_info(_msg, state) do
    # debug "Received unknown messsage:"
    # IO.inspect msg
    {:noreply, state}
  end

  defp autojoin_channels(state) do
    [state.channel]
  end

  defp debug(msg) do
    IO.puts IO.ANSI.yellow() <> msg <> IO.ANSI.reset()
  end
end