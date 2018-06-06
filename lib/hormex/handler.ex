defmodule Hormex.Handler do
  alias Hormex.Router
  require Logger

  @status_names %{
    200 => "OK",
    400 => "Bad Request",
    404 => "Not Found"
  }

  def handle_request(client, packets) do
    case packets do
      [{:ok, {:http_request, method, {:abs_path, path}, {major, minor}}} | _rest] ->
        Logger.debug("#{method} #{path} HTTP/#{major}.#{minor}")
        respond_with_file(client, method, path)

      _ ->
        Logger.debug("Invalid request")
        respond(client, 400, "<h1>Bad Request</h1>")
    end
  end

  defp respond_with_file(client, _method, path) do
    path_string = to_string path
    with {:ok, {route_path, options}} <- Router.route_for(Router, path_string),
         file_path <- String.trim_leading(path_string, route_path),
         {:ok, contents} <- File.read("#{options[:location]}/#{file_path}") do
      respond(client, 200, contents)
    else
      _ ->
        respond(
          client,
          404,
          "<h1>Not Found</h1><p>The requested resource could not be found.</p>"
        )
    end
  end

  def respond(client, status, content_type \\ "text/html", body) do
    Logger.debug("Responding with status #{status}")

    response = """
    HTTP/1.1 #{status} #{@status_names[status]}
    Content-Type: #{content_type}
    Content-Length: #{byte_size(body) + 1}\r\n\r
    #{body}
    """

    :gen_tcp.send(client, response)
  end
end
