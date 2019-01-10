defmodule SendInBlue.ContactTest do
  use ExUnit.Case

  setup do
    bypass = Bypass.open
    Application.put_env(SendInBlue, :api_base_url, "http://localhost:#{bypass.port}/v3/")
    {:ok, bypass: bypass}
  end

  test "create", %{bypass: bypass} do
    Bypass.expect_once bypass, "POST", "/v3/contacts/", fn conn ->
      {:ok, body, _} = Plug.Conn.read_body(conn)
      assert Jason.decode!(body) == %{
        "email" => "test@mail.com",
        "emailBlacklisted" => false,
        "listIds" => [0],
        "smsBlacklisted" => false,
        "smtpBlacklistSender" => []
      }
      Plug.Conn.resp(conn, 201, ~s<{"id": 5}>)
    end

    params = %{
      email: "test@mail.com",
      email_blacklisted: false,
      sms_blacklisted: false,
      list_ids: [0],
      smtp_blacklist_sender: []
    }
    assert {:ok, %{id: 5}} == SendInBlue.Contact.create(params)
  end

  test "create duplicate contact", %{bypass: bypass} do
    Bypass.expect_once bypass, "POST", "/v3/contacts/", fn conn ->
      Plug.Conn.resp(conn, 400, ~s<{"code": "duplicate_parameter", "message": "Contact already exist"}>)
    end

    assert {:error, %SendInBlue.Error{
      source: :send_in_blue,
      code: :duplicate_parameter,
      message: "Contact already exist"
    }} = SendInBlue.Contact.create(%{email: "test@mail.com"})
  end

  test "update", %{bypass: bypass} do
    Bypass.expect_once bypass, "PUT", "/v3/contacts/test@mail.com", fn conn ->
      Plug.Conn.resp(conn, 204, "")
    end

    params = %{
      email: "test@mail.com",
      attributes: %{"attr" => "value"}
    }
    assert :ok == SendInBlue.Contact.update(params)
  end

  test "delete", %{bypass: bypass} do
    Bypass.expect_once bypass, "DELETE", "/v3/contacts/test@mail.com", fn conn ->
      Plug.Conn.resp(conn, 204, "")
    end
    assert :ok == SendInBlue.Contact.delete(%{email: "test@mail.com"})
  end

  @contact_details """
    {
      "email": "test@mail.com",
      "id": 5,
      "emailBlacklisted": true,
      "smsBlacklisted": false,
      "modifiedAt": "2019-01-07T14:59:34.424+01:00",
      "attributes": {
        "FIRST_NAME": "first",
        "LAST_NAME": "last"
      },
      "listIds": [
        2
      ],
      "statistics": {
        "clicked": [
          {
            "campaignId": 1,
            "links": [
              {
                "count": 1,
                "eventTime": "2018-12-18T15:50:44.493+01:00",
                "ip": "123.456.489.123",
                "url": "https://dummy.com"
              }
            ]
          }
        ],
        "messagesSent": [
          {
            "campaignId": 1,
            "eventTime": "2018-12-18T15:47:01.108+01:00"
          }
        ],
        "unsubscriptions": {
          "userUnsubscription": [],
          "adminUnsubscription": [
            {
              "eventTime": "2019-01-07T14:59:34.424+01:00",
              "ip": "123.456.489.123"
            }
          ]
        },
        "opened": [
          {
            "campaignId": 1,
            "count": 1,
            "eventTime": "2018-12-18T15:49:42.309+01:00",
            "ip": "123.456.489.123"
          }
        ]
      }
    }
  """

  test "get", %{bypass: bypass} do
    Bypass.expect_once bypass, "GET", "/v3/contacts/test@mail.com", fn conn ->
      Plug.Conn.resp(conn, 200, @contact_details)
    end

    expected = %SendInBlue.Contact{
      attributes: %{"FIRST_NAME" => "first", "LAST_NAME" => "last"},
      email: "test@mail.com",
      email_blacklisted: true,
      id: 5,
      list_ids: [2],
      modified_at: "2019-01-07T14:59:34.424+01:00",
      sms_blacklisted: false,
      statistics: %{
        clicked: [
          %{
            "campaignId" => 1,
            "links" => [
              %{
                "count" => 1,
                "eventTime" => "2018-12-18T15:50:44.493+01:00",
                "ip" => "123.456.489.123",
                "url" => "https://dummy.com"
              }
            ]
          }
        ],
        messages_sent: [
          %{
            "campaignId" => 1,
            "eventTime" => "2018-12-18T15:47:01.108+01:00"
          }
        ],
        opened: [
          %{
            "campaignId" => 1,
            "count" => 1,
            "eventTime" => "2018-12-18T15:49:42.309+01:00",
            "ip" => "123.456.489.123"
          }
        ],
        unsubscriptions: %{
          "adminUnsubscription" => [
            %{
              "eventTime" => "2019-01-07T14:59:34.424+01:00",
              "ip" => "123.456.489.123"
            }
          ],
          "userUnsubscription" => []
        }
      }
    }
    assert {:ok, expected} == SendInBlue.Contact.get(%{email: "test@mail.com"})
  end

  @attributes """
    {
      "attributes": [
        {
          "name": "LASTNAME",
          "category": "normal",
          "type": "text"
        },
        {
          "name": "FIRSTNAME",
          "category": "normal",
          "type": "text"
        },
        {
          "name": "GENDER",
          "category": "category",
          "type": "text",
          "enumeration": [
            {
              "value": 1,
              "label": "Male"
            },
            {
              "value": 2,
              "label": "Female"
            }
          ]
        }
      ]
    }
  """

  test "get_attributes", %{bypass: bypass} do
    Bypass.expect_once bypass, "GET", "/v3/contacts/attributes", fn conn ->
      Plug.Conn.resp(conn, 200, @attributes)
    end
    assert SendInBlue.Contact.get_attributes() == {:ok, %{
      attributes: [
        %{
          "name" => "LASTNAME",
          "category" => "normal",
          "type" => "text"
        },
        %{
          "name" => "FIRSTNAME",
          "category" => "normal",
          "type" => "text"
        },
        %{
          "name" => "GENDER",
          "category" => "category",
          "type" => "text",
          "enumeration" => [
            %{
              "value" => 1,
              "label" => "Male"
            },
            %{
              "value" => 2,
              "label" => "Female"
            }
          ]
        }
      ]
    }}
  end
end