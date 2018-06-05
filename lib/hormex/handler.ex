defmodule Hormex.Handler do
  require Logger

  def handle_request(client, packets) do
    log_request_info(packets)
    :gen_tcp.send(client, "HTTP/1.0 200 OK\nContent-Type: text/html\nContent-Length: 5\n\nhello")
    :gen_tcp.close(client)
  end

  defp log_request_info(packets) do
    [{:ok, {:http_request, method, {:abs_path, path}, {major, minor}}} | _rest] = packets
    Logger.debug "#{method} #{path} HTTP/#{major}.#{minor}"
  end
end
