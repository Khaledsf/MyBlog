require 'rack'
require 'ap'

class App
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
        status_code = 404
        headers = {
            "Content-Type" => "text/html"
        }
        body = ["<h1>404 Not Found</h1>"]

        if env["PATH_INFO"] == "/"
            status_code = 200
            body = [File.open(File.expand_path((File.dirname(__FILE__))) + "/public/index.html", "rb").read]
        else
            path = File.expand_path("#{File.dirname(__FILE__)}/public/#{env['PATH_INFO']}")
            if File.exists?(path)
                status_code = 200
                body = [File.open(path, "rb").read]
            end
        end

        [status_code,headers,body]
    end

    def post(env)
        [
            200,
            {
                'Content-Type' => 'text/html'
            },
            [
                "Gettin' racked."
            ]
        ]
    end
end

Rack::Handler::WEBrick.run(App.new, :Port => 1234)