local cache = {}
cache.history = {}

local M = {}

M.add_history = function(index, cmd)
  table.insert(cache.history, { id = index + 0, cmd = cmd })
end

M.parse_history = function(entry)
  local d1, d2 = string.find(entry, '%d+')
  ---@diagnostic disable-next-line
  local digit = string.sub(entry, d1, d2)
  local _, finish = string.find(entry, '%d+ +')
  return digit, string.sub(entry, finish + 1)
end

-- Loads full history when no text is provided and matches when text is provided
M.command_history = function(text)
  local history_string = assert(vim.fn.execute('history cmd'), 'History is empty')
  local history_list = vim.split(history_string, '\n')

  cache.history = {}

  for i = #history_list, 3, -1 do
    local item = history_list[i]

    if text == nil or text == '' then
      M.add_history(M.parse_history(item))
    elseif string.find(item, text) then
      M.add_history(M.parse_history(item))
    end
  end
  return cache.history
end

M.get_most_recent = function()
  local recent_history = {}

  -- Populate the chache if empty
  if #cache.history == 0 then
    M.command_history()
  end

  for i = 1, 10 do
    recent_history[i] = cache.history[i]
  end

  return recent_history
end

function M.cache_history()
  if #cache.history == 0 then
    M.command_history()
  end
end

return M
