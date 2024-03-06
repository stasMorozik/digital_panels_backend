defmodule Core.Playlist.Ports.GetterList do
  @moduledoc """
    Порт получающий данные из хранилища и преобразующий их в список сущностей
  """

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Shared.Types.Exception

  alias Core.Shared.Types.Pagination
  alias Core.Playlist.Types.Filter
  alias Core.Playlist.Types.Sort

  alias Core.User.Entity, as: User

  @type t :: __MODULE__

  @callback get(
    Pagination.t(), 
    Filter.t(), 
    Sort.t(), 
    User.t()
  ) ::  Success.t() | Error.t() | Exception.t()
end
