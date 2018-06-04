defmodule Hormex.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: Hormex.Worker.start_link(arg)
      # {Hormex.Worker, arg},
      Supervisor.child_spec({Task, fn -> Hormex.Listener.listen(4040) end}, restart: :permanent)
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Hormex.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
