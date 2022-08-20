defmodule ElixirAMQP.Repo.Migrations.CreateDielectronTable do
  use Ecto.Migration

  def change do
    create table(:dielectrons, primary_key: false) do
      add :event, :bigint, primary_key: true
      add :run, :bigint, null: false
      add :m, :decimal, null: false

      add :e1, :decimal, null: false
      add :px1, :decimal, null: false
      add :py1, :decimal, null: false
      add :pz1, :decimal, null: false
      add :pt1, :decimal, null: false
      add :eta1, :decimal, null: false
      add :phi1, :decimal, null: false
      add :q1, :decimal, null: false

      add :e2, :decimal, null: false
      add :px2, :decimal, null: false
      add :py2, :decimal, null: false
      add :pz2, :decimal, null: false
      add :pt2, :decimal, null: false
      add :eta2, :decimal, null: false
      add :phi2, :decimal, null: false
      add :q2, :decimal, null: false

      timestamps(type: :utc_datetime_usec)
    end
  end
end
