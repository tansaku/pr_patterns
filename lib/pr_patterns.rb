# frozen_string_literal: true

require 'dotenv'
Dotenv.load

require 'octokit'
require 'csv'
require 'json'

class PRPatterns
  def self.run(client = default_client, prs = nil)
    instance = new(client, prs)
    instance.to_csv
    instance.to_json
  end

  def initialize(client = default_client, prs = nil)
    @client = client
    @prs = prs || default_prs
  end

  def to_csv(output_klass = File)
    output_klass.write('pr_reviews_closed2.csv', review_stats.map(&:to_csv).join)
  end

  def to_json(output_klass = File)
    output_klass.write('graphFile2.json', { nodes: nodes, links: links }.to_json)
  end

  private

  def review_stats
    @review_stats ||= prs.map do |pr|
      reviews = client.pull_request_reviews(ENV['GITHUB_REPO_TO_REVIEW'], pr.number)
      reviewers = reviews.map { |r| r.user.login }
      codeclimate_count = reviewers.count('codeclimate[bot]')
      human_reviewers = reviewers.reject { |r| r == 'codeclimate[bot]' }
      [pr.created_at, "https://github.com/#{ENV['GITHUB_REPO_TO_REVIEW']}/pull/#{pr.number}", pr.user.login, codeclimate_count, human_reviewers].flatten
    end
  end

  def nodes
    @nodes ||= review_stats.each_with_object([]) do |rs, memo|
      memo << { name: rs[2] } unless memo.include?(name: rs[2])
      memo << { name: rs[4] } unless memo.include?(name: rs[4])
    end
  end

  def links
    @links ||= prs.each_with_object([]) do |pr, memo|
      reviews = client.pull_request_reviews(ENV['GITHUB_REPO_TO_REVIEW'], pr.number)
      reviewers = reviews.map { |r| r.user.login }
      human_reviewers = reviewers.reject { |r| r == 'codeclimate[bot]' }

      human_reviewers.each do |hr|
        creator = nodes.index(name: pr.user.login)
        reviewer = nodes.index(name: hr)
        existing = memo.select { |link| (link[:source] == creator) && (link[:target] == reviewer) }
        if !existing.empty?
          existing[0][:weight] += 1
        else
          memo << { source: creator, target: reviewer, weight: 1 }
        end
      end
    end
  end

  attr_reader :client, :prs

  def self.default_client
    Octokit::Client.new(login: ENV['GITHUB_USERNAME'], password: ENV['GITHUB_PASSWORD'])
  end

  def default_prs
    client.pull_requests(ENV['GITHUB_REPO_TO_REVIEW'], state: 'closed')
  end
end
