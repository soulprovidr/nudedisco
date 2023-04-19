defmodule Nudedisco.Util do
  @moduledoc false

  @doc """
  Make an HTTP request. Wrapper around HTTPoison.request/4.
  """
  @spec request(:delete | :get | :head | :options | :patch | :post | :put, binary, any, any) ::
          :error | {:ok, any}
  def request(method, url, body \\ "", headers \\ []) do
    case HTTPoison.request(method, url, body, headers) do
      {:ok, %HTTPoison.Response{status_code: status_code, body: body}}
      when status_code in 200..299 ->
        {:ok, body}

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        IO.inspect("[Nudedisco.Util.request] Request failed with status code: #{status_code}")
        IO.inspect(body)
        :error

      {:error, error} ->
        IO.inspect("[Nudedisco.Util.request] Request failed.")
        IO.inspect("URL: #{url}")
        IO.inspect(error)
        :error
    end
  end
end
