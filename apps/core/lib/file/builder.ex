defmodule Core.File.Builder do
  @moduledoc """
    Билдер сущности
  """

  alias UUID

  @spec build(map()) :: Core.Shared.Types.Success.t() | Core.Shared.Types.Error.t()
  def build(%{path: path, name: name, extname: extname, size: size}) do
    entity()
      |> Core.File.Builders.Extension.build(extname)
      |> Core.File.Builders.Size.build(size)
      |> Core.File.Builders.Path.build(path)
      |> Core.File.Builders.Type.build(extname)
      |> Core.File.Builders.Url.build(name)
  end

  def build(_) do
    {:error, "Невалидные данные для построения пользователя"}
  end

  defp entity do
    {:ok, %Core.File.Entity{
      id: UUID.uuid4(), 
      created: Date.utc_today
    }}
  end
end