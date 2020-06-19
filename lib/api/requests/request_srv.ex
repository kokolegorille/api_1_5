defmodule Api.Requests.RequestSrv do
  @moduledoc """
  The request server
  """

  use GenServer
  require Logger
  @name __MODULE__

  def start_link(_ \\ []) do
    GenServer.start_link(@name, nil, name: @name)
  end

  def add_request(%{owner: owner} = request) do
    if has_requests?(owner),
      do: {:error, "Cannot own multiple requests"},
      else: GenServer.call(@name, {:create_request, request})
  end

  def delete_by_id(id) do
    keys =
      id
      |> get_by_id()
      |> Enum.map(fn request -> {request.id, request.owner} end)

    with false <- Enum.empty?(keys),
         :ok <- GenServer.cast(@name, {:delete_by_keys, keys}) do
      {:ok, Enum.map(keys, fn {id, _} -> id end)}
    else
      true -> {:error, "Request not found"}
      {:error, reason} -> {:error, reason}
    end
  end

  def delete_by_owner(owner) do
    keys =
      owner
      |> get_by_owner()
      |> Enum.map(fn request -> {request.id, owner} end)

    with false <- Enum.empty?(keys),
         :ok <- GenServer.cast(@name, {:delete_by_keys, keys}) do
      {:ok, Enum.map(keys, fn {id, _} -> id end)}
    else
      true -> {:error, "Request not found"}
      {:error, reason} -> {:error, reason}
    end
  end

  def delete_by_owner_and_id(owner, id) do
    keys =
      owner
      |> get_by_owner_and_id(id)
      |> Enum.map(fn request -> {request.id, owner} end)

    with false <- Enum.empty?(keys),
         :ok <- GenServer.cast(@name, {:delete_by_keys, keys}) do
      {:ok, Enum.map(keys, fn {id, _} -> id end)}
    else
      true -> {:error, "Request not found"}
      {:error, reason} -> {:error, reason}
    end
  end

  def flush_table, do: GenServer.cast(@name, :flush_table)

  def get_by_owner(owner) do
    :ets.match_object(:requests, {{:_, owner}, :"$1"})
    |> Enum.map(fn {_key, request} -> request end)
  end

  def get_by_id(id) do
    :ets.match_object(:requests, {{id, :_}, :"$1"})
    |> Enum.map(fn {_key, request} -> request end)
  end

  def get_by_owner_and_id(owner, id) do
    :ets.match_object(:requests, {{id, owner}, :"$1"})
    |> Enum.map(fn {_key, request} -> request end)
  end

  def has_requests?(owner) do
    not Enum.empty?(get_by_owner(owner))
  end

  def list_requests() do
    :ets.tab2list(:requests)
    |> Enum.map(fn {_key, request} -> request end)
  end

  def stop, do: GenServer.cast(@name, :stop)

  def init(_) do
    :ets.new(:requests, [:set, :protected, :named_table])
    {:ok, nil}
  end

  def handle_call({:create_request, %{id: id, owner: owner} = request}, _from, _state) do
    :ets.insert_new(:requests, {{id, owner}, request})
    {:reply, {:ok, request}, nil}
  end

  def handle_cast({:delete_by_keys, keys}, _state) do
    Enum.each(keys, &delete_request(&1))
    {:noreply, nil}
  end

  def handle_cast(:flush_table, _state) do
    :ets.delete_all_objects(:requests)
    {:noreply, nil}
  end

  def handle_cast(:stop, _state), do: {:stop, :normal, nil}

  def terminate(reason, _state) do
    Logger.debug(fn -> "#{@name} is stopping : #{inspect(reason)}" end)
    :ets.delete(:requests)
    :ok
  end

  defp delete_request(key), do: :ets.delete(:requests, key)
end
