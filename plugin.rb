# frozen_string_literal: true

# name: discourse-seo
# about: Custom SEO tool for Discourse with targeted indexability controls
# version: 0.1.0
# authors: Raven
# url: https://github.com/gorfist/discourse-seo
# required_version: 2.7.0

module ::DiscourseSeo
  PLUGIN_NAME = "discourse-seo"
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
    Topic.register_custom_field_type ::DiscourseSeo::NOINDEX_CUSTOM_FIELD, :boolean

    add_to_class(:topic, :noindex) do
      ::DiscourseSeo.topic_noindex?(self)
    end

    module ::DiscourseSeoTopicViewExtension
      def canonical_path
        return super unless post_number.to_i > 1
        return super if SiteSetting.embed_set_canonical_url && topic.topic_embed.present?

        case SiteSetting.canonical_topic_post_urls
        when "self"
          "#{relative_url}/#{post_number}"
        when "topic_root"
          relative_url
        else
          super
        end
      end
    end

    ::TopicView.prepend ::DiscourseSeoTopicViewExtension

    module ::DiscourseSeoTopicsControllerExtension
      def show
        super

        if SiteSetting.discourse_category_topic_noindex_enabled &&
             ::DiscourseSeo.topic_noindex?(@topic_view&.topic)
          ::DiscourseSeo.add_noindex_header(response)
        end
      end
    end

    ::TopicsController.prepend ::DiscourseSeoTopicsControllerExtension
  end
end
