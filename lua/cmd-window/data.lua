local logger = require('cmd-window.logger')
local Path = require('plenary.path')
local data_path = vim.fn.stdpath('data')

---@class Data
local Data = {
  cmd = {
    path = string.format('%s/cmd-window/cmd_history', data_path),
    items = {},
  },
  search = {
    path = string.format('%s/cmd-window/search_history', data_path),
    items = {},
  },
  files_exist = false,
  dir_exists = false,
}

local dir_path = Path:new(string.format('%s/cmd-window', data_path))
local cmd_path = Path:new(Data.cmd.path)
local search_path = Path:new(Data.search.path)

--- Checks if the data files exist
--- Does nothing if they exist
--- Creates them if they do not exist
function Data.make_files()
  if Data.dir_exists and Data.files_exist then
    return
  end

  if not dir_path:exists() then
    dir_path:mkdir(dir_path)
  end

  if not cmd_path:exists() then
    cmd_path:touch(Data.cmd.path)
  end

  if not search_path:exists() then
    search_path:touch(Data.search.path)
  end

  Data.dir_exists = true
  Data.files_exist = true
end

---@param cmd string
---@param type ListType
function Data.list_add(cmd, type)
  local length = #Data[type].items

  if cmd == '' or cmd == Data[type].items[length - 1] then
    return
  end

  if #Data[type].items == 0 then
    table.insert(Data[type].items, '')
    table.insert(Data[type].items, 1, cmd)
    return
  end

  table.insert(Data[type].items, length, cmd)
end

---@param data string[]
---@param type ListType
local function cache(data, type)
  for i = 1, #data, 1 do
    Data.list_add(data[i], type)
  end
end

--- Erases all data from the local cache.
--- Does not touch files.
---
---@param type ListType
local function empty_cache(type)
  Data[type].items = {}
end

--- Loads the data read from the files into the cache
function Data.load()
  local search_data = search_path:readlines()
  local cmd_data = cmd_path:readlines()
  cache(search_data, 'search')
  cache(cmd_data, 'cmd')
end

function Data:__dump_data()
  logger:log('cmd list: ', Data.cmd)
  logger:log('search list: ', Data.search)
  logger:log('files_exist: ', Data.files_exist)
  logger:log('dir_exists: ', Data.dir_exists)
end

--- Clears the cache and fills it with the content from the buffer when it closes.
--- Might add an option later to prioritize the memory cache or the buffer in the future.
--- My preference is to keep the cache syncd with the buffer instead of the other way around.
--- This will let me delete stuff from the buffer and then the cache will reflect those changes.
---@param bufnr integer
---@param type ListType
function Data:sync(bufnr, type)
  local last_line = vim.fn.line('$')
  --- Throw an error if we cant get the last line of the buffer
  if not last_line then
    error('Data:sync() -> Could not get last line.')
    return
  end
  --- get the lines from the buffer
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, last_line, true)

  --- Do nothing if the buffer and cache are the same
  if lines == Data[type].items then
    return
  else
    --- clear the cache if they aren't
    empty_cache(type)
  end

  Data[type].items = lines
end

function Data.setup()
  Data.make_files()
  Data.load()
end

return Data
