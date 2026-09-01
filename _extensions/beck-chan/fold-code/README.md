# Fold Code

[Quarto's build-in option for folding code](https://quarto.org/docs/output-formats/html-code.html#folding-code) only covers executable cell output. This extension allows non-executable fenced code blocks to be wrapped in a `<details>` toggle. 

## Prerequisites

Requires Quarto `>= 1.4.0`.

## Usage Examples

Add `fold=true` to a fenced code block to collapse it:

````markdown
```{.yaml fold=true}
key: value
```
````

Start expanded with a custom summary label:

````markdown
```{.yaml fold=false summary="Show config"}
key: value
```
````

## Reference

`{.fold}` on the block is the same as `fold=true`.

| Attribute | Values | Default |
|---|---|---|
| `fold` | `true` — collapsed; `false` — expanded | off |
| `summary` | summary label text | `show code` |
