defmodule Hormex.Listener do
  def accept_forever(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    {:ok, pid} = Task.Supervisor.start_child(Hormex.HandlerSupervisor, fn -> serve(client) end)
    # :ok = :gen_tcp.controlling_process(client, pid)
    accept_forever(socket)
  end

  defp serve(client, request \\ []) do
    IO.inspect request
    next_line = :gen_tcp.recv(client, 0)
    case next_line do
      {:ok, :http_eoh} ->
        :gen_tcp.send(client, "HTTP/1.0 200 OK\nContent-Type: text/html\nContent-Length: 5\n\nhello")
        :gen_tcp.close(client)
      {:error, :closed} ->
        :gen_tcp.send(client, "HTTP/1.0 200 OK\nContent-Type: text/html\nContent-Length: 5\n\nhello")
        :gen_tcp.close(client)
      _ ->
        serve(client, request ++ [next_line])
    end
  end
end
