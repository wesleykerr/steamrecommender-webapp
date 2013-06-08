require 'net/http'

module Couch
  class Server
    def initialize(host, port, options = nil)
      @host = host
      @port = port
      @options = options
    end

    def get(uri)
      request(Net::HTTP::Get.new(uri))
    end

    def post(uri, json)
      req = Net::HTTP::Post.new(uri)
      req['content-type'] = 'application/json'
      req.body = json
      request(req)
    end
    
    def put(uri, json)
      req = Net::HTTP::Put.new(uri)
      req['content-type'] = 'application/json'
      req.body = json
      request(req)
    end

    private
    def request(req)
      res = Net::HTTP.start(@host, @port) { |http| http.request(req) }
      unless res.kind_of?(Net::HTTPSucess)
        handle_error(req, res)
      end
    end

    def handle_error(req, res)
      msg = "#{res.code}:#{res.message}\n"
      msg << "METHOD:#{req.method}\n"
      msg << "URI:#{req.path}\n"
      msg << "#{req.body}"
      raise RuntimeError.new(msg)
    end
  end
end
