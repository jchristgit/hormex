defmodule Hormex.Application do
  require Logger
  use Application

  def start(_type, _args) do
    children = [
      {Task.Supervisor, name: Hormex.HandlerSupervisor},
      Supervisor.child_spec({Task, fn -> Hormex.listen(4040) end}, restart: :permanent)
    ]

    opts = [strategy: :one_for_one, name: Hormex.Supervisor]
    Logger.info("Starting up main supervisor.")
    Supervisor.start_link(children, opts)
  end

  def stop(_state) do
    Logger.info("Stopping main supervisor.")
  end
end
