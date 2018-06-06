defmodule Hormex.Router do
  use GenServer

  ## Client API

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def add_route(server, path, options) do
    GenServer.cast(server, {:add, path, options})
  end

  def all_routes(server) do
    GenServer.call(server, :fetchall)
  end

  def route_for(server, path) do
    GenServer.call(server, {:lookup, path})
  end

  ## Server Callbacks

  @impl true
  def init(:ok) do
    {:ok, %{}}
  end

  @impl true
  def handle_call(:fetchall, _from, routes) do
    {:reply, routes, routes}
  end

  @impl true
  def handle_call({:lookup, path}, _from, routes) do
    route =
      Map.keys(routes)
      |> Enum.find(&String.starts_with?(path, &1))

    case Map.get(routes, route) do
      nil -> {:reply, {:error, "no matching route found"}, routes}
      match -> {:reply, {:ok, {route, match}}, routes}
    end
  end

  @impl true
  def handle_cast({:add, path, options}, routes) do
    {:noreply, Map.put(routes, path, options)}
  end
end
