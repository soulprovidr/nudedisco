defmodule Nudedisco.Listmonk.Constants do
  @moduledoc """
  nudedisco listmonk constants.
  """

  @list_id 3
  @template_id 1

  @doc """
  Listmonk API URL.
  """
  def api_url(), do: Application.get_env(:nudedisco, :listmonk_api_url)

  @doc """
  Listmonk admin user.
  """
  def admin_user(), do: Application.get_env(:nudedisco, :listmonk_admin_user)

  @doc """
  Listmonk admin password.
  """
  def admin_password, do: Application.get_env(:nudedisco, :listmonk_admin_password)

  def list_id, do: @list_id

  def template_id, do: @template_id
end
