defmodule Relay.Location.Irc do
  use Ecto.Schema

  embedded_schema do
    field :bot_name, :string
    field :server, :string
    field :port, :integer
    field :channel, :string
  end
end