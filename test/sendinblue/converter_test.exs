defmodule SendInBlue.ConverterTest do
  use ExUnit.Case

  describe "convert" do
    test "creates struct from data" do
      data = %{
        "attributes" => %{
          "FIRST_NAME" => "first",
          "LAST_NAME" => "last",
        },
        "email" => "test@mail.com",
        "emailBlacklisted" => false,
        "id" => 12,
        "listIds" => [],
        "modifiedAt" => "2019-01-14T09:03:32.638+01:00",
        "smsBlacklisted" => false,
        "statistics" => %{}
      }
      expected = %SendInBlue.Contact{
        attributes: %{"FIRST_NAME" => "first", "LAST_NAME" => "last"},
        email: "test@mail.com",
        email_blacklisted: false,
        id: 12,
        list_ids: [],
        modified_at: "2019-01-14T09:03:32.638+01:00",
        sms_blacklisted: false,
        statistics: %{
          clicked: nil,
          messages_sent: nil,
          opened: nil,
          unsubscriptions: nil
        }
      }
      assert expected == SendInBlue.Converter.convert(data, SendInBlue.Contact)
    end

    test "creates generic map from data" do
      data = %{
        "attributes" => [
          %{
            "calculatedValue" => "COUNT[BLACKLISTED,BLACKLISTED,<,NOW()]",
            "category" => "global",
            "name" => "BLACKLIST",
            "type" => "float"
          },
          %{
            "calculatedValue" => "COUNT[READERS,READERS,<,NOW()]",
            "category" => "global",
            "name" => "READERS",
            "type" => "float"
          },
          %{
            "calculatedValue" => "COUNT[CLICKERS,CLICKERS,<,NOW()]",
            "category" => "global",
            "name" => "CLICKERS",
            "type" => "float"
          },
          %{"category" => "normal", "name" => "NAME", "type" => "text"}
        ]
      }

      expected = %{attributes: data["attributes"]}
      assert expected == SendInBlue.Converter.convert(data, %{attributes: [nil]})  
    end
  end
end