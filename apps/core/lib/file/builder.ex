defmodule Core.File.Builder do
  @moduledoc """
    Билдер сущности
  """

  alias UUID
  alias Core.File.Entity

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @spec build(map()) :: Success.t() | Error.t()
  def build(%{
    binary: binary(),
    path: binary(),
    web_dav_url: binary()
  }) do
    entity()
      |> size(path, binary)
      |> url(web_dav_url)
  end

  # Функция построения базового файла
  defp entity do
    Success.new(%Entity{
      id: UUID.uuid4(),
      created: Date.utc_today,
      updated: Date.utc_today
    })
  end
end