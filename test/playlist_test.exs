defmodule PlaylistTest do
  use ExUnit.Case, async: true

  test "schedules a playlist sync job for 7am on Fridays" do
    import Crontab.CronExpression
    job = Nudedisco.Scheduler.find_job(:playlist_sync)
    assert job != nil
    assert job.schedule == ~e"0 7 * * 5"
  end
end
