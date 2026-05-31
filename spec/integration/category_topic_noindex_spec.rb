# frozen_string_literal: true

require "rails_helper"

describe "discourse-seo plugin" do
  fab!(:category)
  fab!(:other_category) { Fabricate(:category) }
  fab!(:topic) { Fabricate(:topic, category: category) }
  fab!(:other_topic) { Fabricate(:topic, category: other_category) }
  fab!(:reply) { Fabricate(:post, topic: topic) }

  before do
    SiteSetting.discourse_category_topic_noindex_enabled = true
    SiteSetting.canonical_topic_post_urls = "self"
  end

  def canonical_href
    canonical_tag = response.body.match(/<link(?=[^>]*rel=["']canonical["'])[^>]*>/i)&.[](0)
    canonical_tag&.match(/href=["']([^"']+)["']/i)&.[](1)
  end

  it "sets the noindex header for topics in selected categories" do
    SiteSetting.category_topic_noindex_categories = category.id.to_s

    get "/t/#{topic.slug}/#{topic.id}"

    expect(response.headers["X-Robots-Tag"]).to eq("noindex")
  end

  it "does not set the noindex header for topics in other categories" do
    SiteSetting.category_topic_noindex_categories = category.id.to_s

    get "/t/#{other_topic.slug}/#{other_topic.id}"

    expect(response.headers["X-Robots-Tag"]).to be_nil
  end

  it "does not set the noindex header when the plugin is disabled" do
    SiteSetting.discourse_category_topic_noindex_enabled = false
    SiteSetting.category_topic_noindex_categories = category.id.to_s

    get "/t/#{topic.slug}/#{topic.id}"

    expect(response.headers["X-Robots-Tag"]).to be_nil
  end

  it "honors the legacy topic noindex custom field" do
    topic.custom_fields["noindex"] = true
    topic.save!

    get "/t/#{topic.slug}/#{topic.id}"

    expect(response.headers["X-Robots-Tag"]).to eq("noindex")
  end

  it "keeps post URLs self-canonicalized when canonical_topic_post_urls is self" do
    SiteSetting.canonical_topic_post_urls = "self"

    get "/t/#{topic.slug}/#{topic.id}/#{reply.post_number}"

    expect(canonical_href).to end_with("/t/#{topic.slug}/#{topic.id}/#{reply.post_number}")
  end

  it "canonicalizes post URLs to topic root when canonical_topic_post_urls is topic_root" do
    SiteSetting.canonical_topic_post_urls = "topic_root"

    get "/t/#{topic.slug}/#{topic.id}/#{reply.post_number}"

    expect(canonical_href).to end_with("/t/#{topic.slug}/#{topic.id}")
  end
end
