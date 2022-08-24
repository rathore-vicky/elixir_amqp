defmodule ElixirAMQP.Schema.Twitch do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @fields [
    :channel,
    :watch_time,
    :stream_time,
    :peak_viewers,
    :avg_viewers,
    :followers,
    :followers_gained,
    :views_gained,
    :partnered,
    :mature,
    :language
  ]

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "twitches" do
    field(:channel, :string)
    field(:watch_time, :integer)
    field(:stream_time, :integer)
    field(:peak_viewers, :integer)
    field(:avg_viewers, :integer)
    field(:followers, :integer)
    field(:followers_gained, :integer)
    field(:views_gained, :integer)

    field(:partnered, :boolean)
    field(:mature, :boolean)
    field(:language, :string)

    timestamps()
  end

  @doc false
  def changeset(twitch_data \\ %__MODULE__{}, attrs) do
    attrs =
      attrs
      |> Map.put(:partnered, to_downcase(attrs.partnered))
      |> Map.put(:mature, to_downcase(attrs.mature))

    twitch_data
    |> cast(attrs, @fields)
    |> validate_required(@fields)
    |> unique_constraint(:channel,
      name: :channel_name_is_unique,
      message: "channel already exists"
    )
  end

  defp to_downcase("True"), do: true
  defp to_downcase("False"), do: false
  defp to_downcase(other), do: other
end
