defmodule SendInBlue do
  @moduledoc """
  A HTTP client for SendInBlue.

  ## Configuration

  ### API Key
  You need to set your API key in your application configuration. Typically
  this is done in `config/config.exs` or a similar file. For example:
      config :sendinbluex, api_key: "abc123456789"
  You can also utilize `System.get_env/1` to retrieve the API key from an
  environment variable, but remember that this can cause issues if you use
  a release tool like exrm or Distillery.
      config :sendinbluex, api_key: System.get_env("SEND_IN_BLUE_API_KEY")

  ### Marketing Automation Tracking
  The Tracker API uses a different key that has to be configured separately:
      config :sendinbluex, tracking_id: "abc123456789"

  ### HTTP Connection Pool
  SendInBlue is set up to use an HTTP connection pool by default. This means
  that it will reuse already opened HTTP connections in order to minimize the
  overhead of establishing connections. The pool is directly supervised by
  SendInBlue. Two configuration options are available to tune how this pool
  works: `:timeout` and `:max_connections`.
  `:timeout` is the amount of time that a connection will be allowed to
  remain open but idle (no data passing over it) before it is closed and
  cleaned up. This defaults to 5 seconds.
  `:max_connections` is the maximum number of connections that can be open
  at any time. This defaults to 10.
  Both these settings are located under the `:pool_options` key in your
  application configuration:
      config :sendinbluex, :pool_options,
        timeout: 5_000,
        max_connections: 10
  If you prefer, you can also turn pooling off completely using the
  `:use_connection_pool` setting:
      config :sendinbluex, use_connection_pool: false
  """
  use Application

  @type id :: pos_integer()
  @type date_query :: %{
                   optional(:gt) => timestamp,
                   optional(:gte) => timestamp,
                   optional(:lt) => timestamp,
                   optional(:lte) => timestamp
                 }
  @type options :: Keyword.t()
  @type timestamp :: pos_integer

  @doc """
  Callback for the application
  Start the supervision tree including the supervised HTTP connection pool
  (if it's being used) when the VM loads the application pool.
  Note that we are taking advantage of the BEAM application standard in order
  to start the pool when the application is started. While we do start a
  supervisor, the supervisor is only to comply with the expectations of the
  BEAM application standard. It is not given any children to supervise.
  """
  @spec start(Application.start_type(), any) :: {:error, any} | {:ok, pid} | {:ok, pid, any}
  def start(_start_type, _args) do
    children = SendInBlue.Api.supervisor_children()
    opts = [strategy: :one_for_one, name: SendInBlue.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
