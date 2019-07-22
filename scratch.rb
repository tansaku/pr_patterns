require 'octokit'

client = Octokit::Client.new(:login => ENV['GITHUB_USERNAME'], :password => ENV['GITHUB_PASSWORD'])

# ENV['GITHUB_REPO_TO_REVIEW'] e.g. 'tansaku/pr_patterns'
prs = client.pull_requests(ENV['GITHUB_REPO_TO_REVIEW'], state: 'closed')

review_stats = prs.map do |pr| 
  reviews = client.pull_request_reviews(ENV['GITHUB_REPO_TO_REVIEW'],pr.number)
  reviewers = reviews.map{|r| r.user.login}
  codeclimate_count = reviewers.count("codeclimate[bot]")
  human_reviewers = reviewers.select{|r| r != "codeclimate[bot]"}
  [pr.created_at, "https://github.com/tusker-direct/hobgoblin/pull/#{pr.number}", pr.user.login, codeclimate_count, human_reviewers].flatten
end

nodes = []
review_stats.each do |rs|
  nodes << { name: rs[2] } unless nodes.include?({name: rs[2]})
  nodes << { name: rs[4] } unless nodes.include?({name: rs[4]})
end

links = []
prs.map do |pr| 
  reviews = client.pull_request_reviews(ENV['GITHUB_REPO_TO_REVIEW'],pr.number)
  reviewers = reviews.map{|r| r.user.login}
  human_reviewers = reviewers.select{|r| r != "codeclimate[bot]"}
  
  human_reviewers.each do |hr|
    creator = nodes.index({name: pr.user.login})
    reviewer = nodes.index({name: hr})
    existing = links.select {|link| link[:source] == creator and link[:target] == reviewer}  
    if existing.length > 0
      existing[0][:weight] += 1
    else
      links << {source: creator, target: reviewer, weight: 1}
    end
  end
end


require "csv"
File.write("pr_reviews_closed2.csv", review_stats.map(&:to_csv).join)
File.write("graphFile2.json",{nodes: nodes, links: links}.to_json)
