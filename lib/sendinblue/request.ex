defmodule SendInBlue.Request do
  @moduledoc """
  A module for working with requests to the SendInBlue API.
  Requests are composed in a functional manner. The request does not happen
  until it is configured and passed to `make_request/1` or `make_tracker_request/1`.
  Generally intended to be used internally, but can also be used by end-users to
  work around missing endpoints (if any).
  At a minimum, a request must have the endpoint and method specified to be valid.
  """
  alias SendInBlue.{Api, Converter, Request}

  @type t :: %__MODULE__{
    endpoint: String.t() | nil,
    headers: map() | nil,
    method: SendInBlue.Api.method() | nil,
    opts: Keyword.t() | nil,
    params: map(),
    result_type: any
  }

  @type error_code :: :endpoint_fun_invalid_result | :invalid_endpoint

  defstruct [
    endpoint: nil,
    headers: nil,
    method: nil,
    opts: [],
    params: %{},
    result_type: nil
  ]

  @doc """
  Creates a new request.
  Optionally accepts options for the request, such as using a specific API key.
  See `t:SendInBlue.options` for details.
  """
  @spec new_request(SendInBlue.options(), map) :: t
  def new_request(opts \\ [], headers \\ %{}) do
    %Request{opts: opts, headers: headers}
  end

  @doc """
  Specifies an endpoint for the request.
  The endpoint should not include the version prefix or an initial slash.
  The endpoint can be a binary or a function which takes the parameters of the
  query and returns an endpoint. The function is not evaluated until just
  before the request is made so the actual parameters can be specified after
  the endpoint.
  """
  @spec put_endpoint(t, String.t()) :: t
  def put_endpoint(%Request{} = request, endpoint) do
    %{request | endpoint: endpoint}
  end

  @doc """
  Specifies a method to use for the request.
  Accepts any of the standard HTTP methods as atoms, that is `:get`, `:post`,
  `:put`, `:patch` or `:delete`.
  """
  @spec put_method(t, SendInBlue.Api.method()) :: t
  def put_method(%Request{} = request, method) when method in [:get, :post, :put, :patch, :delete] do
    %{request | method: method}
  end

  @doc """
  Specifies the parameters to be used for the request.
  If the request is a POST request, these are encoded in the request body.
  Otherwise, they are encoded in the URL.
  Calling this function multiple times will merge, not replace, the params
  currently specified.
  """
  @spec put_params(t, map) :: t
  def put_params(%Request{params: params} = request, new_params) do
    new_params = Map.delete(new_params, :__struct__)
    %{request | params: Map.merge(params, new_params)}
  end

  @doc """
  Specify a single param to be included in the request.
  """
  @spec put_param(t, atom, any) :: t
  def put_param(%Request{params: params} = request, key, value) do
    %{request | params: Map.put(params, key, value)}
  end

  @doc """
  Specifies the structure of the result type. This information is used to
  parse the JSON returned by the request.
  """
  @spec put_result_type(t, any) :: t
  def put_result_type(%Request{} = request, result_type) do
    %{request | result_type: result_type}
  end

  @doc """
  Executes the request and returns the response.
  """
  @spec make_request(t) :: {:ok, struct} | {:error, SendInBlue.Error.t()}
  def make_request(%Request{params: params, endpoint: endpoint, method: method, headers: headers, result_type: result_type, opts: opts}) do
    with {:ok, endpoint} <- consolidate_endpoint(endpoint, params),
         {:ok, result} <- Api.request(params, method, endpoint, headers, opts) do
      {:ok, Converter.convert(result, result_type)}
    end
  end

  @doc """
  Executes the request and returns the response for the tracker API.
  """
  @spec make_tracker_request(t) :: {:ok, struct} | {:error, SendInBlue.Error.t()}
  def make_tracker_request(%Request{params: params, endpoint: endpoint, method: method, headers: headers, result_type: result_type, opts: opts}) do
    with {:ok, endpoint} <- consolidate_endpoint(endpoint, params),
         {:ok, result} <- Api.tracker_request(params, method, endpoint, headers, opts) do
      {:ok, Converter.convert(result, result_type)}
    end
  end

  defp consolidate_endpoint(endpoint, _) when is_binary(endpoint),
    do: {:ok, endpoint}

  defp consolidate_endpoint(endpoint_fun, params) when is_function(endpoint_fun, 1) do
    case endpoint_fun.(params) do
      result when is_binary(result) ->
        {:ok, result}

      invalid ->
        {:error, SendInBlue.Error.new(
          source: :internal,
          code: :endpoint_fun_invalid_result,
          message: "calling the endpoint function produced an invalid result of #{inspect(invalid)} "
        )}
    end
  end

  defp consolidate_endpoint(_, _) do
    {:error, SendInBlue.Error.new(
      source: :internal,
      code: :invalid_endpoint,
      message: "endpoint must be a string or a function from params to a string"
    )}
  end
end