# frozen_string_literal: true

set :output, '/log/cron_log.log'

every 1.day, at: '2:30 am' do
  rake :daily_job
end

every 1.hour do
  rake :hourly_job
end
