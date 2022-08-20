defmodule ElixirAMQPWeb.CentralController do
  use ElixirAMQPWeb, :controller

  alias ElixirAMQP.DataSet
  alias ElixirAMQP.Validation

  action_fallback ElixirAMQPWeb.FallbackController

  def list(conn, %{"topic" => topic} = params) do
    with {:ok, params} <- Validation.List.validate(params),
         {pagination_params, _filters} <- Map.split(params, [:page_size, :page]) do
      page = DataSet.get_or_store(topic, pagination_params)

      conn
      |> put_status(200)
      |> render("index.json", entries: page.entries, page: page)
    end
  end
end
