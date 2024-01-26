local data = require('cmd-window.data')
local feedkeys = vim.fn.feedkeys
local get_lines = vim.api.nvim_buf_get_lines
local logger = require('cmd-window.logger')
local map = vim.keymap.set
local map_opts = { buffer = 0, silent = true }
local utils = require('cmd-window.utils')

---@class UI
---@field win_id integer Id for the UI window
---@field bufnr integer Buffer number for the buffer inside the window
---@field display DisplayOpts Window specific options
---@field history boolean Show history or not
---@field open boolean True if a UI window is open
---@field is_closing boolean True during the UI:close() function
---@field ns_id integer Hl group namespace used for virtual text in prompt
---@field ext_id integer Extmark id for virtual text in prompt
local UI = {}

UI.__index = UI

---@param icon string The virtual icon
---@param hl_group string Highlight group for the virtual text
function UI:__set_signs(icon, hl_group)
  local line = vim.fn.line('$', self.win_id)
  if not line then
    error('UI:__draw_virt() -> Could not find a valid line.')
  end

  self.ext_id = vim.api.nvim_buf_set_extmark(0, self.ns_id, line - 1, 0, {
    sign_text = icon,
    sign_hl_group = hl_group,
  })
end

local function set_highlights()
  vim.api.nvim_set_hl(0, 'CmdWindowBorder', { fg = '#2fffff' })
  vim.api.nvim_set_hl(
    0,
    'CmdWindowTitle',
    { fg = '#000000', bg = '#2fffff', bold = true, italic = true }
  )
  vim.api.nvim_set_hl(0, 'CmdWindowPrompt', { fg = '#897999' })
end

local function set_keymaps()
  map('n', 'q', function()
    UI:close()
  end, map_opts)

  map({ 'n', 'i' }, '<Esc>', function()
    UI:close()
  end, map_opts)

  map({ 'n', 'i' }, '<CR>', function()
    UI:select()
  end, map_opts)
end

---@param type WindowType
---@param bufnr integer
local function set_syntax(type, bufnr)
  if type == 'cmd' then
    vim.treesitter.start(bufnr, 'vim')
  else
    vim.treesitter.start(bufnr, 'regex')
  end
end

---@param show_history boolean
---@param win_id integer
---@param icon string
---@param icon_hl string
local function set_options(show_history, win_id, icon, icon_hl)
  if show_history then
    vim.wo[win_id].number = true
  else
    vim.cmd('set nonumber')
    vim.wo[win_id].signcolumn = 'yes:1'
    UI:__set_signs(icon, icon_hl)
  end
  vim.api.nvim_win_set_cursor(win_id, { vim.fn.line('$'), 0 })
  vim.cmd('startinsert')
end

---@param show_history boolean
---@param win_id integer
---@param bufnr integer
---@param type WindowType
---@param icon string
---@param icon_hl string
local function apply_settings(show_history, win_id, bufnr, type, icon, icon_hl)
  set_options(show_history, win_id, icon, icon_hl)
  set_highlights()
  set_keymaps()
  set_syntax(type, bufnr)
end

---@param opts DisplayOpts
---@param type WindowType
---@param show_history boolean
function UI:__create_window(opts, type, show_history)
  self.show_history = show_history
  self.type = type
  local content = data.display_history_data(type)

  local win_id = require('plenary.popup').create(content, {
    relative = 'editor',
    title = opts.title.text,
    title_pos = opts.title.pos,
    titlehighlight = opts.title.hl,
    line = opts.row,
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

  self.open = true
  self.win_id = win_id
  self.bufnr = vim.api.nvim_get_current_buf()
  self.ns_id = vim.api.nvim_create_namespace('CmdWindow')
  apply_settings(show_history, win_id, self.bufnr, type, opts.prompt.icon, opts.prompt.hl)
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
