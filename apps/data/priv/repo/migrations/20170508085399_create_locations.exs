defmodule Data.Repo.Migrations.CreateLocations do
  use Ecto.Migration

  def change do
    create table(:locations) do
      add :name, :string
      add :type, :string
      add :channel, :string

      add :slack_token, :string

      add :bot_name, :string
      add :server, :string
      add :port, :integer

      timestamps()
    end
  end
end
