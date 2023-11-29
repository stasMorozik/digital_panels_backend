defmodule PostgresqlAdapters.ConfirmationCode.Mapper do
  alias Core.Shared.Types.Success
  
  alias Core.ConfirmationCode.Entity

  def to_entity([needle, code, confirmed, created]) do
    Success.new(%Entity{
      needle: needle,
      created: created,
      code: code,
      confirmed: confirmed
    })
  end
end