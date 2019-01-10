defmodule SendInBlue.Contact.Statistics do
    use SendInBlue.Entity, [
      messages_sent: list(map()),
        #{
        #  "campaignId": 21,
        #  "eventTime": "2016-05-03T20:15:13Z"
        #}
      opened: list(map()),
        #{
        #  "campaignId": 21,
        #  "count": 2,
        #  "eventTime": "2016-05-03T21:24:56Z",
        #  "ip": "123.456.489.123"
        #}
      clicked: list(map()),
        #{
        #  "campaignId": 21,
        #  "links": [{
        #      "count": 2,
        #      "eventTime": "2016-05-03T21:25:01Z",
        #      "ip": "123.456.489.123"
        #      "url": "https://url.domain.com/fbe5387ec717e333628380454f68670010b205ff/1/go?uid={EMAIL}&utm_source=sendinblue&utm_campaign=test_camp&utm_medium=email"
        #  }]
        #}
      unsubscriptions: map(),
        #{
        #  "adminUnsubscription": [
        #    {
        #      "eventTime": "2019-01-07T14:59:34.424+01:00",
        #      "ip": "123.456.489.123"
        #    }
        #  ],
        #  "userUnsubscription": []
        #}
    ]
  end