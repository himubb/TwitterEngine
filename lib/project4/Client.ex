defmodule Client do
  @compile :nowarn_unused_vars
	use GenServer

	def init([user_name]) do

    	# IO.puts("checkpoint1")
    		#register account
    		# IO.puts("checkpoint2")
    		# _msg = GenServer.cast(:Master, {:register_user, user_name})
    	register_new_user(user_name)
    		# IO.inspect(l)
    	{:ok, []}
    end



    def user_session(number_of_tweets, user_name, other_clients, hashtag_list) do
    	#Render tweets of all subscription for user
      # IO.puts("In user session")
      # IO.inspect(other_clients)
      # IO.puts("user name: " <> user_name)
      generate_tweet(number_of_tweets, other_clients -- [user_name], hashtag_list, user_name)
    	IO.puts("Live Feed of "<> user_name)
    	IO.puts("")
      live_display(user_name)
    	# _msg = GenServer.call(:Master,{:tweets_by_subscriptions,user_name})
    	# IO.inspect(list_of_tweets)

    	#Create tweets by user
		# generate_tweet(number_of_tweets, other_clients -- [user_name], hashtag_list, user_name)
		# retweet(user_name)
  	end

    def handle_cast({:disconnect_user, user_name}, _state) do
      # IO.puts("in handle cast")
      logout_from_account(user_name)

      {:noreply,[]}
		end
		def handle_cast({:connect_user, user_name}, _state) do
      # IO.puts("in login handle cast")
      login_into_account(user_name)
      # live_display(user_name)
      {:noreply,[]}
		end

		def handle_cast({:delete_user, user_name}, _state) do
      # IO.puts("in delete handle cast")
      delete_account(user_name)

      {:noreply,[]}
    end

    
    def handle_cast({:query_by_mention_test, user_name, mention}, _state) do
      # IO.puts("in query_by_mention_test handle cast")
      query_with_user_mentions(user_name, mention)
      {:noreply,[]}
    end

    def handle_cast({:tweet_test, user_name, mention}, _state) do
      # IO.puts("in tweet test handle cast")
      generate_tweet(1, mention, ["#testHashTag"], user_name)

      {:noreply,[]}
    end

    def handle_cast({:Retweet_test, user_name}, _state) do
      # IO.puts("in Retweet test handle cast")
      retweet("1")

      {:noreply,[]}
    end


    def handle_cast({:subscribe_to_user, user_name, subscription}, _state) do
      # IO.puts("in set_subscription handle cast")
      ppid = get_data_from_table(:pid_lookup_registry, "Master")
      for s <- subscription do
        send(ppid, {:add_subscriptions,user_name, s})
      end

      {:noreply,[]}
    end

    def handle_cast({:login_user, number_of_tweets, user_name, hashtag_list}, _state) do
      # IO.puts("checkpoint" <> user_name)
      l = login_into_account(user_name)
      # IO.inspect(l)
      user_session(number_of_tweets, user_name, l, hashtag_list)

      {:noreply,[]}
    end



    #Function to register new user
    defp register_new_user(user_name) do
      ppid = get_data_from_table(:pid_lookup_registry, "Master")
      send(ppid, {:register_user, user_name})
      l = receive do
        {:reply1, l} -> l
      end
      # IO.puts("checkpoint3")

      IO.puts("userId #{user_name} is registered")
      set_subscribers(user_name, l)
      l
    end

    #Login into user Account, change status to connected
    defp login_into_account(user_name) do
      ppid = get_data_from_table(:pid_lookup_registry, "Master")
      send(ppid, {:login, user_name})
      l = receive do
        {:reply2, l} -> l
      end
      IO.puts("Login successful into your account")
      l
    end

    defp logout_from_account(user_name) do
      # IO.puts("in logout")
      ppid = get_data_from_table(:pid_lookup_registry, "Master")
      send(ppid, {:logout, user_name})
      IO.puts("User has been successfully logged out")
    end

    defp delete_account(user_name) do
      ppid = get_data_from_table(:pid_lookup_registry, "Master")
      send(ppid, {:delete_account, user_name})
      IO.puts("User account has been successfully deleted")
    end




  	defp live_display(user_name) do
  		receive do
        {:reply9, tweet} -> IO.puts(tweet)
      end
      live_display(user_name)
  	end

  	def generate_tweet(number_of_tweets, other_clients, hashtag_list, user_name) do
  		# IO.puts("In generate tweet")
  		for i<- 1..number_of_tweets do
	  		hashtag = Enum.random(hashtag_list)
	  		mention = if other_clients != [] do
	  			"@" <> Enum.random(other_clients)
	  		else
	  			"admin"
	  		end

	  		tweet="Tweet No #{i}: I am tweeting using the #{hashtag} and #{mention} has to been mentioned in it."
	  		# _msg=GenServer.cast(:Master,{:publish_tweet,user_name,tweet})
	  		ppid = get_data_from_table(:pid_lookup_registry, "Master")

        #Send tweet to list of followers live if user is connected
        list_of_followers = get_data_from_table(:user_followers, user_name)
        for x <- list_of_followers do
          z = get_data_from_table(:registered_user, x)
          if z == "C" do
            send(String.to_atom(x), {:reply9, tweet})
          end
        end


        if mention != "admin" && get_data_from_table(:registered_user, mention) == "C" do
          IO.puts("mention" <> mention)
          send(String.to_atom(String.slice(mention, 1, String.length(mention))), {:reply9, tweet})
        end

	  		send(ppid, {:publish_tweet,user_name, tweet})

	  		return_tweet = receive do
    			{:reply3, tweet} -> tweet
    		end
	  		IO.puts(return_tweet <> " has been successfully tweeted")
	  	end
  	end


  	def retweet(user_name) do
  		ppid = get_data_from_table(:pid_lookup_registry, "Master")
    	send(ppid, {:tweets_by_subscriptions,user_name})
    	list_of_tweets = receive do
    			{:reply4, l} -> l
    		end
      if list_of_tweets != [] do

      end
    	tweet = hd(list_of_tweets)

    	tweet = "(ReTweeT) " <> tweet
    	ppid = get_data_from_table(:pid_lookup_registry, "Master")
      list_of_followers = get_data_from_table(:user_followers, user_name)
        for x <- list_of_followers do
          z = get_data_from_table(:registered_user, x)
          if z == "C" do
            send(String.to_atom(x), {:reply9, tweet})
          end
        end


  		send(ppid, {:publish_tweet,user_name, tweet})

  		return_tweet = receive do
			{:reply3, tweet} -> tweet
		end
		IO.puts(return_tweet <> " has been successfully retweeted")
  	end

	def set_subscribers(user_name, l) do
    l = l --[user_name]
		subs = Enum.take_random(l, Enum.random(1..length(l)))
		ppid = get_data_from_table(:pid_lookup_registry, "Master")
		for s <- subs do
			send(ppid, {:add_subscriptions,user_name, s})
		end
		# IO.inspect(subs)
	end

defp query_with_user_mentions(user_name, mention) do
	ppid = get_data_from_table(:pid_lookup_registry, "Master")
	send(ppid, {:query_by_mention,user_name, mention})
	list_of_tweets_with_mention = receive do
			{:reply6, l} -> IO.inspect(l)
      l
		end
    list_of_tweets_with_mention
end

defp query_with_hashtags(user_name, hashtag) do
	ppid = get_data_from_table(:pid_lookup_registry, "Master")
	send(ppid, {:query_by_hashtag,user_name, hashtag})
	list_of_tweets_with_hashtag = receive do
			{:reply5, l} -> l
		end
    list_of_tweets_with_hashtag
end

defp query_tweets_subscribed_to(user_name) do
	ppid = get_data_from_table(:pid_lookup_registry, "Master")
    	send(ppid, {:tweets_by_subscriptions,user_name})
    	list_of_tweets = receive do
    			{:reply4, l} -> l
    		end
    list_of_tweets
end

defp get_data_from_table(table_name, key) do
  	value = :ets.lookup(table_name, key)
  	if value != [] do
  		[{_, value}] = value
  		value
  	else
  		[]
  	end
  end

end
