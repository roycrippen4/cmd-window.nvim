local logger = require('cmd-window.logger')
local data = require('cmd-window.data')
local utils = require('cmd-window.utils')
local map = vim.keymap.set
local map_opts = { buffer = 0, silent = true }
local get_lines = vim.api.nvim_buf_get_lines
local feedkeys = vim.fn.feedkeys

---@class UI
---@field win_id integer
---@field bufnr integer
---@field display DisplayOpts
---@field history boolean
---@field open boolean
---@field is_closing boolean
local UI = {}

UI.__index = UI

---@param opts Display
---@param type WindowType
---@param show_history boolean
local function get_specific_opts(opts, type, show_history)
  if show_history then
    return opts.history[type]
  end

  if type == 'cmd' then
    return opts.cmdline
  end

  return opts.search
end

---@param opts Display
---@param type WindowType
---@param show_history boolean
function UI:new(opts, type, show_history)
  local display_opts = get_specific_opts(opts, type, show_history)
  return setmetatable({
    win_id = nil,
    bufnr = nil,
    type = type,
    display = display_opts,
    history = show_history,
  }, self)
end

local function create_highlights()
  vim.api.nvim_set_hl(0, 'CmdWindowBorder', { fg = '#2fffff' })
  vim.api.nvim_set_hl(
    0,
    'CmdWindowTitle',
    { fg = '#000000', bg = '#2fffff', bold = true, italic = true }
  )
end

function UI:__apply_settings()
  if self.history then
    vim.wo[self.win_id].number = true
  else
    vim.cmd('set nonumber')
  end

  -- vim.bo[self.bufnr].filetype = 'vim'
  vim.api.nvim_win_set_cursor(self.win_id, { vim.fn.line('$'), 0 })
  vim.cmd('startinsert')

  create_highlights()
end

function UI:__set_keymaps()
  map('n', 'q', function()
    self:close()
  end, map_opts)

  map({ 'n', 'i' }, '<Esc>', function()
    self:close()
  end, map_opts)

  map({ 'n', 'i' }, '<CR>', function()
    self:select()
  end, map_opts)
end

-- ---@param icon string The icon to show
-- ---@param icon_hl_group string The highlight
-- local function set_virt_text(icon, icon_hl_group) end

---@param opts DisplayOpts
---@param type WindowType
---@param show_history? boolean
function UI:__create_window(opts, type, show_history)
  self.show_history = show_history
  self.type = type
  local content = data.display_history_data(self.type)

  local win_id = require('plenary.popup').create(content, {
    relative = 'editor',
    title = opts.title.text,
    title_pos = opts.title.pos,
    titlehighlight = opts.title.hl,
    row = opts.row,
    col = opts.col,
    width = opts.width,
    height = opts.height,
    maxwidth = opts.width,
    maxheight = opts.height,
    style = 'minimal',
    focusable = true,
    borderchars = utils.convert_border(opts.border.style),
    borderhighlight = opts.border.hl,
  })

  self.win_id = win_id
  self.bufnr = vim.api.nvim_get_current_buf()
  self:__set_keymaps()
  self:__apply_settings()
end

function UI:close()
  if self.is_closing then
    return
  end

  self.is_closing = true
  if self.bufnr ~= nil and vim.api.nvim_buf_is_valid(self.bufnr) then
    vim.api.nvim_buf_delete(self.bufnr, { force = true })
  end

  if self.win_id ~= nil and vim.api.nvim_win_is_valid(self.win_id) then
    vim.api.nvim_win_close(self.win_id, true)
  end

  self.win_id = nil
  self.bufnr = nil
  self.is_closing = false
  vim.cmd('stopinsert')
end

--- Executes the line the cursor is on.
function UI:select()
  local line = vim.fn.line('.')
  ---@diagnostic disable-next-line
  local command = get_lines(self.bufnr, line - 1, line, false)[1]

  self:close()

  if self.type == 'search' then
    command = 'let @/=' .. '"' .. command .. '"'
    utils.pcall(vim.cmd, command)

    feedkeys('n', 'n')
    return
  end

  utils.pcall(vim.cmd, command)
end

return UI
