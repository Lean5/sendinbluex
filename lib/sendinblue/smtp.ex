defmodule SendInBlue.Smtp do
  @moduledoc """
  A simple wrapper for the SendInBlue SMTP api.
  """

  @smtp "smtp/"

  @typep person :: %{
    :email => String.t(),
    optional(:name) => String.t()
  }

  @typep attachment :: %{
    :url => String.t(),
    :name => String.t()
  } | %{
    :content => String.t(),
    :name => String.t()
  }

  import SendInBlue.Request

  @spec send(params, SendInBlue.options()) :: {:ok, %{message_id: String.t()}} | {:error, SendInBlue.Error.t()}
    when params: %{
      optional(:sender) => person(),
      optional(:to) => list(person()),
      optional(:bcc) => list(person()),
      optional(:cc) => list(person()),
      optional(:html_content) => String.t(),
      optional(:text_content) => String.t(),
      optional(:subject) => String.t(),
      optional(:reply_to) => person(),
      optional(:attachment) => list(attachment()),
      optional(:headers) => %{String.t() => String.t()},
      optional(:template_id) => non_neg_integer(),
      optional(:params) => %{String.t() => String.t()},
      optional(:tags) => list(String.t())
    }
  def send(params, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@smtp <> "email")
    |> put_params(params)
    |> put_method(:post)
    |> put_result_type(%{message_id: nil})
    |> make_request()
  end
end
