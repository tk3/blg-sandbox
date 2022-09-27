#!/usr/bin/env ruby

require 'net/http'
require 'json'
require 'dotenv'

Dotenv.load

hostname = ENV['BACKLOG_HOSTNAME']
api_key = ENV['BACKLOG_API_KEY']

#url = URI.parse('http://localhost:12345/api/v2/space')
#api = Blg::Api.new('https://tk4.backlog.com')

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
      def get_space
        get('/space')
      end
    end
  end
end

module Blg
  module Api
    module Project
      def get_projects(params = {})
        get('/projects')
      end

      def get_versions(project_id_or_key)
        get('/projects/' + project_id_or_key.to_s + '/versions')
      end
    end
  end
end

module Blg
  module Api
    module Issue
      def get_issues(params = {})
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

    def initialize(hostname, api_key)
      @hostname = hostname
      @api_key = api_key
      @endpoint = 'https://' + @hostname + '/api/v2'
      pp @endpoint
    end
  end

  class Client::Base
  end
end

api = Blg::Client.new(hostname, api_key)

require 'pp'

pp api.get_space
projects = api.get_projects
pp projects
pp api.get_projects({:archived => true})
pp api.get_issues
pp api.get_versions(projects[0]['id'])

