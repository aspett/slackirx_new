defmodule Data.Repo.Migrations.CreatePipelines do
  use Ecto.Migration

  def change do
    create table(:pipelines) do
      add :type, :string
      add :name, :string

      add :source_id, references(:locations)
      add :destination_id, references(:locations)

      timestamps()
    end
  end
end
