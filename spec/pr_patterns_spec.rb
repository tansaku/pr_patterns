# frozen_string_literal: true

require 'spec_helper'
require './lib/pr_patterns'

describe PRPatterns do
  let(:client) { double :client, pull_requests: [pr], pull_request_reviews: [] }
  subject(:pr_patterns) { described_class.new(client) }

  let(:pr) do
    double('Sawyer::Resource',
           url: 'https://api.github.com/repos/AgileVentures/LocalSupport/pulls/1154',
           id: 304_551_105,
           number: 1154,
           created_at: '2019-08-06 05:17:58 UTC',
           user: user)
  end
  let(:user) { double :user, login: 'dependabot-preview[bot]' }

  let(:output_klass) { spy File }
  let(:csv) { "2019-08-06 05:17:58 UTC,https://github.com//pull/1154,dependabot-preview[bot],0\n" }
  let(:json) { '{"nodes":[{"name":"dependabot-preview[bot]"},{"name":null}],"links":[]}' }

  it '#to_csv' do
    pr_patterns.to_csv(output_klass)
    expect(output_klass).to have_received(:write).with('pr_reviews_closed2.csv', csv)
  end

  it '#to_json' do
    pr_patterns.to_json(output_klass)
    expect(output_klass).to have_received(:write).with('graphFile2.json', json)
  end
end
