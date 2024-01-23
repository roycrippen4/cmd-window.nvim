local logger = require('cmd-window.logger')
local Path = require('plenary.path')
local data_path = vim.fn.stdpath('data')
local dir_path = string.format('%s/cmd-window', data_path)

---@class item
---@field cmd string
---@field id integer

---@class list
---@field path string|nil
---@field data item[]

---@class history
---@field command list
---@field search list
local history = {
  command = {
    path = nil,
    data = {},
  },
  search = {
    path = nil,
    data = {},
  },
}

--- Creates the local files if they do not exist.
--- Files are created at the top level of the vim stdpath
local function make_files()
  history.command.path = string.format('%s/cmd-window/command_history.txt', data_path)
  history.search.path = string.format('%s/cmd-window/search_history.txt', data_path)

  local cmd_path = Path:new(history.command.path)
  local search_path = Path:new(history.search.path)
  local dir_Path = Path:new(dir_path)

  if not dir_Path:exists() then
    dir_Path:mkdir(dir_path)
  end

  if not cmd_path:exists() then
    logger:log('create command file')
    cmd_path:touch(history.command.path)
  end

  if not search_path:exists() then
    logger:log('create search file')
    search_path:touch(history.search.path)
  end
end

make_files()

history.add_history = function(index, cmd)
  table.insert(history.command.data, { id = index + 0, cmd = cmd })
end

local parse_history = function(entry)
  local d1, d2 = string.find(entry, '%d+')
  ---@diagnostic disable-next-line
  local digit = string.sub(entry, d1, d2)
  local _, finish = string.find(entry, '%d+ +')
  return digit, string.sub(entry, finish + 1)
end

-- Loads full history when no text is provided and matches when text is provided
local get_command_history = function()
  local history_string = assert(vim.fn.execute('history cmd'), 'History is empty')
  local history_list = vim.split(history_string, '\n')

  for i = 3, #history_list do
    history.add_history(parse_history(history_list[i]))
  end
  return history.command.data
end

---@param list HistoryType
---@return string[]
function history.get_list(list)
  local cmds = {}

  if #history[list].data == 0 then
    get_command_history()
  end

  for i = 1, #history[list].data do
    cmds[i] = history[list].data[i]['cmd']
  end

  cmds[#history[list].data + 1] = ''
  return cmds
end

return history
