defmodule Nudedisco.OpenAI do
  @moduledoc """
  nudedisco OpenAI module.

  Provides a simple interface for interacting with OpenAI's GPT-3 API.

  ## Configuration

  The OpenAI API key is configured via the `:openai_api_key` environment variable.

  ## Usage

  The `chat_completion` function is used to generate a response to a list of messages.
  """
  alias Nudedisco.OpenAI
  alias Nudedisco.Util

  require Logger

  defp api_key, do: Application.get_env(:nudedisco, OpenAI)[:api_key]

  # Calculate the rough cost of the request.
  defp print_cost(%{"total_tokens" => total_tokens}) do
    total_cost = Float.round(total_tokens / 1000 * 0.002, 3)
    Logger.debug("[OpenAI] Used #{total_tokens} tokens ($#{total_cost})")
  end

  @doc """
  Uses OpenAI's GPT-3 API to generate a response to a list of messages.

  ## Parameters

  - `messages`: A list of tuples containing the role of the message and the message content.

  See [OpenAI's Chat Completion documentation](https://platform.openai.com/docs/guides/chat/introduction) for more information regarding the `messages` parameter.

  ## Returns

  The response will be a string containing the system's response to the user's message.
  """
  @spec chat_completion([{role :: String.t(), content :: String.t()}]) ::
          {:ok, String.t()} | :error
  def chat_completion(messages) do
    url = "https://api.openai.com/v1/chat/completions"

    messages =
      Enum.into(messages, [], fn {role, content} ->
        %{"role" => role, "content" => content}
      end)

    body =
      Poison.encode!(%{
        model: "gpt-4o-mini",
        messages: messages
      })

    headers = [
      {"Authorization", "Bearer #{api_key()}"},
      {"Content-Type", "application/json"}
    ]

    with {:ok, body} <- Util.request(:post, url, body, headers, recv_timeout: 30 * 1000) do
      %{"choices" => choices, "usage" => usage} = Poison.decode!(body)

      content =
        choices
        |> List.first()
        |> Map.get("message")
        |> Map.get("content")

      print_cost(usage)

      {:ok, content}
    else
      :error ->
        :error
    end
  end
end
