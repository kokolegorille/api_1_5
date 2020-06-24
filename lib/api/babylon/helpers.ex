defmodule Api.Babylon.Helpers do
  use Bitwise

  @moduledoc """
  A set of Elixir helpers for managing Babylonjs world
  """

  @max_size 500
  @default_animation "Idle"
  # @shapes ~w(box cylinder disc icoSphere polyhedron torus torusKnot sphere)
  @shapes ~w(box icoSphere polyhedron torus torusKnot)

  def random_player(max_size \\ @max_size) do
    position = random_position(max_size)

    %{
      model: random_shape(),
      colour: random_color(),
      animation: @default_animation,
      x: position.x,
      y: 5,
      z: position.z,
      rx: 0,
      ry: 0,
      rz: 0
    }
  end

  def random_shape do
    Enum.random(@shapes)
  end

  def random_position(max_size) do
    %{
      x: Enum.random(1..max_size),
      y: Enum.random(1..max_size),
      z: Enum.random(1..max_size)
    }
  end

  def random_color() do
    random_rgb()
    |> rgb_to_hex
  end

  defp random_rgb do
    %{
      red: generate_random_hex(),
      green: generate_random_hex(),
      blue: generate_random_hex()
    }
  end

  # https://github.com/barakyo/color_utils
  defp rgb_to_hex(%{red: red, green: green, blue: blue}) do
    hex =
      ((1 <<< 24) + (red <<< 16) + (green <<< 8) + blue)
      |> Integer.to_string(16)
      |> String.slice(1..1500)

    "#" <> hex
  end

  defp generate_random_hex, do: Enum.random(0..255)
end
