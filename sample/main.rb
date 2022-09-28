#!/usr/bin/env ruby

require 'net/http'
require 'json'
require 'dotenv'


module Blg
  module Request
    def get(api_path, params = {})
      url = URI.parse(@endpoint)

      query_string = {'apiKey' => @api_key}
      url.path = url.path + api_path
      url.query = URI.encode_www_form(query_string.merge(params))

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      req = Net::HTTP::Get.new(url.request_uri)
      req['User-Agent'] = 'blg ' + Blg::VERSION
      req['Accept'] = 'application/json'
      res = http.request(req)

      JSON.parse(res.body)
    end
  end
end

module Blg
  module Api
    module Space
      def space
        get('/space')
      end
    end
  end
end

module Blg
  module Api
    module Project
      def projects(params = {})
        get('/projects')
      end

      def versions(project_id_or_key)
        get('/projects/' + project_id_or_key.to_s + '/versions')
      end
    end
  end
end

module Blg
  module Api
    module Issue
      def issues(params = {})
        get('/issues')
      end
    end
  end
end

module Blg
  VERSION = '0.0.1'
end

module Blg

  class Client
    include Blg::Request
    include Blg::Api::Space
    include Blg::Api::Project
    include Blg::Api::Issue

    def initialize(endpoint, api_key)
      @endpoint = endpoint
      @api_key = api_key
    end
  end

  class Client::Base
  end
end


Dotenv.load

endpoint = ENV['BACKLOG_API_ENDPOINT']
api_key = ENV['BACKLOG_API_KEY']

api = Blg::Client.new(endpoint, api_key)

require 'pp'

pp api.space
projects = api.projects
pp projects
pp api.projects({:archived => true})
pp api.issues
pp api.versions(projects[0]['id'])

