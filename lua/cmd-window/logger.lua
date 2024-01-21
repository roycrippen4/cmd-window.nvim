local function remove_duplicate_whitespace(str)
  return str:gsub('%s+', ' ')
end

local function is_white_space(str)
  return str:gsub('%s', '') == ''
end

local function split(str, sep)
  if sep == nil then
    sep = '%s'
  end
  local t = {}
  for s in string.gmatch(str, '([^' .. sep .. ']+)') do
    table.insert(t, s)
  end
  return t
end

local function trim(str)
  return str:gsub('^%s+', ''):gsub('%s+$', '')
end

---@class Logger
---@field lines string[]
---@field max_lines number
---@field enabled boolean not used yet, but if we get reports of slow, we will use this
local Logger = {}

Logger.__index = Logger

---@return Logger
function Logger:new()
  local logger = setmetatable({
    lines = {},
    enabled = true,
    max_lines = 50,
    liveupdate = true,
    bufnr = nil, -- Add buffer number for log window
    winnr = nil, -- Add window ID for log window
  }, self)

  return logger
end

function Logger:disable()
  self.enabled = false
end

function Logger:enable()
  self.enabled = true
end

---@vararg any
function Logger:log(...)
  local processed = {}
  for i = 1, select('#', ...) do
    local item = select(i, ...)
    if type(item) == 'table' then
      item = vim.inspect(item)
    end
    table.insert(processed, item)
  end

  local lines = {}
  for _, line in ipairs(processed) do
    local _split = split(line, '\n')
    for _, l in ipairs(_split) do
      if not is_white_space(l) then
        local ll = trim(remove_duplicate_whitespace(l))
        table.insert(lines, ll)
      end
    end
  end

  table.insert(self.lines, table.concat(lines, ' '))

  while #self.lines > self.max_lines do
    table.remove(self.lines, 1)
  end

  if self.enabled and self.bufnr and vim.api.nvim_buf_is_loaded(self.bufnr) then
    vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, self.lines)
  end
end

function Logger:clear()
  self.lines = {}
end

function Logger:show()
  if not self.bufnr or not vim.api.nvim_buf_is_loaded(self.bufnr) then
    if os.getenv('DEBUG') == '1' then
      vim.schedule(function()
        vim.cmd([[
          vsplit
        ]])
        vim.cmd([[
        NvimTreeToggle
        NvimTreeToggle
        wincmd l
        vsplit
        vertical resize 80
        wincmd h
    ]])
        -- require('harpoon'):list('relative'):select(1)
        require('harpoon.ui').nav_file(1)
      end)
    end

    self.winnr = vim.api.nvim_get_current_win()
    self.bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(self.bufnr, 'logger')
    vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, self.lines)
    vim.api.nvim_win_set_buf(self.winnr, self.bufnr)
    vim.bo[self.bufnr].ft = 'logger'
  end
end

_G.log = function(msg)
  if type(msg) ~= 'string' then
    msg = vim.inspect(msg)
  end
  require('plugins.local_plugs.logger'):log(msg)
end

vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    if os.getenv('DEBUG') == '1' then
      vim.cmd('Log')
      log('Debug enabled')
      log('')
    end
  end,
})

vim.api.nvim_create_user_command('Log', function()
  local logger = require('plugins.local_plugs.logger')
  logger:show()
end, {})

return Logger:new()
