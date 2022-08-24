defmodule ElixirAMQP.Validation do
  @moduledoc """
    This module validate the external APIs parameteres.
  """

  alias ElixirAMQP.Types.Topic

  defmodule List do
    @moduledoc """
     Validators for List API.
    """
    use Ecto.Schema
    import Ecto.Changeset

    @required_fields ~w(topic)a
    @optional_fields ~w(page page_size)a

    @primary_key false
    embedded_schema do
      field :topic, Topic
      field :page, :integer
      field :page_size, :integer
    end

    @spec validate(params :: map()) :: {:error, Ecto.Changeset.t()} | {:ok, map()}
    def validate(params) do
      changeset =
        %__MODULE__{}
        |> cast(params, @required_fields ++ @optional_fields)
        |> validate_required(@required_fields)

      if changeset.valid? do
        {:ok, apply_changes(changeset)}
      else
        {:error, changeset}
      end
    end
  end
end
