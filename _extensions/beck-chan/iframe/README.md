# Iframe

HTML filter that embeds a zoomable iframe from a fenced div. Optional `title` text is rendered as a caption under the frame.

Requires Quarto `>= 1.4.0`.

## Installation

Copy this directory into your project:

```
your-project/
  _extensions/
    beck-chan/
      iframe/
        _extension.yml
        iframe.lua
        iframe.css
```

Then enable the filter in `_quarto.yml`:

```yaml
filters:
  - iframe
```

In this portfolio the extension is already installed and listed under `filters`. The filter only affects HTML output. The default `.pics` class is styled by this site's theme; other projects should define `.pics` (and `figcaption`) themselves if they want the same border, shadow, and caption look.

## Usage

Only `url` is required. `title` becomes the caption under the iframe:

```markdown
::: {.iframe url="https://example.com" title="Example site"}
:::
```

Override defaults when you need a different size, zoom, or alignment:

```markdown
::: {.iframe url="https://example.com" title="Example site" zoom="80%" width="90%" height=720 align="left" valign="top"}
:::
```

`src` is an alias for `url`. Extra classes can be passed with `class="..."` or `{.iframe .your-class}`. `.pics` is always applied. `align` and `valign` default to `center`; `middle` is accepted for `valign`.

| Attribute | Default | Notes |
|---|---|---|
| `url` / `src` | required | iframe source |
| `title` | — | caption under the iframe; also used as the iframe `title` |
| `zoom` | `60%` | also accepts `75` or `0.75` |
| `width` | `100%` | visible viewport width |
| `height` | `560` | unitless numbers become `px` |
| `align` | `center` | `left`, `center`, or `right` on the page |
| `valign` | `center` | `top`, `center`/`middle`, or `bottom` in a flex/grid parent |
| `loading` | `lazy` | iframe `loading` attribute |
| `class` | `pics` | extra classes are added alongside `pics` |
