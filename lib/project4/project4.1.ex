defmodule Project41 do
  @compile :nowarn_unused_vars
  def main(num_user, num_msg, perform_operation) do
    :ets.new(:pid_lookup_registry, [:set, :public, :named_table])
    #Start Engine
    _msg = GenServer.start_link(Engine, [], name: :Master)

    # IO.puts("bdicjbdijdn")

    #pid_lookup_registry to store process name to pid




    #Create Users = number users given as input: Regster user
    for index <- 1..num_user do
      process_name = get_process_name(index)
      # number_of_subscribers = get_random_value(num_user - 1)
      {_,pid} = GenServer.start_link(Client, [process_name], name: String.to_atom(process_name))
      :ets.insert(:pid_lookup_registry, {process_name, pid})
    end

    :timer.sleep(1000)

    hashtag_list = ["#jamaude", "#pkmkb", "#elixirLanguage", "#python"]
    _next_operation = nil
    _next_operation = if perform_operation == "login" do
      for index <- 1..num_user do
        process_name = get_process_name(index)
        GenServer.cast(String.to_atom(process_name), {:login_user, num_msg, process_name, hashtag_list})
      end

    else
      perform_operation
    end
    
    # :timer.sleep(5000)

    
  end

  def operation(user_name, perform) do
    v=nil
    v=if perform == "disconnect" do
      # IO.puts("operation is " <> perform)
      # pid = get_data_from_table(:pid_lookup_registry, )
      # IO.inspect(Process.alive?(pid))
      GenServer.cast(String.to_atom(user_name), {:disconnect_user, user_name})
      :timer.sleep(100)
      val = get_data_from_table(:registered_user, user_name)
      # IO.puts(val)
      val
    else
      v
    end

    v=if perform == "login_test" do
      # IO.puts("operation is " <> perform)
      # pid = get_data_from_table(:pid_lookup_registry, )
      # IO.inspect(Process.alive?(pid))
      GenServer.cast(String.to_atom(user_name), {:connect_user, user_name})
      :timer.sleep(100)
      val = get_data_from_table(:registered_user, user_name)
      # IO.puts(val)
      val
    else
      v

    end
    v=if perform == "delete" do
      # IO.puts("operation is " <> perform)
      # pid = get_data_from_table(:pid_lookup_registry, )
      # IO.inspect(Process.alive?(pid))
      GenServer.cast(String.to_atom(user_name), {:delete_user, user_name})
      :timer.sleep(100)
      val = get_data_from_table(:registered_user, user_name)
      # IO.puts(val)
      val
    else
      v
    end

    v=if perform == "register" do
      # IO.puts("operation is " <> perform)
      # pid = get_data_from_table(:pid_lookup_registry, )
      # IO.inspect(Process.alive?(pid))
      process_name = get_process_name(user_name)
      # number_of_subscribers = get_random_value(user_name - 1)
      {_,pid} = GenServer.start_link(Client, [process_name], name: String.to_atom(process_name))
      :ets.insert(:pid_lookup_registry, {process_name, pid})
      # IO.puts(val)
      pid
    else
      v
    end

    v=if perform == "tweet_test" do
      # IO.puts("operation is " <> perform)
      # pid = get_data_from_table(:pid_lookup_registry, )
      # IO.inspect(Process.alive?(pid))
      GenServer.cast(String.to_atom("2"), {:disconnect_user, "2"})
      GenServer.cast(String.to_atom("2"), {:disconnect_user, "3"})
      GenServer.cast(String.to_atom("2"), {:disconnect_user, "4"})
      GenServer.cast(String.to_atom("2"), {:disconnect_user, "5"})
      :timer.sleep(100)

      GenServer.cast(String.to_atom(user_name), {:tweet_test, user_name, ["2"]})
      :timer.sleep(100)
      val = get_data_from_table(:tweets_by_user, user_name)
      # IO.puts(val)
      val
    else
      v
    end



    v=if perform == "Retweet_test" do
      # IO.puts("operation is " <> perform)
      # pid = get_data_from_table(:pid_lookup_registry, )
      # IO.inspect(Process.alive?(pid))

      GenServer.cast(String.to_atom(user_name), {:subscribe_to_user, user_name,["2"]})
      :timer.sleep(100)

      GenServer.cast(String.to_atom("1"), {:disconnect_user, "1"})
      :timer.sleep(100)
      
      GenServer.cast(String.to_atom("2"), {:tweet_test, "2", []})
      GenServer.cast(String.to_atom("2"), {:disconnect_user, "2"})
      :timer.sleep(100)
      

      GenServer.cast(String.to_atom("1"), {:Retweet_test, "1"})
      :timer.sleep(100)


      val = get_data_from_table(:tweets_by_user, user_name)
      # IO.puts(val)
      val
    else
      v
    end



    v=if perform == "Query_with_mention" do
      # IO.puts("operation is " <> perform)
      GenServer.cast(String.to_atom("1"), {:disconnect_user, "1"})
      :timer.sleep(100)
      
      GenServer.cast(String.to_atom(user_name), {:tweet_test, user_name, ["1"]})
      :timer.sleep(100)
      
      mention = "1"
      GenServer.cast(String.to_atom(user_name), {:query_by_mention_test, user_name, "@" <> mention})


      val = get_data_from_table(:mention_table, mention)
      
      val
    else
      v
    end

    v=if perform == "Query_with_hashtag" do
      # IO.puts("operation is " <> perform)
      GenServer.cast(String.to_atom("1"), {:disconnect_user, "1"})
      :timer.sleep(100)
      
      GenServer.cast(String.to_atom(user_name), {:tweet_test, user_name, ["1"]})
      :timer.sleep(100)
      
      hashtag = "#testHashTag"
      val = get_data_from_table(:hashtag_table, hashtag)
      
      val
    else
      v
    end



    v=if perform == "subscribe_to_user" do
      IO.puts("operation is " <> perform)
      # pid = get_data_from_table(:pid_lookup_registry, )
      # IO.inspect(Process.alive?(pid))
      GenServer.cast(String.to_atom(user_name), {:subscribe_to_user, user_name,["5"]})
      :timer.sleep(200)
      val = get_data_from_table(:subscriptions, user_name)


      val
    else
      v
    end

    v
  end




  def get_process_name(num) do
    Integer.to_string(num)
    # ("Elixir.P" <> num) |> String.to_atom()
  end

  def get_random_value(max) do
    Enum.random(1..max)
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

  def hello() do
    IO.puts("hello world")
    "world"
  end

end


