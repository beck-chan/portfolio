--[[
  Collapses static fenced code blocks marked with fold=true into a
  <details> toggle. Quarto's built-in code-fold only covers cell-code
  from executable chunks, so this fills the gap for {.yaml}, {.bash}, etc.

  Usage:
    ```{.yaml fold=true}
    key: value
    ```

    ```{.yaml fold=show fold-summary="Show config"}
    key: value
    ```

  Attributes:
    fold          true|1|hide → collapsed; show → expanded; false|0|none → no fold
    fold-summary  summary label (default: "Show Code")

  Notes:
    Uses a real wrapper div (not quarto-scaffold) so margin-footnote
    numbering injects before <details>, e.g. "4 Show Code", instead of
    landing inside <details> ahead of <summary>.
]]

local function is_html()
  return quarto.doc.is_format("html:js") or quarto.doc.is_format("html")
end

local function escape_html(text)
  return text
    :gsub("&", "&amp;")
    :gsub("<", "&lt;")
    :gsub(">", "&gt;")
    :gsub('"', "&quot;")
end

local function normalize_fold(value)
  if value == nil then
    return nil
  end
  local fold = pandoc.utils.stringify(value):lower()
  if fold == "true" or fold == "1" or fold == "hide" then
    return "hide"
  elseif fold == "show" then
    return "show"
  elseif fold == "false" or fold == "0" or fold == "none" then
    return "none"
  end
  return nil
end

function CodeBlock(block)
  if not is_html() then
    return nil
  end

  local fold = normalize_fold(block.attributes["fold"])
  if fold == nil and block.classes:includes("fold") then
    fold = "hide"
  end
  if fold == nil or fold == "none" then
    return nil
  end

  local summary = block.attributes["fold-summary"] or "show code"
  summary = escape_html(pandoc.utils.stringify(summary))

  block.attributes["fold"] = nil
  block.attributes["fold-summary"] = nil
  block.classes = block.classes:filter(function(class)
    return class ~= "fold"
  end)

  local open = fold == "show" and " open" or ""
  return pandoc.Div({
    pandoc.RawBlock(
      "html",
      "<details class=\"code-fold\"" .. open .. "><summary>" .. summary .. "</summary>"
    ),
    block,
    pandoc.RawBlock("html", "</details>")
  }, pandoc.Attr("", { "code-fold-wrap" }))
end
