require 'spec_helper'
require './lib/pr_patterns'

describe PRPatterns do
  let(:client) {double :client, pull_requests: [pr], pull_request_reviews: []}
  subject(:pr_patterns) { described_class.new(client) }

  let(:pr) { double('Sawyer::Resource',
                    url: 'https://api.github.com/repos/AgileVentures/LocalSupport/pulls/1154',
                    id: 304551105,
                    number: 1154, 
                    created_at: '2019-08-06 05:17:58 UTC',
                    user: user)}
  let(:user) {double :user, login: "dependabot-preview[bot]"}

  it '#review_stats' do
    pr_patterns.review_stats
  end

end