defmodule Nudedisco.Listmonk.Constants do
  @moduledoc """
  nudedisco listmonk constants.
  """

  @doc """
  Listmonk admin user.
  """
  def admin_user(), do: Application.get_env(:nudedisco, :listmonk_admin_user)

  @doc """
  Listmonk admin password.
  """
  def admin_password, do: Application.get_env(:nudedisco, :listmonk_admin_password)

  def list_id, do: Application.get_env(:nudedisco, :listmonk_list_id)
end
