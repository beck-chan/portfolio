# Fold Code

HTML filter that wraps static fenced code blocks in a `<details>` toggle. Quarto's built-in `code-fold` only covers executable cell output, so this fills the gap for `{.yaml}`, `{.bash}`, and other static blocks.

Requires Quarto `>= 1.4.0`.

## Installation

Copy this directory into your project:

```
your-project/
  _extensions/
    beck-chan/
      fold-code/
        _extension.yml
        fold-code.lua
```

Then enable the filter in `_quarto.yml`:

```yaml
filters:
  - fold-code
```

In this portfolio the extension is already installed and listed under `filters`. The filter only affects HTML output.

## Usage

Add `fold=true` to a fenced code block to collapse it:

````markdown
```{.yaml fold=true}
key: value
```
````

Start expanded with a custom summary label:

````markdown
```{.yaml fold=show fold-summary="Show config"}
key: value
```
````

`{.fold}` on the block is the same as `fold=true`.

| Attribute | Values | Default |
|---|---|---|
| `fold` | `true`, `1`, `hide` — collapsed; `show` — expanded; `false`, `0`, `none` — leave unfolded | off |
| `fold-summary` | summary label text | `show code` |
