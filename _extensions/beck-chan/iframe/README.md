# Iframe

Embeds an iframe with a fenced div with options to include a caption under the iframe, as well as adjust zoom, sizing, and loading configurations.

## Prerequisites

Requires Quarto `>= 1.4.0`.

## Usage Examples

Only `url` is required. `title` becomes the caption under the iframe. An SVG control in the bottom-left corner opens the source URL in a new window by default:

```markdown
::: {.iframe url="https://example.com" title="Example site"}
:::
```

Override defaults when you need a different size, zoom, or alignment:

```markdown
::: {.iframe url="https://example.com" title="Example site" zoom="80%" width="90%" height=720 align="left" valign="top"}
:::
```

Hide the open-in-new-window control:

```markdown
::: {.iframe url="https://example.com" title="Example site" new-window="false"}
:::
```

## Reference

| Attribute | Default | Notes |
|---|---|---|
| `url` / `src` | Required input | Iframe source URL |
| `title` | — | Caption under the frame and used as the iframe `title` |
| `zoom` | `60%` | Also accepts `75` or `0.75` |
| `width` | `100%` | Visible viewport width |
| `height` | `560` | Unitless numbers become `px` |
| `align` | `center` | `left`, `center`, or `right` on the page |
| `valign` | `center` | `top`, `center` or `middle` (valign), or `bottom` in a flex/grid parent |
| `loading` | `lazy` | Iframe `loading` attribute |
| `new-window` | `true` | SVG control in the bottom-left that opens the iframe URL in a new window. Set `false` / `off` / `no` to hide it |
| `class` | `pics` | Extra style classes can be passed with `class="..."` or `{.iframe .your-class}` |
