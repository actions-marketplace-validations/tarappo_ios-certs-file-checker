require 'apple_certs_info'
require 'slack-notifier'

class Message
  # expireが近いものから必要な情報を生成
  def self.expire_list(list:, type:)
    args = :cname
    case type
    when :distribution_certificate, :development_certificate then
        args = :cname
    when :provisioning_profile then
        args = :app_id_name
    end
    
    message = []
    list.each do |data|
      message << "- #{data[args]}（残り約#{data[:limit_days]}日）"
    end

    message
  end

   # slackに投稿するためのメッセージの整形
   def self.create_slack_message(message_list:, type:)
    return "" if (message_list.nil? || message_list.count == 0)

    case type
    when :distribution_certificate then
        prefix_message = "[Certificate(Distribution)]\n"
    when :development_certificate then
        prefix_message = "[Certificate(Development)]\n"
    when :provisioning_profile then
        prefix_message = "[Provisioning Profile]\n"
    end

    message = prefix_message + message_list.join("\n") + "\n\n"

    message
  end
end


limit_days = ENV["EXPIRE_LIMIT_DAYS"]
slack_webhook_url = ENV["SLACK_WEBHOOK_URL"]
extra_message = ENV["EXTRA_MESSAGE"]


# provisioning profile
expire_pp_list = AppleCertsInfo.provisioning_profile_list_limit_days_for(days: limit_days)
expire_pp_message = Message.expire_list(list: expire_pp_list, type: :provisioning_profile)
puts expire_pp_message

# certificate development
expire_dev_cert_list = AppleCertsInfo.certificate_development_list_limit_days_for(days: limit_days)
expire_dev_cert_message = Message.expire_list(list: expire_dev_cert_list, type: :development_certificate)
puts expire_dev_cert_message

# certificate distribution
expire_dist_cert_list = AppleCertsInfo.certificate_distribution_list_limit_days_for(days: limit_days)
expire_dist_cert_message = Message.expire_list(list: expire_dist_cert_list, type: :distribution_certificate)
puts expire_dist_cert_message


# SLACK通知先がある場合
unless (slack_webhook_url.nil? || slack_webhook_url.empty?)
    puts "[start] slack notify"
    expire_pp = Message.create_slack_message(message_list: expire_pp_message, type: :provisioning_profile)
    expire_dev_cert = Message.create_slack_message(message_list: expire_dev_cert_message, type: :development_certificate)
    expire_dist_cert = Message.create_slack_message(message_list: expire_dist_cert_message, type: :distribution_certificate)
    slack_message = expire_pp + expire_dev_cert + expire_dist_cert

    unless slack_message.empty?
        slack_message +=  extra_message unless extra_message.nil?
        notifier = Slack::Notifier.new slack_webhook_url
        notifier.ping slack_message
    end
end
