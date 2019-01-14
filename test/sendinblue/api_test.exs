defmodule SendInBlue.ApiTest do
  use ExUnit.Case

  @api_key "<api-key>"
  @tracking_id "<tracking-id>"

  setup do
    bypass = Bypass.open

    Application.put_env(:sendinbluex, :api_base_url, "http://localhost:#{bypass.port}/")
    Application.put_env(:sendinbluex, :api_key, @api_key)
    Application.put_env(:sendinbluex, :tracker_base_url, "http://localhost:#{bypass.port}/")
    Application.put_env(:sendinbluex, :tracking_id, @tracking_id)

    {:ok, bypass: bypass}
  end

  describe "request" do
    test "get request correctly encodes query in url and passes correct headers", %{bypass: bypass} do
      Bypass.expect_once bypass, "GET", "/testendpoint", fn conn ->
        conn = Plug.Conn.fetch_query_params(conn)

        assert conn.query_params == %{"param" => "value"}
        assert Plug.Conn.get_req_header(conn, "api-key") == [@api_key]
        assert Plug.Conn.get_req_header(conn, "accept") == ["application/json"]
        assert Plug.Conn.get_req_header(conn, "content-type") == ["application/json"]

        Plug.Conn.resp(conn, 200, "")
      end

      SendInBlue.Api.request(%{param: "value"}, :get, "testendpoint", %{}, [])
    end

    test "post request correctly encodes query and passes correct headers", %{bypass: bypass} do
      Bypass.expect_once bypass, "POST", "/testendpoint", fn conn ->
        {:ok, body, _} = Plug.Conn.read_body(conn)

        assert Jason.decode!(body) == %{"param" => "value"}
        assert Plug.Conn.get_req_header(conn, "api-key") == [@api_key]
        assert Plug.Conn.get_req_header(conn, "accept") == ["application/json"]
        assert Plug.Conn.get_req_header(conn, "content-type") == ["application/json"]

        Plug.Conn.resp(conn, 200, "")
      end

      SendInBlue.Api.request(%{param: "value"}, :post, "testendpoint", %{}, [])
    end
  end

  describe "tracker_request" do
    test "post request correctly encodes query and passes correct headers", %{bypass: bypass} do
      Bypass.expect_once bypass, "POST", "/testendpoint", fn conn ->
        {:ok, body, _} = Plug.Conn.read_body(conn)

        assert Jason.decode!(body) == %{"param" => "value"}
        assert Plug.Conn.get_req_header(conn, "ma-key") == [@tracking_id]
        assert Plug.Conn.get_req_header(conn, "accept") == ["application/json"]
        assert Plug.Conn.get_req_header(conn, "content-type") == ["application/json"]

        Plug.Conn.resp(conn, 200, "")
      end

      SendInBlue.Api.tracker_request(%{param: "value"}, :post, "testendpoint", %{}, [])
    end
  end
end