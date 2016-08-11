defmodule Foosball.Repo.Migrations.CreateTeam do
  use Ecto.Migration

  def change do
    create table(:teams) do
      add :team_id, :string
      add :access_token, :string

      timestamps()
    end

  end
end
