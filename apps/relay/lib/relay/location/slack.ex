defmodule Relay.Location.Slack do
  use Ecto.Schema

  embedded_schema do
    field :token, :string
    field :channel, :string
    field :pipeline_id, :integer
  end
end