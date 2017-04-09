require "facebook/messenger"
include Facebook::Messenger
require "google/cloud/language"

Facebook::Messenger::Subscriptions.subscribe(access_token: ENV["FACEBOOK_ACCESS_TOKEN"])

Bot.on :message do |message|
    unless check_positive?(message)
        reply(message.sender, "I can't deal with your negativity right now.")
    end
    if %w(hello hi hiya yo hey).include? message.messaging['message']['text']
        reply(message.sender, 'hello humanoid. How r u?')
    elsif %("how's it going" ok? alright? What about you?).include? message.messaging['message']['text']
       reply(message.sender, "Well it's #{Date.today.wday}, so I'm alright, thanks.")
    else
        reply(message.sender, 'g2g.')
    end
end


def reply(recipient, text)
    Bot.deliver({
        recipient: recipient,
        message: {
          text: text
        }
    }, access_token: ENV["FACEBOOK_ACCESS_TOKEN"])
end

def check_positive?(message)
    project_id = ENV["NLP_GOOGLE_APP_ID"]
    language = Google::Cloud::Language.new project: project_id
    text = message.messaging['message']['text']
    document = language.document text
    sentiment = document.sentiment
    sentiment.score
    sentiment.score > 0
end
