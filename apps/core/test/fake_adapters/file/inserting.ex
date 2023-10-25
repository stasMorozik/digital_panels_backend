defmodule FakeAdapters.File.Inserting do
  alias Core.File.Ports.Transformer

  alias Core.File.Entity, as: FileEntity
  alias Core.User.Entity, as: UserEntity

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @behaviour Transformer

  @impl Transformer
  def transform(file, user) do
    IO.inspect(file)

    IO.inspect(user)
    {:ok, true}
  end
end
