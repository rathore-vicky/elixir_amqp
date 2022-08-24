defmodule ElixirAMQPWeb.CentralController do
  @moduledoc false
  use ElixirAMQPWeb, :controller

  alias ElixirAMQP.DataHandler
  alias ElixirAMQP.Validation

  action_fallback ElixirAMQPWeb.FallbackController

  def list(conn, params) do
    with {:ok, params} <- Validation.List.validate(params),
         {pagination_params, _filters} <- Map.split(params, [:page_size, :page]),
         {:ok, page} <- DataHandler.get_or_store(params.topic, pagination_params) do
      conn
      |> put_status(200)
      |> render("index.json", entries: page.entries, page: page)
    end
  end
end
