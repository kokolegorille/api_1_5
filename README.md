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