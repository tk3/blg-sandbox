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
  Space = Struct.new(
    :space_key,
    :name,
    :owner_id,
    :lang,
    :timezone,
    :report_send_time,
    :text_formatting_rule,
    :created,
    :updated
  )

  module Api
    module Space
      def get_space
        url = URI.parse('https://' + @hostname)
 
        query_string = {'apiKey' => @api_key}
        url.path = '/api/v2/space'
        url.query = URI.encode_www_form(query_string)
 
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
 
        req = Net::HTTP::Get.new(url.request_uri)
        req['User-Agent'] = 'blg ' + Blg::VERSION
        req['Accept'] = 'application/json'
        res = http.request(req)
        puts res.body
 
        json = JSON.parse(res.body)
        Blg::Space.new(
          json['spaceKey'],
          json['name'],
          json['ownerId'],
          json['lang'],
          json['timezone'],
          json['reportSendTime'],
          json['textFormattingRule'],
          json['created'],
          json['updated']
        )
      end
    end
  end
end

module Blg
  Project = Struct.new(
    :id,
    :project_key,
    :name,
    :chart_enabled,
    :use_resolved_for_chart,
    :subtasking_enabled,
    :project_leader_can_edit_project_leader,
    :use_wik,
    :use_file_sharing,
    :use_wiki_treeView,
    :use_original_image_size_at_wiki,
    :text_formatting_rule,
    :archived,
    :display_order,
    :use_dev_attributes
  )

  module Api
    module Project
      def get_projects(params = {})
        url = URI.parse('https://' + @hostname)
 
        query_string = {'apiKey' => @api_key}
        url.path = '/api/v2/projects'
        url.query = URI.encode_www_form(query_string.merge(params))  # TODO: Prevent api_key from being overwritten
 
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
 
        req = Net::HTTP::Get.new(url.request_uri)
        req['User-Agent'] = 'blg ' + Blg::VERSION
        req['Accept'] = 'application/json'
        res = http.request(req)
#       puts res.body
 
        json_projects = JSON.parse(res.body)
        json_projects.map do |json_project|
          Blg::Project.new(
            json_project['id'],
            json_project['projectKey'],
            json_project['name'],
            json_project['chartEnabled'],
            json_project['useResolvedForChart'],
            json_project['subtaskingEnabled'],
            json_project['projectLeaderCanEditProjectLeader'],
            json_project['useWiki'],
            json_project['useFileSharing'],
            json_project['useWikiTreeView'],
            json_project['useOriginalImageSizeAtWiki'],
            json_project['textFormattingRule'],
            json_project['archived'],
            json_project['displayOrder'],
            json_project['useDevAttributes']
          )
        end

      end
    end
  end
end

module Blg
  Issue = Struct.new(
    :id,
    :project_id,
    :issue_key,
    :key_id,
    :issue_type,
    :summary,
    :description,
    :resolution,
    :priority,
    :status,
    :assignee,
    :start_date,
    :due_date,
    :estimated_hours,
    :actual_hours,
    :parent_issue_id,
    :created,
    :updated
  )

  IssueType = Struct.new(
    :id,
    :project_id,
    :name,
    :color,
    :display_order
  )

  Priority = Struct.new(
    :id,
    :name
  )

  Status = Struct.new(
    :id,
    :project_id,
    :name,
    :color,
    :display_order
  )

  NulabAccount = Struct.new(
    :nulab_id,
    :name,
    :unique_id
  )

  User = Struct.new(
    :id,
    :user_id,
    :name,
    :role_type,
    :lang,
    :mail_address,
    :nulab_account,
    :keyword,
    :last_login_time
  )

  module Api
    module Issue
      def get_issues(params = {})
        url = URI.parse('https://' + @hostname)
 
        query_string = {'apiKey' => @api_key}
        url.path = '/api/v2/issues'
        url.query = URI.encode_www_form(query_string.merge(params))  # TODO: Prevent api_key from being overwritten
 
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
 
        req = Net::HTTP::Get.new(url.request_uri)
        req['User-Agent'] = 'blg ' + Blg::VERSION
        req['Accept'] = 'application/json'
        res = http.request(req)
        puts res.body
 
        json_issues = JSON.parse(res.body)
        json_issues.map do |json_issue|
          Blg::Issue.new(
            json_issue['id'],
            json_issue['projectId'],
            json_issue['issueKey'],
            json_issue['keyId'],
            Blg::IssueType.new(
              json_issue['issueType']['id'],
              json_issue['issueType']['projectId'],
              json_issue['issueType']['name'],
              json_issue['issueType']['color'],
              json_issue['issueType']['displayOrder'],
            ),
            json_issue['summary'],
            json_issue['description'],
            json_issue['resolution'],
            Blg::Priority.new(
              json_issue['priority']['id'],
              json_issue['priority']['name']
            ),
            Blg::Status.new(
              json_issue['status']['id'],
              json_issue['status']['projectId'],
              json_issue['status']['name'],
              json_issue['status']['color'],
              json_issue['status']['displayOrder'],
            ),
            Blg::User.new(
              json_issue['assignee']['id'],
              json_issue['assignee']['userId'],
              json_issue['assignee']['name'],
              json_issue['assignee']['roleType'],
              json_issue['assignee']['lang'],
              json_issue['assignee']['mailAddress'],
              Blg::NulabAccount.new(
                json_issue['assignee']['nulabAccount']['nulabId'],
                json_issue['assignee']['nulabAccount']['name'],
                json_issue['assignee']['nulabAccount']['uniqueId']
              ),
              json_issue['assignee']['keyword'],
              json_issue['assignee']['lastLoginTime']
            ),
            json_issue['startDate'],
            json_issue['dueDate'],
            json_issue['estimatedHours'],
            json_issue['actualHours'],
            json_issue['parentIssueId'],
            json_issue['created'],
            json_issue['updated']
          )
        end
      end
    end
  end
end

module Blg
  VERSION = '0.0.1'
end

module Blg

  class Client
    include Blg::Api::Space
    include Blg::Api::Project
    include Blg::Api::Issue

    def initialize(hostname, api_key)
      @hostname = hostname
      @api_key = api_key
    end

  end
end

api = Blg::Client.new(hostname, api_key)

require 'pp'

pp api.get_space
pp api.get_projects
pp api.get_projects({:archived => true})
pp api.get_issues

