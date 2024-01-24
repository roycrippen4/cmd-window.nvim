local logger = require('cmd-window.logger')
local data = require('cmd-window.data')
local utils = require('cmd-window.utils')
local map = vim.keymap.set
local map_opts = { buffer = 0, silent = true }
local get_lines = vim.api.nvim_buf_get_lines
local feedkeys = vim.fn.feedkeys

---@class UI
local ui = {}

ui.__index = ui

---@param win_opts WinOpts
function ui:new(win_opts)
  return setmetatable({
    win_id = nil,
    bufnr = nil,
    kind = nil,
    win_opts = win_opts,
  }, self)
end

local function create_highlights()
  vim.api.nvim_set_hl(0, 'CmdWindowBorder', { fg = '#FF00FF' })
  vim.api.nvim_set_hl(0, 'CmdWindowTitle', { fg = '#000000', bg = '#FF00FF' })
end

function ui:__apply_settings()
  if not string.find(self.kind, 'normal') then
    vim.wo[self.win_id].number = true
  else
    vim.cmd('set nonumber')
  end
  vim.bo[self.bufnr].filetype = 'vim'
  vim.api.nvim_win_set_cursor(self.win_id, { vim.fn.line('$'), 0 })
  vim.cmd('normal A')
  vim.cmd('startinsert')

  create_highlights()
end

function ui:__set_keymaps()
  map('n', 'q', function()
    ui:close()
  end, map_opts)

  map({ 'n', 'i' }, '<Esc>', function()
    ui:close()
  end, map_opts)

  map({ 'n', 'i' }, '<CR>', function()
    ui:select(self.kind)
  end, map_opts)
end

---@param icon string The icon to show
---@param icon_hl_group string The highlight
local function set_virt_text(icon, icon_hl_group) end

---@return string title
---@return string[] contents
function ui:_get_content()
  local title = ''
  local contents = { '' }

  if self.kind ~= 'normal_cmd' and self.kind ~= 'normal_search' then
    contents = data.display_history_data(self.kind)
    title = self.kind .. ' history'
  else
    if self.kind == 'normal_search' then
      vim.api.nvim_exec_autocmds(
        'CmdlineEnter',
        { group = 'CmdWindow', pattern = 'CmdWindow', data = 'search' }
      )
    end
    title = ''
  end
  return title, contents
end

---@param win_opts WinOpts
---@param kind WinType
function ui:__create_window(win_opts, kind)
  self.kind = kind
  local title, contents = ui:_get_content()

  local win_id = require('plenary.popup').create(contents, {
    relative = win_opts.relative,
    title = title,
    title_pos = win_opts.title_pos,
    focusable = true,
    row = math.floor(((vim.o.lines - win_opts.height) / 2) - 1),
    col = math.floor((vim.o.columns - win_opts.width) / 2),
    width = win_opts.width,
    height = win_opts.height,
    maxwidth = win_opts.width,
    maxheight = win_opts.height,
    style = 'minimal',
    borderchars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
    borderhighlight = 'CmdWindowBorder',
    titlehighlight = 'CmdWindowTitle',
  })
  local bufnr = vim.api.nvim_get_current_buf()
  self.win_id = win_id
  self.bufnr = bufnr

  ui:__set_keymaps()
  ui:__apply_settings()
end

function ui:close()
  self.closing = true
  if self.bufnr ~= nil and vim.api.nvim_buf_is_valid(self.bufnr) then
    vim.api.nvim_buf_delete(self.bufnr, { force = true })
  end

  if self.win_id ~= nil and vim.api.nvim_win_is_valid(self.win_id) then
    vim.api.nvim_win_close(self.win_id, true)
  end

  self.win_id = nil
  self.bufnr = nil
  vim.cmd('stopinsert')
end

--- Executes the line the cursor is on.
--- @param kind WinType
function ui:select(kind)
  local line = vim.fn.line('.')
  ---@diagnostic disable-next-line
  local command = get_lines(ui.bufnr, line - 1, line, false)[1]

  ui:close()

  if kind == 'search' or kind == 'normal_search' then
    command = 'let @/=' .. '"' .. command .. '"'
    utils.pcall(vim.cmd, command)

    feedkeys('n', 'n')
    return
  end

  utils.pcall(vim.cmd, command)
end

return ui
