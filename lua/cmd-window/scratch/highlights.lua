local function treesitter_highlight(input)
  local parser = vim.treesitter.get_string_parser(input, 'vim')
  local tree = parser:parse()[1]
  local query = vim.treesitter.query.get('vim', 'highlights')
  local highlights = {}

  local start = vim.fn.line('w0')
  local _end = vim.fn.line('$')

  if not query or not start or not _end then
    return
  end
  for id, node, _ in query:iter_captures(tree:root(), input, start, _end) do
    local _, cstart, _, cend = node:range()
    table.insert(highlights, { cstart, cend, '@' .. query.captures[id] })
  end
  return highlights
end
