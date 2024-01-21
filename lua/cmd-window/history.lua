-- local logger = require('cmd-window.logger')

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

  for i = 3, #history_list do
    local item = history_list[i]

    if text == nil or text == '' then
      M.add_history(M.parse_history(item))
    elseif string.find(item, text) then
      M.add_history(M.parse_history(item))
    end
  end
  return cache.history
end

---@return string[]
function M.get_history()
  local cmds = {}

  if #cache.history == 0 then
    M.command_history()
  end

  for i = 1, #cache.history do
    cmds[i] = cache.history[i]['cmd']
  end

  cmds[#cache.history + 1] = ''
  return cmds
end

return M
