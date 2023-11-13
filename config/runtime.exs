import Config

listmonk_admin_user = System.get_env("LISTMONK_ADMIN_USER")
listmonk_admin_password = System.get_env("LISTMONK_ADMIN_PASSWORD")
listmonk_list_id = System.get_env("LISTMONK_LIST_ID")
openai_api_key = System.get_env("OPENAI_API_KEY")
spotify_client_id = System.get_env("SPOTIFY_CLIENT_ID")
spotify_client_secret = System.get_env("SPOTIFY_CLIENT_SECRET")
spotify_playlist_id = System.get_env("SPOTIFY_PLAYLIST_ID")
spotify_redirect_uri = System.get_env("SPOTIFY_REDIRECT_URI")

if listmonk_admin_user == nil do
  raise "Required value LISTMONK_ADMIN_USER is not set."
end

if listmonk_admin_password == nil do
  raise "Required value LISTMONK_ADMIN_PASSWORD is not set."
end

if listmonk_list_id == nil do
  raise "Required value LISTMONK_LIST_ID is not set."
end

if openai_api_key == nil do
  raise "Required value OPENAI_API_KEY is not set."
end

if spotify_client_id == nil do
  raise "Required value SPOTIFY_CLIENT_ID is not set."
end

if spotify_client_secret == nil do
  raise "Required value SPOTIFY_CLIENT_SECRET is not set."
end

if spotify_playlist_id == nil do
  raise "Required value SPOTIFY_PLAYLIST_ID is not set."
end

if spotify_redirect_uri == nil do
  raise "Required value SPOTIFY_REDIRECT_URI is not set."
end

config :nudedisco,
  listmonk_admin_user: listmonk_admin_user,
  listmonk_admin_password: listmonk_admin_password,
  listmonk_list_id: String.to_integer(listmonk_list_id),
  openai_api_key: openai_api_key,
  spotify_client_id: spotify_client_id,
  spotify_client_secret: spotify_client_secret,
  spotify_playlist_id: spotify_playlist_id,
  spotify_redirect_uri: spotify_redirect_uri
