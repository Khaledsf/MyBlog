require 'rack'
require 'ap'
require 'sqlite3'
require 'erubis'
require 'uri'

class App
    def initialize
        @db = SQLite3::Database.new "kbblog.db"
    end
    def call(env)
        ap env
        case env["REQUEST_METHOD"]
        when "GET"
            get(env)
        when "POST"
            post(env)
        end
    end

    private
    def get(env)
        req = Rack::Request.new(env)
        response = Rack::Response.new
        response.status = 404
        response["Content-Type"] = "text/html"
        response.body = ["<h1>404 Not Found</h1>"]

        if env["PATH_INFO"] == "/"
            response = renderIndex(req)
        else
            path = File.expand_path("public/#{env['PATH_INFO']}")
            if File.exists?(path)
                response.status = 200
                response.body = [File.open(path, "rb").read]
            end
        end

        response.finish
    end

    def post(env)
        req = Rack::Request.new(env)
        response = Rack::Response.new
        response.status = 200
        # Login always works!
        if env["PATH_INFO"] == "/login"
            if req.params["fname"] == "khaled" && req.params["lname"] == "bouchama"
                response["Content-Type"] = "text/html"
                response.body = [File.open("public/admin.html", "rb").read]
            else
                response.status = 401
                response["Content-Type"] =  "text/html"
                response.body = ["<h1>401 Unauthorized</h1>"]
            end
        elsif env["PATH_INFO"] == "/posts/new"
            # Execute a few inserts
            ap req.params
            post = req.params['post'].sub("'", "\'")
            post = req.params['post'].sub('"', '\"')
            @db.execute "insert into posts(title,post) values ('#{req.params['title']}', '#{post}')"
            response = renderIndex(req)
        end

        response.finish
    end

    def renderIndex(req)
        @posts = @db.execute "select * from posts"
        ap @posts
        renderer = Erubis::Eruby.new(File.open("public/index.html", "rb").read)
        response = Rack::Response.new
        response.status = 200
        response["Content-Type"] = "text/html"
        response.body = [renderer.result({posts: @posts})]
        # response.body = [File.open("public/index.html", "rb").read]
        response
    end
end
Rack::Handler::WEBrick.run(App.new, :Port => 8080)