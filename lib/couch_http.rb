
require 'net/http'
require 'uri'
require 'json'

def get(uri)
    JSON.parse(Net::HTTP.get(URI(uri)))
end

def put(uri,doc) 
    uri = URI.parse(uri)
    header = {'Content-Type'=> 'application/json'}
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Put.new(uri.request_uri, header)
    request.body = doc.to_json
    response = http.request(request)
    JSON.parse(response.body)
end

def post(uri,doc) 
    uri = URI.parse(uri)
    header = {'Content-Type'=> 'application/json'}
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.body = doc.to_json
    response = http.request(request)
    JSON.parse(response.body)
end

def delete(uri)
    uri = URI.parse(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Delete.new(uri.request_uri)
    response = http.request(request)
    JSON.parse(response.body)
end
