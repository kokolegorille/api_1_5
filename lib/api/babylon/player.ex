defmodule Api.Babylon.Player do
  @moduledoc """
  The Player structure for Babylonjs world
  """

  @derive {Jason.Encoder,
           only: [
             :id,
             :model,
             :colour,
             :animation,
             :x,
             :y,
             :z,
             :rx,
             :ry,
             :rz
           ]}

  defstruct id: nil,
            model: nil,
            colour: nil,
            animation: nil,
            x: nil,
            y: nil,
            z: nil,
            rx: nil,
            ry: nil,
            rz: nil,
            status: :loading

  def new(attrs), do: struct(__MODULE__, attrs)
end
