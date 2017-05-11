defmodule Data.Location do
  @type t :: %Data.Location{}

  use Ecto.Schema
  import Ecto.Changeset

  @moduledoc false

  schema "locations" do
    field :name, :string
    field :type, :string

    # Common
    field :channel, :string

    # Slack
    field :slack_token, :string

    # Irc
    field :bot_name, :string
    field :server, :string
    field :port, :integer

    has_one :source_pipeline, Data.Pipeline, foreign_key: :source_id
    has_one :destination_pipeline, Data.Pipeline, foreign_key: :destination_id

    timestamps
  end

  def changeset(location, params \\ %{}) do
    location
    |> cast(params, [:name, :type, :channel, :slack_token, :bot_name, :server, :port])
    |> validate_required([:name, :type, :channel])
  end

  def get_pipeline(location) do
    pipeline = cond do
      location.source_pipeline -> location.source_pipeline
      location.destination_pipeline -> location.destination_pipeline
      true -> raise "no pipeline associated"
    end

    pipeline |> Data.Repo.preload([:source, :destination])
  end
end