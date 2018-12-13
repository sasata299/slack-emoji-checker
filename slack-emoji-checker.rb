require 'slack-ruby-client'

Slack.configure do |config|
  config.token = ENV['SLACK_API_TOKEN']
end

client = Slack::Web::Client.new
client.channels_list.channels.each do |channel|
  p channel.id
  p channel.name
end
