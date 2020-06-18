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

  def delete_request_by_uuid(uuid) do
    keys = uuid
    |> search_by_uuid()
    |> Enum.map(fn request -> {request.uuid, request.owner} end)
    GenServer.cast(@name, {:delete_by_keys, keys})
  end

  def delete_by_owner(owner) do
    keys = owner
    |> search_by_owner()
    |> Enum.map(fn request -> {request.uuid, owner} end)
    GenServer.cast(@name, {:delete_by_keys, keys})
  end

  def flush_table, do: GenServer.cast(@name, :flush_table)

  def has_requests?(owner) do
    not Enum.empty?(search_by_owner(owner))
  end

  def list_requests() do
    :ets.tab2list(:requests)
    |> Enum.map(fn {_key, request} -> request end)
  end

  def search_by_owner(owner) do
    :ets.match_object(:requests, {{:_, owner}, :"$1"})
    |> Enum.map(fn {_key, request} -> request end)
  end

  def search_by_uuid(uuid) do
    :ets.match_object(:requests, {{uuid, :_}, :"$1"})
    |> Enum.map(fn {_key, request} -> request end)
  end

  def search_by_owner_and_uuid(owner, uuid) do
    :ets.match_object(:requests, {{uuid, owner}, :"$1"})
    |> Enum.map(fn {_key, request} -> request end)
  end

	def stop, do: GenServer.cast(@name, :stop)

  def init(_) do
    :ets.new(:requests, [:set, :protected, :named_table])
    {:ok, nil}
  end

  def handle_call({:create_request, %{uuid: uuid, owner: owner} = request}, _from, _state) do
    :ets.insert_new(:requests, {{uuid, owner}, request})
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
		Logger.debug(fn -> "#{@name} is stopping : #{inspect reason}" end)
    :ets.delete(:requests)
		:ok
  end

  defp delete_request(key), do: :ets.delete(:requests, key)
end
