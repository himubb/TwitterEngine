defmodule Project41Test do
  use ExUnit.Case
  doctest Project41

  test "Disconnect User" do
  	Project4.main(5, 2, "disconnect")
    assert Project4.operation("1", "disconnect") == "D"
  end

  test "Disconnect User1" do
  	Project4.main(5, 2, "disconnect")
    assert Project4.operation("2", "disconnect") == "D"
  end

  test "Login User" do
    Project4.main(5, 2, "login_test")
    assert Project4.operation("1", "login_test") == "C"
  end
  test "Delete User" do
      Project4.main(5, 2, "delete")
      assert Project4.operation("1", "delete") == "X"
  end  
  test "subscribe_to_user" do
      Project4.main(5, 2, "subscribe_to_user")
      assert Project4.operation("1", "subscribe_to_user") == ["5"]
  end

  test "tweet_test" do
      Project4.main(5, 1, "tweet_test")
      assert Project4.operation("1", "tweet_test") == ["Tweet No 1: I am tweeting using the #testHashTag and @2 has to been mentioned in it."]
  end

  test "Retweet_test" do
      Project4.main(2, 1, "Retweet_test")
      assert Project4.operation("1", "Retweet_test") == ["(ReTweeT) Tweet No 1: I am tweeting using the #testHashTag and admin has to been mentioned in it."]
  end

  test "Query_with_mention" do
      Project4.main(2, 1, "Query_with_mention")
      assert Project4.operation("2", "Query_with_mention") == ["Tweet No 1: I am tweeting using the #testHashTag and @1 has to been mentioned in it."]
  end

  test "Query_with_hashtag" do
      Project4.main(2, 1, "Query_with_hashtag")
      assert Project4.operation("2", "Query_with_hashtag") == ["Tweet No 1: I am tweeting using the #testHashTag and @1 has to been mentioned in it."]
  end

  test "register" do
      Project4.main(5, 2, "register")
      assert Project4.operation(6, "register") == Project4.get_data_from_table(:pid_lookup_registry, "6")
  end



  

  
end







