# Discourse Category Topic Noindex

Adds an `X-Robots-Tag: noindex` response header to Discourse topic pages when the topic belongs to a selected category.

This is useful when categories should remain public for people but should not be indexed by search engines.

## Installation

Add the plugin to your Discourse container's `app.yml`:

```yml
hooks:
  after_code:
    - exec:
        cd: $home/plugins
        cmd:
          - git clone https://github.com/gorfist/discourse-category-topic-noindex.git
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

Every topic in a selected category will return:

```http
X-Robots-Tag: noindex
```

The plugin also honors the legacy topic custom field `noindex`, so topics previously marked by `discourse-topic-noindex` continue to receive the header.

## Locales

Included locales:

- English: `config/locales/server.en.yml`
- Persian: `config/locales/server.fa_IR.yml`
