defmodule ElixirAMQP.DiElectrons do
  @moduledoc """
  The DiElectrons context.
  """

  import Ecto.Query, warn: false

  alias ElixirAMQP.Repo
  alias ElixirAMQP.Schema.Dielectron

  @doc """
  Returns the list of dielectrons.

  ## Examples

      iex> list_with_pagination()
      [%Dielectron{}, ...]

  """
  def list_with_pagination(pagination_params) do
    Dielectron
    |> order_by(desc: :inserted_at)
    |> Repo.paginate(pagination_params)
  end

  @doc """
  Gets a single dielectron.

  Raises `Ecto.NoResultsError` if the Dielectron does not exist.

  ## Examples

      iex> get_dielectron!(123)
      %Dielectron{}

      iex> get_dielectron!(456)
      ** (Ecto.NoResultsError)

  """
  def get_dielectron!(id), do: Repo.get!(Dielectron, id)

  @doc """
  Creates a dielectron.

  ## Examples

      iex> create_dielectron(%{field: value})
      {:ok, %Dielectron{}}

      iex> create_dielectron(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_dielectron(attrs \\ %{}) do
    %Dielectron{}
    |> Dielectron.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a dielectron.

  ## Examples

      iex> update_dielectron(dielectron, %{field: new_value})
      {:ok, %Dielectron{}}

      iex> update_dielectron(dielectron, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_dielectron(%Dielectron{} = dielectron, attrs) do
    dielectron
    |> Dielectron.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a dielectron.

  ## Examples

      iex> delete_dielectron(dielectron)
      {:ok, %Dielectron{}}

      iex> delete_dielectron(dielectron)
      {:error, %Ecto.Changeset{}}

  """
  def delete_dielectron(%Dielectron{} = dielectron) do
    Repo.delete(dielectron)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking dielectron changes.

  ## Examples

      iex> change_dielectron(dielectron)
      %Ecto.Changeset{data: %Dielectron{}}

  """
  def change_dielectron(%Dielectron{} = dielectron, attrs \\ %{}) do
    Dielectron.changeset(dielectron, attrs)
  end
end
