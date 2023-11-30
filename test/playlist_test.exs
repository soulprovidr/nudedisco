defmodule PlaylistTest do
  use ExUnit.Case, async: true

  test "schedules playlist creation for 7am on Fridays" do
    import Crontab.CronExpression
    job = Nudedisco.Scheduler.find_job(:playlist_create)
    assert job != nil
    assert job.schedule == ~e"0 7 * * 5"
  end
end
