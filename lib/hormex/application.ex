defmodule Hormex.Application do
  @moduledoc false

  require Logger
  use Application

  @impl true
  @spec start(Supervisor.start_type(), term) :: Supervisor.on_start()
  def start(start_type, _args) do
    children = [
      {Task.Supervisor, name: Hormex.HandlerSupervisor},
      {Hormex.Router, name: Hormex.Router},
      Supervisor.child_spec({Task, fn -> Hormex.listen(4040) end}, restart: :permanent)
    ]

    opts = [strategy: :one_for_one, name: Hormex.Supervisor]
    link_result = Supervisor.start_link(children, opts)

    case link_result do
      {:ok, pid} ->
        case start_type do
          :normal ->
            Logger.info("Started main supervisor normally, running as #{inspect(pid)}")

          {:takeover, node} ->
            Logger.info(
              "Started main supervisor as takeover from #{inspect(node)}, running as #{
                inspect(pid)
              }"
            )

          {:failover, node} ->
            Logger.info(
              "Started main supervisor as failover from #{inspect(node)}, running as #{
                inspect(pid)
              }"
            )
        end

      {:error, {:shutdown, reason}} ->
        Logger.error("Supervisor terminating, reason #{reason}")

      {:error, {:already_started, pid}} ->
        Logger.error("Cannot start application, already running at #{inspect(pid)}")
    end

    link_result
  end

  @impl true
  def stop(_state) do
    Logger.info("Stopping main supervisor.")
  end
end
