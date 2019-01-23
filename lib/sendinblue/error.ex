defmodule SendInBlue.Error do
  @moduledoc """
  A struct which represents an error which occurred during a SendInBlue API call.

  This struct is designed to provide all the information needed to effectively log and maybe respond
  to an error.

  It contains the following fields:
  - `:source` – this is one of
    * `:internal` – the error occurred within the library. This is usually caused by an unexpected
      or missing parameter.
    * `:network` – the error occurred while making the network request (i.e. `:hackney.request/5`
      returned an error.) In this case, `:code` will always be `:network_error`. The
      `:hackney_reason` field in the `:extra` map contains the actual error reason received from
      hackney.
    * `:send_in_blue` – an error response was received from SendInBlue.
  - `:code` – an atom indicating the particular error.
  - `:message` – a loggable message describing the error. This should not be shown to your users
    but is intended for logging and troubleshooting.
  - `:extra` - a map which may contain some additional information about the error. See "Extra
    Fields" for details.

  ## Extra Fields
  The `:extra` field contains a map of miscellaneous information about the error which may be
  useful. The fields are not present if not relevant. The possible fields are:
  - `:param` – for errors where a particular parameter was the cause, indicates which parameter
    was invalid.
  - `:http_status` – for `:send_in_blue` errors, the HTTP status returned with the error.
  - `:http_body` – the raw body received from SendInBlue.
  - `:hackney_reason` – for `:network` errors, contains the error reason received from hackney.
  """

  @type error_source :: :internal | :network | :send_in_blue

  @type error_code :: :invalid_parameter
    | :missing_parameter
    | :out_of_range
    | :campaign_processing
    | :campaign_sent
    | :document_not_found
    | :reseller_permission_denied
    | :not_enough_credits
    | :permission_denied
    | :duplicate_parameter
    | :duplicate_request
    | :method_not_allowed
    | :unauthorized
    | :account_under_validation
    | :not_acceptable

  @type t :: %__MODULE__{
    source: error_source,
    code: error_code | :network_error | :invalid_result,
    message: String.t(),
    extra: %{
      optional(:http_status) => 400..599,
      optional(:http_body) => binary(),
      optional(:hackney_reason) => any(),
      optional(:parse_error) => any()
    }
  }

  @enforce_keys [:source, :code, :message]
  defstruct [:source, :code, :extra, :message]

  @doc false
  @spec new(Keyword.t()) :: t
  def new(fields) do
    struct!(__MODULE__, fields)
  end

  @doc false
  @spec from_hackney_error(any) :: t
  def from_hackney_error(reason) do
    %__MODULE__{
      source: :network,
      code: :network_error,
      message:
        "An error occurred while making the network request. The HTTP client returned the following reason: #{
          inspect(reason)
        }",
      extra: %{
        hackney_reason: reason
      }
    }
  end

  def from_send_in_blue_error(status, %{"code" => code, "message" => msg}) do
    %__MODULE__{
      source: :send_in_blue,
      code: String.to_atom(code),
      message: msg,
      extra: %{http_status: status}
    }
  end

  def could_not_decode(status, body, err) do
    %__MODULE__{
      source: :internal,
      code: :invalid_result,
      message: "Failed to parse result data.",
      extra: %{
        http_status: status,
        http_body: body,
        parse_error: err
      }
    }
  end
end
