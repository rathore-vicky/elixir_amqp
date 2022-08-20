defmodule ElixirAMQP.Repo.Migrations.CreateTwitchTable do
  use Ecto.Migration

  def change do
    create table(:twitches, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :channel, :char, size: 64, null: false
      add :watch_time, :bigint, null: false
      add :stream_time, :bigint, null: false
      add :peak_viewers, :bigint, null: false
      add :avg_viewers, :bigint, null: false
      add :followers, :bigint, null: false
      add :followers_gained, :bigint, null: false
      add :views_gained, :bigint, null: false

      add :partnered, :boolean, null: false
      add :mature, :boolean, null: false
      add :language, :char, size: 16, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:twitches, [:channel])
  end
end
