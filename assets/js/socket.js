
import {Socket} from "phoenix"

let socket = new Socket("/socket", {params: {token: window.userToken}})

socket.connect()

// Now that you are connected, you can join channels with a topic:
let channel = socket.channel("rooms:lobby", {})
channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

export default socket

//UI code
let messagesDiv = $('#tweet-container');
messagesDiv.empty();

let loginContainer = $('#login-container');


let loginUsername = $("#login-username");
let loginPassword = $("#login-password");
let loginSubmit = $("#login-btn");

let registerUsername = $("#register-username");
let registerPassword = $("#register-password");
let registerSubmit = $("#register-btn");

var userLoggedIn;

let tweetInput = $("#tweet-box");
let tweetBtn = $("#tweet-btn");


loginSubmit.on('click', function(){
  if(loginUsername.val()==='' || loginPassword.val()==='')
    alert("Invalid username/password !!");
  else{
      channel.push("login", {username: loginUsername.val(), password: loginPassword.val()})
      loginUsername.val("");
      loginPassword.val("");
  }
});

registerSubmit.on('click', function(){
  if(registerUsername.val()==='' || registerPassword.val()==='')
    alert("Please enter valid credentials !!");
  else{
      channel.push("register", {username :registerUsername.val(), password: registerPassword.val()})
      registerUsername.val("");
      registerPassword.val("");
  }
});

let content = $('#content-container');

channel.on("registered", payload => {
  alert(payload.response)
});



channel.on("afterLogin", payload => {
  userLoggedIn = payload.username;
  if(payload.code === '0'){
    alert(userLoggedIn+" "+payload.response)
    loginContainer.css('display','none');
    tweetInput.css('display','block');
    tweetBtn.css('display','block');
    content.css('display','block');
  }
  else
    alert(payload.response);
  
});


channel.on("initiate_message", payload => {
  messagesContainer.append(`<br/>${payload.body}`);
});


let displayMyTweets = $('#show-my-tweets');
let follow = $('#follow');


displayMyTweets.on('click',function(){
  channel.push("displayMyTweets", {username: userLoggedIn});
  $('#h3-tweets').css('display',"block");

});



follow.on('click',function(){
    dissapear();
    $('#h3-follow').css('display','block');
    $('#follow-box').css('display','block');
    $('#follow-btn').css('display','block');
});

let subscribeButton = $('#follow-btn');
subscribeButton.on('click', function(){
  var subscriber = $('#follow-box').val();
  if(subscriber=='')
    alert('Please enter some subscriber !!');
  else{
    channel.push('subscription', {subscriber: subscriber, username: userLoggedIn});
    $('#follow-box').val('');
  }
});

channel.on("SubscribedUser", payload=>{
  alert(payload.response);
});

tweetBtn.on('click', function(){
  if(tweetInput.val()==='')
  alert("Please enter something to tweet !!");
else{
    channel.push("newTweet", {tweet :tweetInput.val(), username: userLoggedIn})
    tweetInput.val("");
}
});


let myTweets = $('#my-tweets');
let nav = $('#nav');
channel.on("tweetSuccess", payload=>{
  alert(payload.response);
});

channel.on("displayingMyTweets", payload=>{
  dissapear();
  $('#h3-tweets').css('display','block');
  myTweets.css('display',"block");
  myTweets.empty();
  var tweets = payload.response.split("\r\n")
  for(var a=0;a<tweets.length;a++){
    myTweets.append(`<p class='col-sm-11'>${tweets[a]}</p><br/>`);
  }
  alert(tweets[0]);
});



let liveFeed = $('#news-feed');
liveFeed.on('click', function(){
  dissapear();
  channel.push("livefeed", {username: userLoggedIn});
  $('#h3-newsfeed').css('display',"block");
});

channel.on("displayingLiveFeed", payload => {
  $('#my-news-feed').css('display','block');
  $('#my-news-feed').empty();
  var count=0;
  if(feed===""){
    $('#my-news-feed').append(`<h4>You have no tweets from subscriptions</h4>`)
  }
  else
  {
   
    var feed= payload.feed.split("\r\n")
    $('#my-news-feed').append(`<h4>Tweets from people you are subscribed to, and your mentions</h4>`)
    for(var b=0;b<=feed.length-1;b++){
      $('#my-news-feed').append(`<p class='col-sm-11'>${feed[b]}</p><button type="submit" class="btn col-sm-3 col-sm-offset-1" id="retweetBtn-${b}" style="margin-left: 10px;line-height: 0px !important; font-weight: 0px !important; height: 15px !important; width: 15% !important;">Retweet</button>`);
      count++;
    }
  }
  $('#my-news-feed').append(`<br />`)
  if(mentions===""){
    $('#my-news-feed').append(`<h4>No mentions about you</h4>`)
  }
  else{
    var mentions = payload.mentions.split("\r\n");
    for(var i=0;i<=mentions.length-1;i++){
      $('#my-news-feed').append(`<p class='col-sm-11'>${mentions[i]}</p><button type="submit" class="btn col-sm-3 col-sm-offset-1" id="retweetBtn-${i+count}" style="margin-left: 10px;line-height: 0px !important; font-weight: 0px !important; height: 15px !important; width: 15% !important;">Retweet</button>`);
    }
  }
});

$('#my-news-feed').on('click', 'button', function(){
  var id = $(this).attr('id');
  id = parseInt(id.substring(id.lastIndexOf('-')+1, id.length))+1;
  channel.push('retweet', {tweet_no:id, username: userLoggedIn});
});

channel.on('retweeted', payload => {
  alert(payload.response);
});


let hashtag = $('#query-hash');
hashtag.on('click', function(){
  dissapear();
  $('#h3-hash').css('display','block');
  $('#hash-box').css('display','block');
  $('#hash-btn').css('display','block');
});

let hashtagButton = $('#hash-btn');
hashtagButton.on('click', function(){
  var hashtag = $('#hash-box').val();
  if(hashtag=='')
    alert('Enter at least one hash string to query');
  else{
    channel.push('queryByHashtag', {hashtag: hashtag});
    $('#hash-box').val('');
  }
});

channel.on("hashtagQueried", payload=>{
  dissapear();
  $('#h3-hash').css("display","block");
  $('#my-hash').css("display","block");
  var hashtag= payload.response.split("\r\n")
  alert(hashtag);
  for(var y=0;y<hashtag.length;y++){
    $('#my-hash').append(`<p class='col-sm-11' id='${y+1}'>${hashtag[y]}</p><br/>`);
  }
});


let mention = $('#query-mention');
mention.on('click', function(){
  dissapear();
  $('#h3-mention').css('display','block');
  $('#mention-box').css('display','block');
  $('#mention-btn').css('display','block');
});

let mentionButton = $('#mention-btn');
mentionButton.on('click', function(){
  var mention = $('#mention-box').val();
  if(mention=='')
    alert('Please enter a mention to be queried !!');
  else{
    channel.push('queryByMention', {mention: mention});
    $('#mention-box').val('');
  }
});

channel.on("mentionQueried", payload=>{
  dissapear();
  $('#h3-mention').css("display","block");
  $('#my-mention').css("display","block");
  var mentions1= payload.response.split("\r\n")
  for(var z=0;z<mentions1.length;z++){
    $('#my-mention').append(`<p class='col-sm-11'>${mentions1[z]}</p><br/>`);
  }
});

function dissapear(){
  $('#h3-tweets').css('display','none');
  $('#my-tweets').css('display','none');
  $('#h3-follow').css('display','none');
  $('#follow-box').css('display','none');
  $('#follow-btn').css('display','none');
  $('#h3-newsfeed').css("display","none");
  $("#my-news-feed").css("display","none");
  $('#h3-hash').css("display","none");
  $('#hash-box').css("display","none");
  $('#hash-btn').css("display","none");
  $('#my-hash').css("display","none");
  $('#h3-mention').css("display","none");
  $('#mention-box').css("display","none");
  $('#mention-btn').css("display","none");
  $('#my-mention').css("display","none");

  



}
