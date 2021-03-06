defmodule ApiWeb.UserSocket do
  use Phoenix.Socket
  import ApiWeb.TokenHelpers, only: [verify_token: 1]

  alias ApiWeb.{
    SystemChannel,
    LobbyChannel,
    UserChannel,
    RoomChannel,
    WorldChannel
  }

  ## Channels
  channel "system", SystemChannel
  channel "lobby", LobbyChannel
  channel "user:*", UserChannel
  channel "room:*", RoomChannel
  channel "world:*", WorldChannel

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  # @impl true
  # def connect(_params, socket, _connect_info) do
  #   {:ok, socket}
  # end

  @impl true
  def connect(%{"token" => token}, socket) do
    case verify_token(token) do
      {:ok, user} ->
        {:ok, assign(socket, :user, user)}

      {:error, _reason} ->
        :error
    end
  end

  def connect(_params, _socket), do: :error

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     ApiWeb.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  @impl true
  def id(_socket), do: nil
end
