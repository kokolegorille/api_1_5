defmodule Api.Requests do
  @moduledoc """
  The requests module
  """

  alias Api.Requests.{Request, RequestSrv}

  defdelegate new(name, description, owner), to: Request

  defdelegate add_request(request), to: RequestSrv
  defdelegate list_requests(), to: RequestSrv
end
