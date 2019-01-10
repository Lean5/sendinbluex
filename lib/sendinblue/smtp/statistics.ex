defmodule SendInBlue.Smtp.Statistics do

  defmodule Report do
    use SendInBlue.Entity, [
      date: Date.t(),
      requests: non_neg_integer(),
      delivered: non_neg_integer(),
      hard_bounces: non_neg_integer(),
      soft_bounces: non_neg_integer(),
      clicks: non_neg_integer(),
      unique_clicks: non_neg_integer(),
      opens: non_neg_integer(),
      unique_opens: non_neg_integer(),
      spam_reports: non_neg_integer(),
      blocked: non_neg_integer(),
      invalid: non_neg_integer(),
      unsubscribed: non_neg_integer(),
    ]
  end

  defmodule AggregatedReport do
    use SendInBlue.Entity, [
      range: String.t(),
      requests: non_neg_integer(),
      delivered: non_neg_integer(),
      hard_bounces: non_neg_integer(),
      soft_bounces: non_neg_integer(),
      clicks: non_neg_integer(),
      unique_clicks: non_neg_integer(),
      opens: non_neg_integer(),
      unique_opens: non_neg_integer(),
      spam_reports: non_neg_integer(),
      blocked: non_neg_integer(),
      invalid: non_neg_integer(),
      unsubscribed: non_neg_integer(),
    ]
  end

  alias __MODULE__
  import SendInBlue.Request

  @statistics "smtp/statistics/"

  @spec get_reports(params, SendInBlue.options()) :: {:ok, %{reports: list(Statistics.Report.t())}} | {:error, SendInBlue.Error.t()}
    when params: %{
      optional(:limit) => non_neg_integer(),
      optional(:offset) => non_neg_integer(),
      optional(:start_date) => Date.t(),
      optional(:end_date) => Date.t(),
      optional(:days) => pos_integer,
      optional(:tag) => String.t(),
    } | %{}
  def get_reports(params \\ %{}, opts \\ [])
  do
    new_request(opts)
    |> put_endpoint(@statistics <> "reports")
    |> put_params(params)
    |> put_method(:get)
    |> put_result_type(%{reports: [Statistics.Report]})
    |> make_request()
  end

  @spec get_aggregated_reports(params, SendInBlue.options()) :: {:ok, Statistics.AggregatedReport.t()} | {:error, SendInBlue.Error.t()}
    when params: %{
      optional(:limit) => non_neg_integer(),
      optional(:offset) => non_neg_integer(),
      optional(:start_date) => Date.t(),
      optional(:end_date) => Date.t(),
      optional(:days) => pos_integer,
      optional(:tag) => String.t(),
    } | %{}
  def get_aggregated_reports(params \\ %{}, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@statistics <> "aggregatedReport")
    |> put_params(params)
    |> put_method(:get)
    |> put_result_type(Statistics.AggregatedReport)
    |> make_request()
  end
end