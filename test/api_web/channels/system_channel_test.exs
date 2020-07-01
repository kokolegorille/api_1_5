defmodule ApiWeb.SystemChannelTest do
  use ApiWeb.ChannelCase

  alias ApiWeb.{SystemChannel, UserSocket}

  setup do
    user = %{id: 1, name: "koko"}
    {:ok, _, socket} = UserSocket
    |> socket("user_id", %{user: user})
    |> subscribe_and_join(SystemChannel, "system")

    %{socket: socket}
  end

  # test "ping replies with status ok", %{socket: socket} do
  #   ref = push(socket, "ping", %{})
  #   assert_reply ref, :ok, _
  # end
end
