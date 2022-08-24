defmodule ElixirAMQP.Repo.Migrations.CreateMemesTable do
  use Ecto.Migration

  def change do
    create table(:memes, primary_key: false) do
      add :id, :bigint, primary_key: true
      add :archived_url, :varchar, size: 255, null: false
      add :base_name, :varchar, size: 255, null: false
      add :page_url, :varchar, size: 255, null: false
      add :md5_hash, :varchar, size: 255, null: false
      add :file_size, :bigint, null: false
      add :alternate_text, :text, null: false

      timestamps(type: :utc_datetime_usec)
    end
  end
end
