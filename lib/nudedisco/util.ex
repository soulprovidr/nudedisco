defmodule Nudedisco.Util do
  @moduledoc false

  require Logger

  @doc """
  Parse a date string in the provided format and return a DateTime struct in UTC.
  """
  @spec parse_date_in_utc(String.t(), String.t()) :: DateTime.t()
  def parse_date_in_utc(date, format \\ "{RFC1123}") do
    date
    |> Timex.parse!(format)
    |> DateTime.shift_zone!("Etc/UTC")
  end

  @spec request(
          :delete | :get | :head | :options | :patch | :post | :put,
          binary(),
          any(),
          any(),
          keyword()
        ) :: :error | {:ok, any()}
  @doc """
  Make an HTTP request. Wrapper around HTTPoison.request/4.
  """
  @spec request(:delete | :get | :head | :options | :patch | :post | :put, binary, any, any) ::
          :error | {:ok, any}
  def request(method, url, body \\ "", headers \\ [], options \\ []) do
    case HTTPoison.request(method, url, body, headers, options) do
      {:ok, %HTTPoison.Response{status_code: status_code, body: body}}
      when status_code in 200..299 ->
        {:ok, body}

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        Logger.error("[Util.request] Request failed with status code: #{status_code}")
        IO.inspect(body)
        :error

      {:error, error} ->
        Logger.error("[Util.request] Request failed: #{method} #{url}")
        IO.inspect(error)
        :error
    end
  end
end
