defmodule Foosball.Team do
  use Foosball.Web, :model

  schema "teams" do
    field :team_id, :string
    field :access_token, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:team_id, :access_token])
    |> validate_required([:team_id, :access_token])
  end
end
