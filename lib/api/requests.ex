defmodule Api.Requests do
  @moduledoc """
  The requests module
  """

  alias Api.Requests.{Request, RequestSrv}

  defdelegate new(name, description, owner), to: Request
  defdelegate add_request(request), to: RequestSrv
  defdelegate delete_by_id(id), to: RequestSrv
  defdelegate delete_by_owner(owner), to: RequestSrv
  defdelegate delete_by_owner_and_id(owner, id), to: RequestSrv
  defdelegate flush_table, to: RequestSrv
  defdelegate has_requests?(owner), to: RequestSrv
  defdelegate list_requests, to: RequestSrv
  defdelegate get_by_owner(owner), to: RequestSrv
  defdelegate get_by_id(id), to: RequestSrv
  defdelegate get_by_owner_and_id(owner, id), to: RequestSrv
  defdelegate stop, to: RequestSrv
end
