defmodule SendInBlue.Contact do
  use SendInBlue.Entity, [
    email: String.t(),
    id: SendInBlue.id(),
    email_blacklisted: boolean(),
    sms_blacklisted: boolean(),
    modified_at: DateTime.t(),
    attributes: map(),
    list_ids: list(SendInBlue.id()),
    statistics: SendInBlue.Contact.Statistics.t()
  ]

  alias __MODULE__
  import SendInBlue.Request

  @contacts "contacts/"

  @spec create(params, SendInBlue.options()) :: {:ok, %{id: SendInBlue.id()}} | {:error, SendInBlue.Error.t()}
    when params: %{
      :email => String.t(),
      optional(:attributes) => map(),
      optional(:email_blacklisted) => boolean(),
      optional(:sms_blacklisted) => boolean(),
      optional(:list_ids) => list(SendInBlue.id()),
      optional(:unlink_list_ids) => list(SendInBlue.id()),
      optional(:smtp_blacklist_sender) => list(String.t()),
    }
  def create(params, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@contacts)
    |> put_params(params)
    |> put_method(:post)
    |> put_result_type(%{id: nil})
    |> make_request()
  end

  @spec update(params, SendInBlue.options()) :: :ok | {:error, SendInBlue.Error.t()}
    when params: %{
      :email => String.t(),
      optional(:attributes) => map(),
      optional(:email_blacklisted) => boolean(),
      optional(:sms_blacklisted) => boolean(),
      optional(:list_ids) => list(SendInBlue.id()),
      optional(:update_enabled) => boolean(),
      optional(:smtp_blacklist_sender) => list(String.t()),
    }
  def update(params, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@contacts <> params.email)
    |> put_params(params)
    |> put_method(:put)
    |> make_request()
  end

  @spec delete(params, SendInBlue.options()) :: :ok | {:error, SendInBlue.Error.t()}
    when params: %{
      :email => String.t()
    }
  def delete(params, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@contacts <> params.email)
    |> put_params(params)
    |> put_method(:delete)
    |> make_request()
  end

  @spec get(params, SendInBlue.options()) :: {:ok, Contact.t()} | {:error, SendInBlue.Error.t()}
    when params: %{
      :email => String.t()
    }
  def get(params, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@contacts <> params.email)
    |> put_params(params)
    |> put_method(:get)
    |> put_result_type(Contact)
    |> make_request()
  end

  @spec list(params, SendInBlue.options()) :: {:ok, %{contacts: [Contact.t()]}} | {:error, SendInBlue.Error.t()}
    when params: %{
      optional(:limit) => non_neg_integer(),
      optional(:offset) => non_neg_integer()
    }
  def list(params \\ %{}, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@contacts)
    |> put_params(params)
    |> put_method(:get)
    |> put_result_type(%{contacts: [Contact]})
    |> make_request()
  end

  @spec get_attributes(SendInBlue.options()) :: {:ok, %{attributes: list(map())}} | {:error, SendInBlue.Error.t()}
  def get_attributes(opts \\ []) do
    new_request(opts)
    |> put_endpoint(@contacts <> "attributes")
    |> put_method(:get)
    |> put_result_type(%{attributes: [nil]})
    |> make_request()
  end
end