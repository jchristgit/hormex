defmodule Hormex.Listener do
  alias Hormex.Handler
  require Logger

  def accept_forever(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    {:ok, pid} = Task.Supervisor.start_child(Hormex.HandlerSupervisor, fn -> serve(client) end)
    :ok = :gen_tcp.controlling_process(client, pid)
    accept_forever(socket)
  end

  defp serve(client, packets \\ []) do
    next_line = :gen_tcp.recv(client, 0)

    case next_line do
      {:ok, :http_eoh} ->
        Handler.handle_request(client, packets)

      {:error, :closed} ->
        Handler.handle_request(client, packets)

      {:ok, {:http_error, bad_line}} ->
        Handler.respond(client, 400,
          "<h1>Bad Request</h1><p>Invalid HTTP line #{bad_line}</p>"
        )

      _ ->
        serve(client, packets ++ [next_line])
    end
  end
end
