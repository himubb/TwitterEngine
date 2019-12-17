# Project4


Team Members:
Shubham Saoji 26364957
Himavanth Boddu 32451847


Problem Statement:
The goal of this project is to implement a web interface for Twitter-like engine implementing functionalities like registering account, login, logout, delete account, tweet, retweet, subscribe to other users etc using phoenix framework.

What is Working:
All functionalities mentioned are working as expected. A video has been recorded showing working of this project. 
Link for video is - https://youtu.be/OVzV_3SloWo 


How to run project:

  * Install dependencies with `mix deps.get`
  * Install Node.js dependencies with `npm install`
  * Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.


Project Description:
The goal of this project is to implement a Twitter-like engine and pair up with Web Sockets to provide full functionality.

The Twitter Engine acts as server and users are clients. We have used simulated functionalities like create account, login, logout, subscribe, tweet etc.
Overview of all functionalities is provided later in this report.

Multiple ets tables are used as server storage or database for server/ twitter engine.





Overview of functionalities:
The functionalities that have been implemented in this project are as follows -

1. Register account –
Client can register into twitter engine. The entry of this new used is stored in ets table. We store username and password in ets table.


2. Login -
Client can login into account and then is eligible to send tweets, receive live feeds  or perform any other operation. Username and password are verified.

3. Logout -
User logs out of this application

4. Tweet -
User when connected can send tweet. Hashtags and mentions may be included in tweet. This tweet is sent to Twitter Engine and engine stores it in ‘tweets_by_user’ table correponding to that user. Also, tweets are stored in ‘hashtag_table’ and ‘mention_table’ as per the hashtag and/or mention used in tweet. 

5. Subscribe to other users -
User can subscribe to other user, so that it can receive tweets by that user.‘subscriptions’ table is used in Twitter Engine to store the subscriptions on a user.

6. Re-tweet -
A user can retweet a tweet made by one of its subscriptions so that user’s followers also get this tweet by clicking on retweet button.

7. Tweets with specific hashtag -
This function returns all the tweets containing that hashtag. 

8. Tweets with specific mention -
This function returns all the tweets containing that mention. 

9. Live feed -
User should receive, without quering, tweet containing his mention or made by the user whom he subscribed to. 

All these functionalities are working as intended.








