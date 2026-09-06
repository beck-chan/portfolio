--[[
  Collapses static fenced code blocks marked with fold=true into a
  <details> toggle. Quarto's built-in code-fold only covers cell-code
  from executable chunks, so this fills the gap for {.yaml}, {.bash}, etc.

  Usage:
    ```{.yaml fold=true}
    key: value
    ```

    ```{.yaml fold=false summary="Show config"}
    key: value
    ```

  Attributes:
    fold      true → collapsed; false → expanded
    summary   summary label (default: "Show Code")

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
  if fold == "true" then
    return "true"
  elseif fold == "false" then
    return "false"
  end
  return nil
end

function CodeBlock(block)
  if not is_html() then
    return nil
  end

  local fold = normalize_fold(block.attributes["fold"])
  if fold == nil and block.classes:includes("fold") then
    fold = "true"
  end
  if fold == nil then
    return nil
  end

  local summary = block.attributes["summary"] or "show code"
  summary = escape_html(pandoc.utils.stringify(summary))

  block.attributes["fold"] = nil
  block.attributes["summary"] = nil
  block.classes = block.classes:filter(function(class)
    return class ~= "fold"
  end)

  local open = fold == "false" and " open" or ""
  return pandoc.Div({
    pandoc.RawBlock(
      "html",
      "<details class=\"code-fold\"" .. open .. "><summary>" .. summary .. "</summary>"
    ),
    block,
    pandoc.RawBlock("html", "</details>")
  }, pandoc.Attr("", { "code-fold-wrap" }))
end
