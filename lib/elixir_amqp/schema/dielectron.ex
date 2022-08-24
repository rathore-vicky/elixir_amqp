defmodule ElixirAMQP.Schema.Dielectron do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @fields [
    :event,
    :run,
    :m,
    :e1,
    :px1,
    :py1,
    :pz1,
    :pt1,
    :eta1,
    :phi1,
    :q1,
    :e2,
    :px2,
    :py2,
    :pz2,
    :pt2,
    :eta2,
    :phi2,
    :q2
  ]

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "dielectrons" do
    field(:run, :integer)
    field(:event, :integer)
    field(:m, :decimal)

    field(:e1, :decimal)
    field(:px1, :decimal)
    field(:py1, :decimal)
    field(:pz1, :decimal)
    field(:pt1, :decimal)
    field(:eta1, :decimal)
    field(:phi1, :decimal)
    field(:q1, :decimal)

    field(:e2, :decimal)
    field(:px2, :decimal)
    field(:py2, :decimal)
    field(:pz2, :decimal)
    field(:pt2, :decimal)
    field(:eta2, :decimal)
    field(:phi2, :decimal)
    field(:q2, :decimal)

    timestamps()
  end

  @doc false
  def changeset(di_electron, attrs) do
    di_electron
    |> cast(attrs, @fields)
    |> validate_required(@fields)
    |> unique_constraint([:run, :event],
      name: :dielectrons_event_run,
      message: "run with event already exists"
    )
  end
end
