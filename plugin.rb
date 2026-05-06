# frozen_string_literal: true

# name: discourse-category-topic-noindex
# about: Add X-Robots-Tag noindex to topics in selected categories
# version: 0.1.0
# authors: Raven
# url: https://github.com/gorfist/discourse-category-topic-noindex
# required_version: 2.7.0

enabled_site_setting :discourse_category_topic_noindex_enabled

module ::DiscourseCategoryTopicNoindex
  PLUGIN_NAME = "discourse-category-topic-noindex"
  NOINDEX_CUSTOM_FIELD = "noindex"

  def self.category_ids
    SiteSetting.category_topic_noindex_categories.to_s.split("|").map(&:to_i).select(&:positive?)
  end

  def self.topic_noindex?(topic)
    return false if topic.blank?

    topic.custom_fields[NOINDEX_CUSTOM_FIELD] == true ||
      topic.custom_fields[NOINDEX_CUSTOM_FIELD] == "true" ||
      category_ids.include?(topic.category_id)
  end

  def self.add_noindex_header(response)
    header = response.headers["X-Robots-Tag"].to_s
    return if header.downcase.split(/\s*,\s*/).include?("noindex")

    response.headers["X-Robots-Tag"] = header.present? ? "#{header}, noindex" : "noindex"
  end
end

after_initialize do
  reloadable_patch do
    Topic.register_custom_field_type ::DiscourseCategoryTopicNoindex::NOINDEX_CUSTOM_FIELD, :boolean

    add_to_class(:topic, :noindex) do
      ::DiscourseCategoryTopicNoindex.topic_noindex?(self)
    end

    module ::CategoryTopicNoindexTopicsControllerExtension
      def show
        super

        if SiteSetting.discourse_category_topic_noindex_enabled &&
             ::DiscourseCategoryTopicNoindex.topic_noindex?(@topic_view&.topic)
          ::DiscourseCategoryTopicNoindex.add_noindex_header(response)
        end
      end
    end

    ::TopicsController.prepend ::CategoryTopicNoindexTopicsControllerExtension
  end
end
