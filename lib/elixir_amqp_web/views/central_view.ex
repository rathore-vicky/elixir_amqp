defmodule ElixirAMQPWeb.CentralView do
  @moduledoc false
  use ElixirAMQPWeb, :view

  def render("index.json", %{entries: entries}) do
    Enum.map(entries, &struct_to_map/1)
  end

  defp struct_to_map(row) do
    row
    |> Map.from_struct()
    |> Map.delete(:__meta__)
  end
end
