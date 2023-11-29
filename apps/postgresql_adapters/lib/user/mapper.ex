defmodule PostgresqlAdapters.User.Mapper do

  alias Core.User.Entity
  alias Core.Shared.Types.Success

  def to_entity([id, email, name, surname, created, updated]) do
    Success.new(%Entity{
      id: UUID.binary_to_string!(id),
      email: email,
      name: name,
      surname: surname,
      created: created,
      updated: updated
    })
  end
end