local function treesitter_highlight(input)
  local parser = vim.treesitter.get_string_parser(input, 'python')
  local tree = parser:parse()[1]
  local query = vim.treesitter.query.get('python', 'highlights')
  local highlights = {}
  for id, node, _ in query:iter_captures(tree:root(), input) do
    local _, cstart, _, cend = node:range()
    table.insert(highlights, { cstart, cend, '@' .. query.captures[id] })
  end
  return highlights
end
local function test_input()
  vim.ui.input({ prompt = 'Enter the thing: ', highlight = treesitter_highlight }, function(_) end)
end
