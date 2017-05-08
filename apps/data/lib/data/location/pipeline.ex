defmodule Data.Pipeline do
  @type t :: %Data.Pipeline{}

  use Ecto.Schema
  import Ecto.Changeset

  schema "pipelines" do
    field :type, :string
    field :name, :string

    belongs_to :source, Data.Location
    belongs_to :destination, Data.Location

    timestamps
  end

  def changeset(pipeline, params \\ %{}) do
    pipeline
    |> cast(params, [:type, :name])
    |> validate_required([:type, :name])
    |> cast_assoc(:source)
    |> cast_assoc(:destination)
  end

end