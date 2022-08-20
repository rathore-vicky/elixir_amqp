defmodule ElixirAMQP do
  @moduledoc """
  ElixirAMQP keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  alias ElixirAMQP.DataSet

  defdelegate dispatch_data, to: DataSet
end
