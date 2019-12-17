defmodule Project4Web.RoomChannel do
  use Project4Web, :channel

  def join("rooms:lobby", payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("initiate_message", payload, socket) do
    broadcast! socket, "initiate_message", payload
    {:noreply, socket}
  end

   def handle_in("login",%{"username"=>username, "password"=>password} ,socket) do
        password_obtained=get_data_from_table(:register_user, username)
        if(password_obtained == password) do
            page = Phoenix.View.render_to_string(Project4Web.PageView,"tweets.html",username: username)
            push socket, "afterLogin", %{response: "logged in successfully", username: username, html: page, code: "0"}
        else
            push socket, "afterLogin", %{response: "Wrong credentials!!", code: "-1"}
        end
        {:noreply, socket}
    end

    def handle_in("register", %{"username"=>username, "password"=>password},socket) do
        :ets.insert(:register_user, {username, password})
        push socket, "registered", %{response: "User is registered successfully!!"}
        {:noreply, socket}
    end

    def handle_in("newTweet", %{"tweet"=> tweet, "username"=>username} ,socket) do
        l = get_data_from_table(:tweets_by_user, username)
        :ets.insert(:tweets_by_user, {username, l++[tweet]})
        tweet_parser(tweet, "#")
        tweet_parser(tweet, "@")

        push socket, "tweetSuccess", %{response: "Tweet Successful"}
        {:noreply, socket}
    end





    def handle_in("displayMyTweets", %{"username"=>username} ,socket) do
        #IO.puts "username is #{username}"
        tweeted = display_tweet(username)
        tweeted=list_to_string(tweeted, "")
        #IO.inspect tweeted
        push socket, "displayingMyTweets", %{response: tweeted}
        {:noreply, socket}
    end


    def handle_in("subscription", %{"subscriber"=>subscription, "username"=>user_name} ,socket) do
        #IO.puts "username is #{user_name} subscribed to #{follow} "


        val = get_data_from_table(:subscriptions, user_name)
        val = val ++ [subscription]
        :ets.insert(:subscriptions, {user_name, val})

        val = get_data_from_table(:user_followers, subscription)
        val = val ++ [user_name]
        :ets.insert(:user_followers, {subscription, val})

        push socket, "SubscribedUser", %{response: "Subscribed to #{subscription}"}
        {:noreply, socket}
    end



    def handle_in("livefeed", %{"username"=>user_name} ,socket) do

        subscriptions=get_data_from_table(:subscriptions, user_name)
        tweet_list=[]
        tweet_list=tweet_list++for s<- subscriptions do
        get_tweets_by_subscription(s)
        end
        tweet_list=List.flatten(tweet_list)
        tweet_list = list_to_string(tweet_list, "")
        mentions=get_data_from_table(:mention_table, user_name)
        mentions = list_to_string(mentions, "")
        push socket, "displayingLiveFeed", %{feed: tweet_list, mentions: mentions}
        {:noreply, socket}
    end


    def handle_in("queryByMention", %{"mention"=>mention} ,socket) do
         mentions=get_data_from_table(:mention_table, String.slice(mention, 1, String.length(mention)))
        mentions =if(mentions == nil) do
            mention= "There is no tweet with given mention\r\n"
            mention
        else
          list_to_string(mentions, "")
        end
        push socket, "mentionQueried", %{response: mentions}
        {:noreply, socket}
    end







    def handle_in("queryByHashtag", %{"hashtag"=>hashtag} ,socket) do
        #IO.puts "hashtag is #{hashtag}"
        hashtagResult = get_data_from_table(:hashtag_table, hashtag)
        hashtag_str=if(hashtagResult == nil) do
          hashtag_str = "No match for hashtag \r\n"
          hashtag_str
        else
          list_to_string(hashtagResult, "")
        end
        push socket, "hashtagQueried", %{response: hashtag_str}
        {:noreply, socket}
    end

    def handle_in("retweet", %{"tweet_no"=>tweet_no, "username"=>username} ,socket) do
        #IO.puts "tweet_no is #{tweet_no}"
        tweet_no = tweet_no - 1
        subscriptions=get_data_from_table(:subscriptions, username)
        tweet_list=[]
        tweet_list=tweet_list++for s<- subscriptions do
        get_tweets_by_subscription(s)
        end
        tweet_list=List.flatten(tweet_list)

        tweet_list=if tweet_no < length(tweet_list) do
                    tweet_list
                  else
                     mentions=get_data_from_table(:mention_table, username)
                     tweet_list++mentions
                  end

        retweet=Enum.at(tweet_list,tweet_no)
        l = get_data_from_table(:tweets_by_user, username)
        :ets.insert(:tweets_by_user, {username, l++[retweet]})
        push socket, "retweeted", %{response: retweet<>" is retweeted successfully!"}
        {:noreply, socket}
    end





      def display_tweet(username) do
        tweet = get_data_from_table(:tweets_by_user, username)
        #IO.puts("in display")
        #IO.inspect tweet
        tweet
      end



def get_data_from_table(table_name, key) do
    value = :ets.lookup(table_name, key)
    if value != [] do
      [{_, value}] = value
      value
    else
      []
    end
  end
def list_to_string(list, resultant_string) do
    # #IO.inspect(list)
    resultant_string = if length(list) == 1 do
      resultant_string <> hd(list)
    else
      resultant_string = if length(list) == 0 do
        ""
      else
        element = hd(list)
        resultant_string = resultant_string <> element <> "\r\n"
        list_to_string(Enum.slice(list, 1, length(list)-1), resultant_string)
      end
      resultant_string
    end
    resultant_string
  end

  def get_tweets_by_subscription(user_name) do
    l=display_tweet(user_name)
    l

end



def tweet_parser(tweet, prefix) do
  l = String.split(tweet, " ")
  # #IO.inspect(l)
  for word <- l do
    if String.starts_with?(word, prefix) do
      if prefix == "#" do
        val = get_data_from_table(:hashtag_table, word)
        if val == [] do
          :ets.insert(:hashtag_table, {word, [tweet]})

        else
          val = val ++ [tweet]
          :ets.insert(:hashtag_table, {word, val})
        end
      end
      if prefix == "@" do
        word = String.slice(word, 1, String.length(word))
        # #IO.puts("word is :" <> word)

        val = get_data_from_table(:mention_table, word)
        if val == [] do
          :ets.insert(:mention_table, {word, [tweet]})
          # #IO.puts("word is :" <> word)
        else
          val = val ++ [tweet]
          :ets.insert(:mention_table, {word, val})
          # #IO.puts("word is :" <> word)
        end

      end
    end
  end
end
  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
