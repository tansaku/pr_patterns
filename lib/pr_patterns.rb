require 'octokit'

class PRPatterns

  def initialize(client = Octokit::Client.new(:login => ENV['GITHUB_USERNAME'], :password => ENV['GITHUB_PASSWORD']))
    @client = client
  end

  def review_stats(prs = client.pull_requests(ENV['GITHUB_REPO_TO_REVIEW'], state: 'closed'))
    prs.map do |pr| 
      reviews = client.pull_request_reviews(ENV['GITHUB_REPO_TO_REVIEW'],pr.number)
      reviewers = reviews.map{|r| r.user.login}
      codeclimate_count = reviewers.count("codeclimate[bot]")
      human_reviewers = reviewers.select{|r| r != "codeclimate[bot]"}
      [pr.created_at, "https://github.com/#{ENV['GITHUB_REPO_TO_REVIEW']}/pull/#{pr.number}", pr.user.login, codeclimate_count, human_reviewers].flatten
    end
  end

  private 

  attr_reader :client

end