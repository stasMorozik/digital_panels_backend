defmodule Core.Device.UseCases.Updating do
  @moduledoc """
    Юзекейз редактирования устройства
  """

  alias Core.Device.Methods.Edit

	alias Core.Device.Builder
  alias Core.Device.Ports.Transformer
	alias Core.Device.Ports.Getter

  alias Core.User.UseCases.Authorization
  alias User.Ports.Getter, as: GetterUser
  
  alias Core.Playlist.Ports.Getter, as: GetterPlaylist

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Shared.Types.Exception

	@spec update(
    Authorization.t(),
    GetterUser.t(),
    Getter.t(),
    GetterPlaylist.t(),
    Transformer.t(),
    map()
  ) :: Success.t() | Error.t() | Exception.t()
  def update(
    authorization_use_case,
    getter_user,
		getter,
    getter_playlist,
    transformer,
    args
  ) when is_atom(authorization_use_case)
    and is_atom(transformer)
    and is_map(args) do

		{result_0, _} = UUID.info(Map.get(args, :playlist_id))

		{result_1, _} = UUID.info(Map.get(args, :id))

		with true <- Kernel.function_exported?(authorization_use_case, :auth, 2),
         true <- Kernel.function_exported?(getter, :get, 1),
				 true <- Kernel.function_exported?(getter_playlist, :get, 1),
         true <- Kernel.function_exported?(transformer, :transform, 3),
         :ok <- result_0,
         :ok <- result_1,
         {:ok, user} <- authorization_use_case.auth(
            getter_user, %{token: Map.get(args, :token, "")}
         ),
         {:ok, device} <- getter.get(UUID.string_to_binary!(
            args.id
         )),
         {:ok, playlist} <- getter_playlist.get(UUID.string_to_binary!(
            args.playlist_id
         )),
         default_args <- %{
            ssh_port: Map.get(args, :ssh_port),
            ssh_host: Map.get(args, :ssh_host),
            ssh_user: Map.get(args, :ssh_user),
            ssh_password: Map.get(args, :ssh_password),
            address: Map.get(args, :address),
            longitude: Map.get(args, :longitude),
            latitude: Map.get(args, :latitude),
            is_active: Map.get(args, :is_active),
         },
         {:ok, edited_device} <- Edit.edit(device, default_args),
         {:ok, _} <- transformer.transform(edited_device, user, playlist) do
      Success.new(true)
    else
      false -> Error.new("Не валидные аргументы для получения устройства")
      {:error, message} -> {:error, message}
      :error ->
        Error.new(
          "Не валидный UUID устройства/плэйлиста: " <> 
          "#{Map.get(args, :id)}/#{Map.get(args, :playlist_id)}"
        )
      {:exception, message} -> {:exception, message}
    end
	end

	def update(_, _, _, _, _, _) do
    Error.new("Не валидные аргументы для редактирования устройства")
  end
end