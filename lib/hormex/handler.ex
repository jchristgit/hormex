defmodule Hormex.Handler do
  require Logger

  @status_names %{
    200 => "OK",
    400 => "Bad Request"
  }

  def handle_request(client, packets) do
    case packets do
      [{:ok, {:http_request, method, {:abs_path, path}, {major, minor}}} | _rest] ->
        Logger.debug("#{method} #{path} HTTP/#{major}.#{minor}")
        respond(client, 200, "<h1>OK</h1>")

      _ ->
        Logger.debug("Invalid request")
        respond(client, 400, "<h1>Bad Request</h1>")
    end
  end

  def respond(client, status, body) do
    Logger.debug("Responding with status #{status}")

    response = """
    HTTP/1.1 #{status} #{@status_names[status]}
    Content-Type: text/html
    Content-Length: #{String.length(body)}\r\n\r
    #{body}
    """

    :gen_tcp.send(client, response)
  end
end
