defmodule Relay.Irc.ConnectionHandler do
  defmodule State do
    defstruct host: "***REMOVED***",
              port: 6667,
              pass: "",
              nick: "andrewbot",
              user: "andrewbot",
              name: "andrewbot",
              client: nil
  end

  def start_link(client, state \\ %State{}) do
    GenServer.start_link(__MODULE__, [%{state | client: client}])
  end

  def init([state]) do
    ExIrc.Client.add_handler state.client, self
    ExIrc.Client.connect! state.client, state.host, state.port
    {:ok, state}
  end

  def handle_info({:connected, server, port}, state) do
    debug "Connected to #{server}:#{port}"
    ExIrc.Client.logon state.client, state.pass, state.nick, state.user, state.name
    {:noreply, state}
  end

  def handle_info(:logged_in, state) do
    autojoin_channels
    |> Enum.each(fn channel ->
         ExIrc.Client.join(state.client, channel)
       end)

    {:noreply, state}
  end

  # Catch-all for messages you don't care about
  def handle_info(msg, state) do
    debug "Received unknown messsage:"
    IO.inspect msg
    {:noreply, state}
  end

  defp autojoin_channels do
    ~w[#lobby]
  end

  defp debug(msg) do
    IO.puts IO.ANSI.yellow() <> msg <> IO.ANSI.reset()
  end
end