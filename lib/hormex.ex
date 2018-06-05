defmodule Hormex do
  alias Hormex.Listener
  require Logger

  @doc """
  Start the TCP listener on the given port.
  """
  def listen(port) do
    options = [:binary, packet: :http, active: false, reuseaddr: true]
    {:ok, socket} = :gen_tcp.listen(port, options)
    Logger.info("Listening on port #{port}")
    Listener.accept_forever(socket)
  end
end
