defmodule Project4Web.RegisterController do
    use Project4Web, :controller

    def register(conn, _params) do
        IO.puts "registering now..."
        render conn, "index.html"
    end
end
