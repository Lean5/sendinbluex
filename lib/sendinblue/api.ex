defmodule SendInBlue.Api do
  @moduledoc """
  Low-level utilities for interacting with the SendInBlue API.
  Usually the utilities in `SendInBlue.Request` are a better way to write
  custom interactions with the API.
  """
  alias SendInBlue.Error

  @type method :: :get | :post | :put | :delete | :patch
  @type headers :: %{String.t() => String.t()} | %{}
  @type body :: iodata() | {:multipart, list()}
  @typep http_success :: {:ok, integer, [{String.t(), String.t()}], String.t()}
  @typep http_failure :: {:error, term}

  @pool_name __MODULE__
  @http_module Application.get_env(:sendinbluex, :http_module) || :hackney

  def supervisor_children do
    if use_pool?(),
      do: [:hackney_pool.child_spec(@pool_name, get_pool_options())],
      else: []
  end

  @doc """
  A low level utility function to make a direct request to the SendInBlue API.
  """
  @spec request(body, method, String.t(), headers, list) :: {:ok, map} | {:error, SendInBlue.Error.t()}
  def request(body, :get, endpoint, headers, opts) do
    req_url = get_base_url() <> endpoint

    req_url =
      body
      |> SendInBlue.Utils.camelize_keys()
      |> URI.encode_query()
      |> prepend_url(req_url)

    perform_request(req_url, :get, "", headers, opts)
  end

  def request(body, method, endpoint, headers, opts) do
    req_url = get_base_url() <> endpoint

    req_body =
      body
      |> SendInBlue.Utils.camelize_keys()
      |> Jason.encode!()

    perform_request(req_url, method, req_body, headers, opts)
  end

  @doc """
  A low level utility function to make a direct request to the SendInBlue tracker API.
  """
  def tracker_request(body, :post, endpoint, headers, opts) do
    req_url = get_tracker_base_url() <> endpoint

    req_body =
      body
      |> SendInBlue.Utils.camelize_keys()
      |> Jason.encode!()

    opts = Keyword.put_new(opts, :api_key, get_default_tracking_id())
    perform_request(req_url, :post, req_body, headers, opts)
  end

  @spec get_pool_options() :: Keyword.t()
  defp get_pool_options(), do: Application.get_env(:sendinbluex, :pool_options)

  @spec get_base_url() :: String.t()
  defp get_base_url(), do: Application.get_env(:sendinbluex, :api_base_url)

  @spec get_tracker_base_url() :: String.t()
  defp get_tracker_base_url(), do: Application.get_env(:sendinbluex, :tracker_base_url)

  @spec get_default_api_key() :: String.t()
  defp get_default_api_key() do
    case Application.get_env(:sendinbluex, :api_key) do
      nil -> "" # use an empty string and let SendInBlue produce an error
      key -> key
    end
  end

  @spec get_default_tracking_id() :: {String.t(), String.t()}
  defp get_default_tracking_id() do
    key = case Application.get_env(:sendinbluex, :tracking_id) do
      nil -> "" # use an empty string and let SendInBlue produce an error
      key -> key
    end
    {"ma-key", key}
  end

  @spec use_pool?() :: boolean
  defp use_pool?(), do: Application.get_env(:sendinbluex, :use_connection_pool)

  @spec perform_request(String.t(), method, body, headers, list) :: {:ok, map} | {:error, SendInBlue.Error.t()}
  defp perform_request(req_url, method, body, headers, opts) do    
    {api_key, opts} = Keyword.pop(opts, :api_key)

    req_headers =
      headers
      |> add_default_headers()
      |> add_auth_header(api_key)
      |> Map.to_list()

    req_opts =
      opts
      |> add_default_options()
      |> add_pool_option()

    @http_module.request(method, req_url, req_headers, body, req_opts)
    |> handle_response()
  end

  @spec add_default_headers(headers) :: headers
  defp add_default_headers(existing_headers) do
    existing_headers
    |> Map.merge(%{
        "accept" => "application/json",
        "connection" => "keep-alive"
      })
    |> Map.put_new("content-type", "application/json")
  end

  @spec add_auth_header(headers, nil | String.t() | {String.t(), String.t()}) :: headers
  defp add_auth_header(existing_headers, {name, key}) when is_binary(name) and is_binary(key) do
    Map.put(existing_headers, name, key)
  end

  defp add_auth_header(existing_headers, api_key) do
    api_key = case api_key do
        key when is_binary(key) -> key
        _ -> get_default_api_key()
      end
    Map.put(existing_headers, "api-key", api_key)
  end

  @spec add_default_options(list) :: list
  defp add_default_options(opts) do
    [{:connect_timeout, 24000}, {:recv_timeout, 20000}, :with_body | opts]
  end

  @spec add_pool_option(list) :: list
  defp add_pool_option(opts) do
    if use_pool?(),
      do: [{:pool, @pool_name} | opts],
      else: opts
  end

  @spec handle_response(http_success | http_failure) :: {:ok, map} | {:error, SendInBlue.Error.t()}
  defp handle_response({:ok, status, _headers, body}) when status >= 200 and status <= 299 do
    if body == "",
      do: :ok,
      else: {:ok, Jason.decode!(body)}
  end

  defp handle_response({:ok, status, _headers, body}) when status >= 300 and status <= 599 do
    error =
      case Jason.decode(body) do
        {:ok, %{"code" => _, "message" => _} = api_error} ->
          Error.from_send_in_blue_error(status, api_error)

        {:error, _} = err ->
          Error.could_not_decode(status, body, err)
      end

    {:error, error}
  end

  defp handle_response({:error, reason}) do
    error = SendInBlue.Error.from_hackney_error(reason)
    {:error, error}
  end

  defp prepend_url("", url), do: url
  defp prepend_url(query, url), do: "#{url}?#{query}"
end
