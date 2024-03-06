defmodule PostgresqlAdapters.Executor do

  def execute(connection, query, data_list) do
    with {:ok, query} <- Postgrex.prepare(connection, "", query),
         {:ok, _, result} <- Postgrex.execute(connection, query, data_list) do
      {:ok, result}
    else
      {:error, e} -> {:exception, e.postgres.message}
    end
  end
end