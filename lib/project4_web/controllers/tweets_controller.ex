defmodule Project4Web.TweetsController do
    use Project4Web, :controller
  
    def show(conn, _params) do
      render conn, "home.html"
   
    end
  end
  