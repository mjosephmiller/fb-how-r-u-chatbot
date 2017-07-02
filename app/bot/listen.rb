require "facebook/messenger"
include Facebook::Messenger
require "google/cloud/language"

Facebook::Messenger::Subscriptions.subscribe(access_token: ENV["FACEBOOK_ACCESS_TOKEN"])

GREETINGS = %w('good morning' 'good afternoon' 'good evening' yo hey 'whats up' howdy hiya hi hello)
GOODBYES = %w(bye cya ttyl brb g2g 'got to go' 'talk later' 'speak soon')
ADVICE =  ["try taking some deep breaths. You have got this.", "y'know, meditating for just 10 mins each day has proven to help boost your mood.", 'you should try talking to someone you trust.']

Bot.on :message do |message|
    sender = message.sender
    body = message.messaging['message']['text'].downcase.strip
    @user = User.find_or_create_by(token: sender['id'])
    check_for_mood_review

    if @previous_message == "hello humanoid - #{@user.token}. How r u?"
        quick_reply(sender)
        @previous_message = nil
    end
    if @mood_review.present?
        if GREETINGS.include? body
            reply(sender, "hello humanoid - #{@user.token}. I've already tracked your mood for today.")
        elsif @previous_message == 'ah, anything I can help with?'
            @user.mood_reviews.last.update_columns(thoughts: body)
            reply(sender, ADVICE.sample)
            @previous_message = nil
        elsif GOODBYES.include? body
            reply(sender, 'Buh-bye. 👋')
        else
            respond_to_sentiment(message)
        end
    else
        if message.quick_reply.present?
              @mood_review = @user.mood_reviews.create(rating: message.quick_reply.to_i)
              if message.quick_reply.to_i > 5
                  reply(sender, "#{message.quick_reply.to_i}, eh? That's good to hear!")
              else
                  reply(sender, 'ah, anything I can help with?')
              end
        elsif GREETINGS.include? body
            reply(sender, "hello humanoid - #{@user.token}. How r u?")
        end
    end
end

def reply(recipient, text)
    Bot.deliver({
        recipient: recipient,
        message: {
          text: text
        }
    }, access_token: ENV["FACEBOOK_ACCESS_TOKEN"])
    @previous_message = text
end

def check_for_mood_review
    @mood_review = @user.mood_reviews.where('created_at >= ?', Time.zone.now.beginning_of_day)
end

def respond_to_sentiment(message)
    body = message.messaging['message']['text'].downcase.strip
    if positive_or_negative?(body)
        reply(message.sender, "Totally!")
    else
        reply(message.sender, "I can't deal with your negativity right now.")
    end
end

def positive_or_negative?(body)
    project_id = ENV["NLP_GOOGLE_APP_ID"]
    language = Google::Cloud::Language.new project: project_id
    document = language.document body
    sentiment = document.sentiment
    p sentiment.score
    sentiment.score > 0
end

def quick_reply(recipient)
    Bot.deliver({
        recipient: recipient,
        message: {
          text:"But seriously. If you had to put a number on it?",
          quick_replies:[
            {
              content_type:"text",
              title:"1",
              payload:1
            },
            {
              content_type:"text",
              title:"2",
              payload:2
            },
            {
              content_type:"text",
              title:"3",
              payload:3
            },
            {
              content_type:"text",
              title:"4",
              payload:4
            },
            {
              content_type:"text",
              title:"5",
              payload:5
            },
            {
              content_type:"text",
              title:"6",
              payload:6
            },
            {
              content_type:"text",
              title:"7",
              payload:7
            },
            {
              content_type:"text",
              title:"8",
              payload:8
            },
            {
              content_type:"text",
              title:"9",
              payload:9
            },
            {
              content_type:"text",
              title:"10",
              payload:10
            }
          ]
        }
    }, access_token: ENV["FACEBOOK_ACCESS_TOKEN"])
end


