defmodule Relay.Irc.DispatchHandler do
  use GenServer
  @channel "#lobby"

  def start_link(client) do
    GenServer.start_link(__MODULE__, { :ok, client }, name: __MODULE__)
  end

  def init({:ok, client}) do
    {:ok, client}
  end

  def handle_cast({:message, %{from: from, message: message}}, client) do
    ExIrc.Client.msg(client, :privmsg, @channel, message)

    { :noreply, client }
  end

  def dispatch(dispatch = {:message, event}) do
    GenServer.cast(__MODULE__, dispatch)

    :ok
  end

  def dispatch(_) do
    {:error, :unrecognized_input}
  end
end