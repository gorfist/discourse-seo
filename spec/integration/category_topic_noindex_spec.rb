# frozen_string_literal: true

describe "discourse-category-topic-noindex plugin" do
  fab!(:category)
  fab!(:other_category) { Fabricate(:category) }
  fab!(:topic) { Fabricate(:topic, category: category) }
  fab!(:other_topic) { Fabricate(:topic, category: other_category) }

  before { SiteSetting.discourse_category_topic_noindex_enabled = true }

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

end
