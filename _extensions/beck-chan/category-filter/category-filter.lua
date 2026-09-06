--[[
  Embeds Quarto's margin category filters as an inline dropdown.

  Usage:
    ::: {.category-filter}
    :::

  On mobile, the dropdown mirrors #quarto-margin-sidebar categories and
  drives window.quartoListingCategory. On desktop the embed is hidden
  (.hidden-desktop) so the margin sidebar remains the filter UI.
]]

local deps_injected = false

local function is_html()
  return quarto.doc.is_format("html:js") or quarto.doc.is_format("html")
end

local function ensure_deps()
  if deps_injected then
    return
  end
  quarto.doc.add_html_dependency({
    name = "category-filter",
    version = "1.0.0",
    stylesheets = { "category-filter.css" },
    scripts = { "category-filter.js" }
  })
  deps_injected = true
end

function Div(div)
  if not div.classes:includes("category-filter") then
    return nil
  end
  if not is_html() then
    return nil
  end

  ensure_deps()

  local extra = {}
  for _, class in ipairs(div.classes) do
    if class ~= "category-filter" then
      table.insert(extra, class)
    end
  end

  local classes = { "category-filter", "hidden-desktop" }
  for _, class in ipairs(extra) do
    table.insert(classes, class)
  end

  local id_attr = ""
  if div.identifier ~= "" then
    id_attr = ' id="' .. div.identifier:gsub('"', "&quot;") .. '"'
  end

  local html = table.concat({
    '<div' .. id_attr .. ' class="' .. table.concat(classes, " ") .. '">',
    '  <label class="category-filter__label" for="category-filter-select">',
    '    <span class="category-filter__label-text">filter by category</span>',
    "  </label>",
    '  <select id="category-filter-select" class="category-filter__select"',
    '    aria-label="Filter by category">',
    '    <option value="">All</option>',
    "  </select>",
    "</div>"
  }, "\n")

  return pandoc.RawBlock("html", html)
end
