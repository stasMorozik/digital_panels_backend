defmodule File.PuttingTest do
  use ExUnit.Case

  alias Core.File.Builder, as: FileBuilder
  alias Core.User.Builder, as: UserBuilder

  alias HttpAdapters.File.Putting

  doctest Core.File.Builder
  
  setup_all do
    File.touch("/tmp/not_emty.gif", 1544519753)
    
    File.write("/tmp/not_emty.gif", "data:image/gif;base64,R0lGODlhUAAPAKIAAAsLav///88PD9WqsYmApmZmZtZfYmdakyH5BAQUAP8ALAAAAABQAA8AAAPbWLrc/jDKSVe4OOvNu/9gqARDSRBHegyGMahqO4R0bQcjIQ8E4BMCQc930JluyGRmdAAcdiigMLVrApTYWy5FKM1IQe+Mp+L4rphz+qIOBAUYeCY4p2tGrJZeH9y79mZsawFoaIRxF3JyiYxuHiMGb5KTkpFvZj4ZbYeCiXaOiKBwnxh4fnt9e3ktgZyHhrChinONs3cFAShFF2JhvCZlG5uchYNun5eedRxMAF15XEFRXgZWWdciuM8GCmdSQ84lLQfY5R14wDB5Lyon4ubwS7jx9NcV9/j5+g4JADs=")
    
    :ok
  end

  test "Put" do
    {:ok, f} = FileBuilder.build(%{
      path: "/tmp/not_emty.gif",
      web_dav_url: Application.fetch_env!(:http_adapters, :url)
    })

    {:ok, u} = UserBuilder.build(%{
      email: "test@gmail.com", 
      name: "Пётр", 
      surname: "Павел"
    })

    {result, _} = Putting.transform(f, u)

    assert result == :ok
  end
end
