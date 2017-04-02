require "facebook/messenger"
include Facebook::Messenger

Facebook::Messenger::Subscriptions.subscribe(access_token: ENV["ACCESS_TOKEN"])
Bot.on :message do |message|
    if %w(hello hi hiya yo hey).include? message.messaging['message']['text']
        message.reply(text: 'Hello, humanoid!')
    elsif %("how's it going" ok? alright?).include? message.messaging['message']['text']
        message.reply(text: "I'm ok. How are you?")
    elsif message.messaging['message']['text'] == "I'm good thanks!"
        message.reply(text: "Good to hear. Ta-Ra for now.")
    end
end

def sender
    message.messaging["sender"]["id"]
end

def recipient
    message.messaging["recipient"]["id"]
end

def reply(message)
    payload = {
    recipient: sender,
    message: message
    }
    Facebook::Messenger::Bot.deliver(payload, access_token: ENV["ACCESS_TOKEN"])
end
