defmodule Nudedisco.OpenAI do
  @moduledoc """
  nudedisco OpenAI module.

  Provides a simple interface for interacting with OpenAI's GPT-3 API.

  ## Configuration

  The OpenAI API key is configured via the `:openai_api_key` environment variable.

  ## Usage

  The `chat_completion` function is used to generate a response to a list of messages.
  """

  # Calculate the rough cost of a request to OpenAI's GPT-3 API.
  @spec get_cost(integer) :: float
  defp get_cost(tokens) do
    Float.round(tokens / 1000 * 0.002, 3)
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
        model: "gpt-3.5-turbo",
        messages: messages
      })

    headers = [
      {"Authorization", "Bearer #{Application.get_env(:nudedisco, :openai_api_key)}"},
      {"Content-Type", "application/json"}
    ]

    with {:ok, body} <- Nudedisco.Util.request(:post, url, body, headers) do
      body = Poison.decode!(body)
      content = List.first(body["choices"])["message"]["content"]

      usage = body["usage"]
      total_cost = get_cost(usage["total_tokens"])
      IO.puts("[OpenAI]: Used #{usage["total_tokens"]} tokens ($#{total_cost})")
      {:ok, content}
    else
      :error ->
        :error
    end
  end
end
