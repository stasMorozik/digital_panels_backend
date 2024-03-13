defmodule Assembly.UploadingTest do
  use ExUnit.Case

  alias HttpAdapters.Assembly.Uploading
  alias Core.Assembly.Builder

  doctest HttpAdapters.Assembly.Uploading

  setup_all do
    :ok
  end

  test "Insert" do
    {:ok, user} = Core.User.Builder.build(%{
      email: "test@gmail.com", 
      name: "Пётр", 
      surname: "Павел"
    })

    {:ok, group} = Core.Group.Builder.build(%{
      name: "Тест"
    })

    {:ok, assembly} = Builder.build(%{group: group, type: "Linux"})
    IO.inspect(assembly)
    {result, _} = Uploading.transform(assembly, user)
    
    assert result == :ok
  end
end