local logger = require('cmd-window.logger')

local data = {
  command = {},
  search = {},
}

---@param idx integer
---@param cmd string
---@param list string
local cache_item = function(idx, cmd, list)
  table.insert(data[list], { id = idx, cmd = cmd })
end

---@param entry string
---@return integer
---@return string
local parse_history = function(entry)
  local d1, d2 = string.find(entry, '%d+')
  ---@diagnostic disable-next-line
  local digit = string.sub(entry, d1, d2)
  local _, finish = string.find(entry, '%d+ +')
  return digit + 0, string.sub(entry, finish + 1)
end

-- Loads history
---@param cmd_type WindowType
local load_history = function(cmd_type)
  local data_string = assert(vim.fn.execute('history ' .. cmd_type), 'History is empty')
  local data_list = vim.split(data_string, '\n')

  for i = 3, #data_list do
    local idx, cmd = parse_history(data_list[i])
    cache_item(idx, cmd, cmd_type)
  end
end

---@param type WindowType
---@return string[]
function data.display_history_data(type)
  local items = {}

  if type == 'cmd' or type == 'search' then
    return { '' }
  end

  if #data[type] == 0 then
    load_history(type)
  end

  for i = 1, #data[type] do
    items[i] = data[type][i]['cmd']
  end

  items[#data[type] + 1] = ''
  return items
end

return data
