defmodule Hormex.Router do
  use Agent

  @routes %{
    "/" => %{
      :location => "./example"
    }
  }

  def start_link(opts) do
    Agent.start_link(fn -> @routes end, opts)
  end

  def route_for(router \\ __MODULE__, path) do
    route =
      Agent.get(router, &Map.keys(&1))
      |> Enum.find(&String.starts_with?(path, &1))

    case Agent.get(router, &Map.get(&1, route)) do
      nil -> {:err, "no route for path #{path}"}
      match -> {:ok, {route, match}}
    end
  end
end
