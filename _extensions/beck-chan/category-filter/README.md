# Quarto Mobile Categories Extension

When enabled, [Quarto's category page filters]((https://quarto.org/docs/websites/website-listings.html#categories) ) display in the right margin on desktop, but are hidden by default on mobile. 

This extension allows you to embed a category filter as an inline drop-down for mobile view.

## Prerequisites

## Install

```bash
quarto add beck-chan/quarto-mobile-categories
```

## Usage

Add the filter to the YAML frontmatter on a `.qmd` file or your top-level `_quarto.yml`:

```yaml
filters:
  - mobile-categories
```

### Example

Appears on any page with listings and `categories: true` enabled.


```markdown
---
listing:
  - id: posts
    contents: "posts"
    categories: true
filters:
  - mobile-categories
---

::: {.posts}
:::
```

Extra classes on the div are preserved if you want to style the embed in your theme:

```markdown
::: {.mobile-categories .my-filter-styles}
:::
```

## Reference

| Class | Notes |
|---|---|
| `.mobile-categories` | Required fenced-div class that becomes the dropdown |

## Support

> If you liked this extension and found it useful, please consider donating via Ko-fi: [https://ko-fi.com/beckchan](https://ko-fi.com/beckchan)
