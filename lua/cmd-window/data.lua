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
---@param kind Kind
local load_history = function(kind)
  logger:log(kind)
  local exe = ''

  if kind == 'command' then
    exe = 'cmd'
  else
    exe = kind
  end

  local data_string = assert(vim.fn.execute('history ' .. exe), 'History is empty')
  local data_list = vim.split(data_string, '\n')

  for i = 3, #data_list do
    local idx, cmd = parse_history(data_list[i])
    cache_item(idx, cmd, kind)
  end
end

---@param kind Kind
---@return string[]
function data.display_history_data(kind)
  local items = {}

  if kind == 'normal_cmd' or kind == 'normal_search' then
    return { '' }
  end

  if #data[kind] == 0 then
    load_history(kind)
  end

  for i = 1, #data[kind] do
    items[i] = data[kind][i]['cmd']
  end

  items[#data[kind] + 1] = ''
  return items
end

return data
