defmodule Hormex.Listener do
  def listen(port) do
    options = [:binary, packet: :http, active: false]
    {:ok, socket} = :gen_tcp.listen(port, options)
    accept_forever(socket)
  end

  defp accept_forever(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    serve(client)
    accept_forever(socket)
  end

  defp serve(client) do
    :gen_tcp.send(client, "HTTP/1.0 200 OK\nContent-Type: text/html\nContent-Length: 5\n\nhello")
  end
end
