defmodule Hormex.RouterTest do
  alias Hormex.Router
  use ExUnit.Case, async: true
  doctest Hormex.Router

  setup do
    %{router: start_supervised!(Hormex.Router)}
  end

  test "`route_for` for unknown route returns `nil`", %{router: router} do
    assert {:error, _reason} =
             Router.route_for(
               router,
               "/surely/non/existant/route/"
             )
  end

  test "`all_routes` returns an empty map", %{router: router} do
    assert Router.all_routes(router) == %{}
  end

  test "`add_route` properly adds a new route", %{router: router} do
    path = "/test"
    options = %{location: "/my/router/test/"}
    Router.add_route(router, path, options)

    assert Router.route_for(router, "/test") == {:ok, {path, options}}
    assert Router.route_for(router, "/test/me") == {:ok, {path, options}}
    assert Router.route_for(router, "/test/page.html") == {:ok, {path, options}}

    assert {:error, _reason} =
             Router.route_for(
               router,
               "/surely/non/existant/route/"
             )

    assert Router.all_routes(router) == %{path => options}
  end
end
