# discourse seo

`discourse seo` is a custom tool for custom SEO-focused modifications over Discourse.

This plugin currently adds an `X-Robots-Tag: noindex` response header to topic pages when a topic belongs to selected categories, helping you control what search engines can index.

## Installation

Add `discourse seo` to your Discourse container's `app.yml`:

```yml
hooks:
  after_code:
    - exec:
        cd: $home/plugins
        cmd:
          - git clone https://github.com/gorfist/discourse-seo.git
```

Rebuild Discourse:

```sh
cd /var/discourse
./launcher rebuild app
```

## Configuration

In Discourse admin settings:

1. Enable `discourse category topic noindex enabled`.
2. Select categories in `category topic noindex categories`.
3. Choose canonical behavior in `canonical topic post urls`:
   - `self` (default): `/t/topic/16654/6` keeps canonical `/t/topic/16654/6`
   - `topic_root`: `/t/topic/16654/6` uses canonical `/t/topic/16654`

Every topic in a selected category will return:

```http
X-Robots-Tag: noindex
```

The tool also honors the legacy topic custom field `noindex`, so topics previously marked by `discourse-topic-noindex` continue to receive the header.

## Canonical URL Override

`discourse seo` can override canonical tags for topic post URLs without redirecting or changing route structure.

- `canonical_topic_post_urls = self`: each post URL remains self-canonical.
- `canonical_topic_post_urls = topic_root`: post URLs canonicalize to the topic root URL.

## Locales

Included locales:

- English: `config/locales/server.en.yml`
- Persian: `config/locales/server.fa_IR.yml`
