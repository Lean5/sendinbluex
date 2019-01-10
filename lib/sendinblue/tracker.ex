defmodule SendInBlue.Tracker do
  @moduledoc """
  A simple wrapper for the SendInBlue tracker api.

  Configuration:
  ```
  config SendInBlue.Tracker
    tracking_id: "<your marketing automation tracking id>"
  ```

  For more information about the SendInBlue tracker api see:
  https://tracker-doc.sendinblue.com/reference

  """

  import SendInBlue.Request, except: [make_request: 1]

  @spec identify(params, SendInBlue.options()) :: :ok | {:error, SendInBlue.Error.t()}
    when params: %{
      :email => String.t(),
      optional(:attributes) => map()
    } | %{}
  def identify(params, opts \\ []) do
    new_request(opts)
    |> put_endpoint("identify")
    |> put_params(params)
    |> make_request()
  end

  @spec track_event(params, SendInBlue.options()) :: :ok | {:error, SendInBlue.Error.t()}
    when params: %{
      :email => String.t(),
      :event => String.t(),
      optional(:properties) => map(),
      optional(:eventdata) => map()
    } | %{}
  def track_event(params, opts \\ []) do
    new_request(opts)
    |> put_endpoint("trackEvent")
    |> put_params(params)
    |> make_request()
  end

  @spec track_link(params, SendInBlue.options()) :: :ok | {:error, SendInBlue.Error.t()}
    when params: %{
      :email => String.t(),
      :link => String.t(),
      optional(:properties) => map()
    } | %{}
  def track_link(params, opts \\ []) do
    new_request(opts)
    |> put_endpoint("trackLink")
    |> put_params(params)
    |> make_request()
  end

  @spec track_page(params, SendInBlue.options()) :: :ok | {:error, SendInBlue.Error.t()}
    when params: %{
      :email => String.t(),
      :page => String.t(),
      optional(:properties) => map()
    } | %{}
  def track_page(params, opts \\ []) do
    new_request(opts)
    |> put_endpoint("trackPage")
    |> put_params(params)
    |> make_request()
  end

  defp make_request(request) do
    request
    |> put_method(:post)
    |> make_tracker_request()
  end
end
