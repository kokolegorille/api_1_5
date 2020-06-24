# Api

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix

# Building an API 

This version is for Phoenix 1.5.

https://github.com/kokolegorille/api_1_5

$ mix phx.new api --no-html --no-webpack
$ mix phx.gen.presence

$ cd api
$ mix ecto.create

$ git init
$ git add .
$ git commit -m "Initial commit"

$ mix phx.gen.presence
* creating lib/api_web/channels/presence.ex

Add your new module to your supervision tree,
in lib/api/application.ex:

    children = [
      ...
      ApiWeb.Presence
    ]

You're all set! See the Phoenix.Presence docs for more details:
http://hexdocs.pm/phoenix/Phoenix.Presence.html

## Add channels

Add files:

/lib/api_web/channels/lobby_channel.ex
/lib/api_web/channels/room_channel.ex
/lib/api_web/channels/system_channel.ex
/lib/api_web/channels/user_channel.ex


## Manual start of Babylon worker

iex> w = Babylon.new %{id: "1", members: [%{id: 1, name: "admin"}]}
iex> Babylon.start_worker w

to check...

iex> Babylon.list_worlds                                           
[
  %Api.Babylon.World{
    access: :public,
    description: nil,
    id: "1",
    inserted_at: nil,
    members: [%{id: 1, name: "admin"}],
    name: nil,
    owner: nil,
    players: %{
      1 => %Api.Babylon.Player{
        animation: "Idle",
        colour: "#FEBCD3",
        id: 1,
        model: "torus",
        rx: 0,
        ry: 0,
        rz: 0,
        status: :loading,
        x: 122,
        y: 5,
        z: 226
      }
    },
    presences: [%{id: 1, name: "admin"}],
    status: :running
  }
]