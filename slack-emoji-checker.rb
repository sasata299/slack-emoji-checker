require 'slack-ruby-client'
require 'pry'

Slack.configure do |config|
  config.token = ENV['SLACK_API_TOKEN']
end

reaction_counts = Hash.new { |h,k| h[k] = 0 }

client = Slack::Web::Client.new

client.conversations_list(types: 'public_channel,private_channel', exclude_archived: true,  limit: 1000).channels.each do |channel|
  next unless channel.name == ENV['TARGET_CHANNEL']
  p channel.name

  history = client.conversations_history(channel: channel.id, count: 1000)
  history.messages.each do |message|
    #p message.text

    # メッセージにリアクションがあればカウントする
    if message.reactions
      message.reactions.each do |reaction|
        reaction.name.sub!(/::skin-tone-\d/, '')
        reaction_counts[reaction.name] += 1
      end
    end

    # メッセージがスレッドであれば、スレッドを取得する
    # スレッド内のメッセージににリアクションがあればカウントする
    if message.reply_count
      thread = client.conversations_replies(channel: channel.id, ts: message.ts, limit: 20)
      thread.messages.each do |message|
        next if message.ts == message.thread_ts

        if message.reactions
          message.reactions.each do |reaction|
            reaction.name.sub!(/::skin-tone-\d/, '')
            reaction_counts[reaction.name] += 1
          end
        end
      end
    end
  end
end

reaction_counts.sort { |(k1,v1),(k2,v2)| v2 <=> v1 }.each_with_index do |(k,v), i|
  exit if i >= 19
  puts "#{v} :#{k}:"
end
