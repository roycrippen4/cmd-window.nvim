local logger = require('cmd-window.logger')

local data = {
  cmd = {},
  search = {},
}

---@param idx integer
---@param cmd string
---@param list string
data.cache_item = function(idx, cmd, list)
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
---@param type WindowType
data.cache_history = function(type)
  local data_string = assert(vim.fn.execute('history ' .. type), 'History is empty')
  local data_list = vim.split(data_string, '\n')

  for i = 3, #data_list do
    local idx, cmd = parse_history(data_list[i])
    data.cache_item(idx, cmd, type)
  end
end

---@param type WindowType
---@return string[]
function data.display_history_data(type)
  local items = {}

  if #data[type] == 0 then
    data.cache_history(type)
  end

  for i = 1, #data[type] do
    items[i] = data[type][i]['cmd']
  end

  items[#data[type] + 1] = ''
  return items
end

return data
