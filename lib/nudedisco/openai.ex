defmodule Nudedisco.OpenAI do
  def completion(prompt) do
    url = "https://api.openai.com/v1/completions"

    body =
      Poison.encode!(%{
        model: "gpt-3.5-turbo",
        prompt: prompt,
        temperature: 0.2
      })

    headers = [
      {"Authorization", "Bearer #{Application.get_env(:nudedisco, :openai_api_key)}"},
      {"Content-Type", "application/json"}
    ]

    with {:ok, body} <- Nudedisco.Util.request(:post, url, body, headers) do
      %{"choices" => [%{"text" => text}]} = Poison.decode!(body)
      {:ok, text}
    else
      :error ->
        :error
    end
  end
end
