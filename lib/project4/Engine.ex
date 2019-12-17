defmodule Engine do
  @compile :nowarn_unused_vars
	use GenServer

	def init([]) do
      
		  #initiate storage database
    	initiate_storage()
      pid = spawn_link(fn() -> incoming_messages() end) 
      # IO.inspect(pid)
      :ets.insert(:pid_lookup_registry, {"Master", pid})
    	{:ok, []}
  	end

  	defp initiate_storage() do
	    #registered_user to store registerd client pid info
      :ets.new(:users, [:set, :public, :named_table])
	    :ets.new(:registered_user, [:set, :public, :named_table])
	    :ets.new(:tweets_by_user, [:set, :public, :named_table])
	    :ets.new(:hashtag_table, [:set, :public, :named_table])
	    :ets.new(:mention_table, [:set, :public, :named_table])
	    :ets.new(:subscriptions, [:set, :public, :named_table])
      :ets.new(:user_followers, [:set, :public, :named_table])
      :ets.insert(:users, {"clients", []})
  	end

  	#register user
  defp register_user(user_name, pid) do
    l = get_data_from_table(:users, "clients")
    :ets.insert(:users, {"clients", l ++ [user_name]})
    :ets.insert(:registered_user, {user_name, "C"})
    :ets.insert(:tweets_by_user, {user_name, []})
    :ets.insert(:subscriptions, {user_name, []})
    :ets.insert(:user_followers, {user_name, []})
  end

  defp disconnect_user(user_name) do
  	:ets.insert(:registered_user, {user_name, "D"})
  end

  defp delete_account(user_name) do
    :ets.insert(:registered_user, {user_name, "X"})
  end

  # defp add_new_tweet(tweet, user_name) do
  # 	l = get_data_from_table(:tweets_by_user, user_name)
  # 	l = l ++ tweet
  # 	:ets.insert(:tweets_by_user, {user_name, l})
  	
  # end

  defp query_tweets(user_name) do
  	query_result = get_data_from_table(:tweets_by_user, user_name)
  end

  defp add_new_subscription(user_name, new_subscription_user_name) do
    # IO.inspect(new_subscription_user_name)
  	val = get_data_from_table(:subscriptions, user_name)
  	val = val ++ [new_subscription_user_name]
  	:ets.insert(:subscriptions, {user_name, val})

    val = get_data_from_table(:user_followers, new_subscription_user_name)
    val = val ++ [user_name]
    :ets.insert(:user_followers, {new_subscription_user_name, val})
  end

  

  defp tweet_parser(tweet, user_name, prefix) do
  	l = String.split(tweet, " ")
    # IO.inspect(l)
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
          # IO.puts("word is :" <> word)
  				z = get_data_from_table(:registered_user, word)
  				if z != [] do
	  				val = get_data_from_table(:mention_table, word)
	  				if val == [] do
	  					:ets.insert(:mention_table, {word, [tweet]})
              # IO.puts("word is :" <> word)
	  				else
	  					val = val ++ [tweet]
	  					:ets.insert(:mention_table, {word, val})
              # IO.puts("word is :" <> word)
	  				end
	  			end
  			end
  		end
  	end
  end

  defp tweets_rendered_from_subscriptions(user_name) do
  	l = get_data_from_table(:subscriptions, user_name)
  	tweet_list = []
  	tweet_list = tweet_list ++ for subscribed_user <- l do
      # IO.puts(subscribed_user)
  		get_data_from_table(:tweets_by_user, subscribed_user)
  	end
    # IO.inspect(tweet_list)
  	List.flatten(tweet_list)
  end

  defp query_by_hashtag(hashtag, user_name) do
  	l = get_data_from_table(:hashtag_table, hashtag)
    send(String.to_atom(user_name), {:reply5, l})
  end

  defp query_by_mention(mention, user_name) do
  	z = get_data_from_table(:registered_user, String.slice(mention, 1, String.length(mention)))
  	q = if z == [] do
  		[]
  	else
  		v = get_data_from_table(:mention_table, String.slice(mention, 1, String.length(mention)))

      v
  	end
    send(String.to_atom(user_name), {:reply6, q})
  end 

  #HANDLE INCOMING MESSAGES
  def incoming_messages() do
    receive do 
      {:register_user, user_name} -> reg_user(user_name)
      {:login, user_name} -> login_process(user_name)
      {:publish_tweet, user_name,tweet} -> publish_tweet(user_name, tweet)
      {:tweets_by_subscriptions, user_name} -> tweets_by_subscriptions(user_name)
      {:add_subscriptions, user_name, subs} -> add_new_subscription(user_name, subs)
      {:query_by_hashtag, user_name, hashtag} -> query_by_hashtag(hashtag, user_name)
      {:query_by_mention, user_name, mention} -> query_by_mention(mention, user_name)
      {:logout, user_name} -> disconnect_user(user_name)
      {:delete_account, user_name} -> delete_account(user_name)
    end
    incoming_messages()

  end


  def reg_user(user_name) do
    pid = get_data_from_table(:pid_lookup_registry, user_name)
    register_user(user_name, pid)
    l = get_data_from_table(:users, "clients")
    send(String.to_atom(user_name), {:reply1, l})
  end
  def login_process(user_name) do
    :ets.insert(:registered_user, {user_name, "C"})
    l = get_data_from_table(:users, "clients")
    send(String.to_atom(user_name), {:reply2, l})
  end
  def publish_tweet(user_name, tweet) do
    l = get_data_from_table(:tweets_by_user, user_name)
    :ets.insert(:tweets_by_user, {user_name, l++[tweet]})
    send(String.to_atom(user_name), {:reply3, tweet})
    tweet_parser(tweet, user_name, "#")
    tweet_parser(tweet, user_name, "@")
  end
  def tweets_by_subscriptions(user_name) do
    # IO.puts("sub")
    l = tweets_rendered_from_subscriptions(user_name)
    # IO.inspect(l)

    send(String.to_atom(user_name), {:reply4, l})
  end






  # def handle_cast({:register_user, user_name}, _state) do
  #   IO.puts("in handle cast")
  #   pid = get_data_from_table(:pid_lookup_registry, user_name)
  #   register_user(user_name, pid)
  #   l = get_data_from_table(:users, "clients")
  #   send(String.to_atom(user_name), {:reply1, l})
  #   {:noreply,:ok}
  # end
  # def handle_cast({:login, user_name}, _state) do
  #   pid = get_data_from_table(:pid_lookup_registry, user_name)
  #   :ets.insert(:registered_user, {user_name, 'C'})
  #   l = get_data_from_table(:users, "clients")
  #   send(String.to_atom(user_name), {:reply2, l})
  #   {:noreply,:ok}
  # end
  # def handle_cast({:publish_tweet, user_name,tweet}, _state) do
  #   l = get_data_from_table(:tweets_by_user, user_name)
  #   :ets.insert(:tweets_by_user, {user_name, l++[tweet]})
  #   send(String.to_atom(user_name), {:reply3, tweet})
  #   {:noreply,:ok}
  # end
  # def handle_call({:tweets_by_subscriptions, user_name},_from, _state) do
  #   IO.puts("sub")
  #   l = tweets_rendered_from_subscriptions(user_name)
  #   # IO.inspect(l)
  #   send(String.to_atom(user_name), {:reply4, l})
  #   {:reply,:ok,[]}
  # end














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