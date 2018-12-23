require 'slack-ruby-client'
require 'pry'

Slack.configure do |config|
  config.token = ENV['SLACK_API_TOKEN']
end

reaction_counts = Hash.new { |h,k| h[k] = 0 }

client = Slack::Web::Client.new

client.conversations_list(types: 'public_channel,private_channel', limit: 500).channels.each do |channel|
  next unless channel.name == ENV['TARGET_CHANNEL']
  p channel.name

  history = client.conversations_history(channel: channel.id, count: 3)
  history.messages.each do |message|
    p message.text

    if message.reactions
      message.reactions.each do |reaction|
        reaction_counts[reaction.name] += 1
      end
    end
  end
end

reaction_counts.sort { |(k1,v1),(k2,v2)| v2 <=> v1 }.each_with_index do |(k,v), i|
  p "#{i+1}: #{k}"
  exit if i >= 20
end
