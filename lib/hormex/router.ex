defmodule Hormex.Router do
  @moduledoc """
  A `GenServer` that is used for routing
  requests to their proper destinations.

  Internally, this stores a map mapping routes 
  to the respective configured route options,
  as configurable through `Hormex.Router.add_route/3`.
  """

  use GenServer

  ## Client API

  @doc """
  Starts the `GenServer` of the Router,
  linked to the current process.

  ## Parameters

    - opts: options to be passed to `GenServer.start_link/3`.

  ## Examples

    # Start the router, linked to the current process
    {:ok, router} = Hormex.Router.start_link([])

  """
  @spec start_link(GenServer.options()) :: GenServer.on_start()
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @doc """
  Adds a new route to the router.
  This allow for runtime modification of active routes.

  ## Parameters

    - server: The `GenServer` router instance to operate on
    - path: The base path which the route should control
    - options: Options for the given route

  ## Examples

    iex> {:ok, pid} = Hormex.Router.start_link([])
    iex> options = %{location: "/var/www/web.site/static/"}
    iex> Hormex.Router.add_route(pid, "/static", options)
    iex> Hormex.Router.all_routes(pid)
    %{
      "/static" => %{
        location: "/var/www/web.site/static/"
      }
    }

  """
  @spec add_route(GenServer.server(), String.t(), Map.t()) :: :ok
  def add_route(server, path, options) do
    GenServer.cast(server, {:add, path, options})
  end

  @doc """
  Returns the internal map of all currently
  loaded routes on the Router.

  ## Parameters

    - server: The `GenServer` router instance to operate on

  ## Examples

    iex> {:ok, pid} = Hormex.Router.start_link([])
    iex> Hormex.Router.all_routes(pid)
    %{}
    iex> Hormex.Router.add_route(pid, "/test", %{location: "/var/www/example.com/"})
    iex> Hormex.Router.all_routes(pid)
    %{
      "/test" => %{
        location: "/var/www/example.com/"
      }
    }

  """
  @spec all_routes(GenServer.server()) :: Map.t()
  def all_routes(server) do
    GenServer.call(server, :fetchall)
  end

  @doc """
  Attempt to fetch a valid route for the
  given path from the internal route map.

  ## Parameters

    - server: The `GenServer` router instance to operate on

  ## Examples

    iex> {:ok, pid} = Hormex.Router.start_link([])
    iex> Hormex.Router.add_route(pid, "/static", %{location: "/path/to/static/"})
    iex> Hormex.Router.route_for(pid, "/static/index.html")
    {:ok, {"/static", %{location: "/path/to/static/"}}}
    iex> Hormex.Router.route_for(pid, "/unknown/path")
    {:error, "no matching route found"}

  """
  @spec route_for(GenServer.server(), String.t()) ::
          {:ok, {String.t(), Map.t()}} | {:error, String.t()}
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
