defmodule ElixirAMQP.Schema.Meme do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @fields [
    :id,
    :archived_url,
    :base_name,
    :page_url,
    :md5_hash,
    :file_size,
    :alternate_text
  ]

  @primary_key {:id, :integer, []}
  schema "memes" do
    field(:archived_url, :string)
    field(:base_name, :string)
    field(:page_url, :string)
    field(:md5_hash, :string)
    field(:file_size, :integer)
    field(:alternate_text, :string)

    timestamps()
  end

  @doc false
  def changeset(memes, attrs) do
    memes
    |> cast(attrs, @fields)
    |> validate_required(@fields)
  end
end
