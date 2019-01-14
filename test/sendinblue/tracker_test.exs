defmodule SendInBlue.TrackerTest do
  use ExUnit.Case

  setup do
    bypass = Bypass.open

    Application.put_env(:sendinbluex, :tracker_base_url, "http://localhost:#{bypass.port}/api/v2/")

    {:ok, bypass: bypass}
  end

  test "identify", %{bypass: bypass} do
    Bypass.expect_once bypass, "POST", "/api/v2/identify", fn conn ->
      {:ok, body, _} = Plug.Conn.read_body(conn)
      assert Jason.decode!(body) == %{"email" => "test@mail.com"}
      Plug.Conn.resp(conn, 204, "")
    end
    assert :ok == SendInBlue.Tracker.identify(%{email: "test@mail.com"})
  end

  test "identify with empty email", %{bypass: bypass} do
    Bypass.expect_once bypass, "POST", "/api/v2/identify", fn conn ->
      Plug.Conn.resp(conn, 400, ~s<{"code": "request", "message": "email is empty" }>)
    end
    assert {:error, %SendInBlue.Error{
      source: :send_in_blue,
      code: :request,
      message: "email is empty"
    }} = SendInBlue.Tracker.identify(%{email: ""})
  end

  test "track_event", %{bypass: bypass} do
    Bypass.expect_once bypass, "POST", "/api/v2/trackEvent", fn conn ->
      {:ok, body, _} = Plug.Conn.read_body(conn)
      assert Jason.decode!(body) == %{
        "email" => "test@mail.com",
        "event" => "myevent",
        "eventdata" => %{"data" => "qwert"},
        "properties" => %{"blubb" => 123}
      }
      Plug.Conn.resp(conn, 204, "")
    end
    params = %{
      email: "test@mail.com",
      event: "myevent",
      properties: %{"blubb" => 123},
      eventdata: %{"data" => "qwert"},
    }
    assert :ok == SendInBlue.Tracker.track_event(params)
  end

  test "track_link", %{bypass: bypass} do
    Bypass.expect_once bypass, "POST", "/api/v2/trackLink", fn conn ->
      {:ok, body, _} = Plug.Conn.read_body(conn)
      assert Jason.decode!(body) == %{
        "email" => "test@mail.com",
        "link" => "some-link",
        "properties" => %{"blubb" => 123}
      }
      Plug.Conn.resp(conn, 204, "")
    end
    params = %{
      email: "test@mail.com",
      link: "some-link",
      properties: %{"blubb" => 123},
    }
    assert :ok == SendInBlue.Tracker.track_link(params)
  end

  test "track_page", %{bypass: bypass} do
    Bypass.expect_once bypass, "POST", "/api/v2/trackPage", fn conn ->
      {:ok, body, _} = Plug.Conn.read_body(conn)
      assert Jason.decode!(body) == %{
        "email" => "test@mail.com",
        "page" => "some-page",
        "properties" => %{"blubb" => 123}
      }
      Plug.Conn.resp(conn, 204, "")
    end
    params = %{
      email: "test@mail.com",
      page: "some-page",
      properties: %{"blubb" => 123},
    }
    assert :ok == SendInBlue.Tracker.track_page(params)
  end
end