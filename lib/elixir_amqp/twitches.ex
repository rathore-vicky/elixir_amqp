defmodule ElixirAMQP.Twitches do
  @moduledoc """
  The Twitches context.
  """

  import Ecto.Query, warn: false
  alias ElixirAMQP.Repo

  alias ElixirAMQP.Schema.Twitch

  @doc """
  Returns the list of twitchs.

  ## Examples

      iex> list_with_pagination()
      [%Twitch{}, ...]

  """
  def list_with_pagination(pagination_params) do
    Twitch
    |> order_by(desc: :inserted_at)
    |> Repo.paginate(pagination_params)
  end

  @doc """
  Gets a single twitch.

  Raises `Ecto.NoResultsError` if the Twitch does not exist.

  ## Examples

      iex> get_twitch!(123)
      %Twitch{}

      iex> get_twitch!(456)
      ** (Ecto.NoResultsError)

  """
  def get_twitch!(id), do: Repo.get!(Twitch, id)

  @doc """
  Creates a twitch.

  ## Examples

      iex> create_twitch(%{field: value})
      {:ok, %Twitch{}}

      iex> create_twitch(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_twitch(attrs \\ %{}) do
    %Twitch{}
    |> Twitch.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a twitch.

  ## Examples

      iex> update_twitch(twitch, %{field: new_value})
      {:ok, %Twitch{}}

      iex> update_twitch(twitch, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_twitch(%Twitch{} = twitch, attrs) do
    twitch
    |> Twitch.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a twitch.

  ## Examples

      iex> delete_twitch(twitch)
      {:ok, %Twitch{}}

      iex> delete_twitch(twitch)
      {:error, %Ecto.Changeset{}}

  """
  def delete_twitch(%Twitch{} = twitch) do
    Repo.delete(twitch)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking twitch changes.

  ## Examples

      iex> change_twitch(twitch)
      %Ecto.Changeset{data: %Twitch{}}

  """
  def change_twitch(%Twitch{} = twitch, attrs \\ %{}) do
    Twitch.changeset(twitch, attrs)
  end
end
