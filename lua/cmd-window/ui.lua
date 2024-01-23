local logger = require('cmd-window.logger')
local data = require('cmd-window.data')
local map = vim.keymap.set
local map_opts = { buffer = 0, silent = true }
local get_lines = vim.api.nvim_buf_get_lines
local feedkeys = vim.fn.feedkeys

---@class UI
local ui = {}

---@param win_id integer
---@param bufnr integer
---@param kind Kind
local function apply_settings(win_id, bufnr, kind)
  if not string.find(kind, 'normal') then
    vim.wo[win_id].number = true
  else
    vim.cmd('set nonumber')
  end
  vim.bo[bufnr].filetype = 'vim'
  vim.api.nvim_win_set_cursor(ui.win_id, { vim.fn.line('$'), 0 })
  vim.cmd('normal A')
  vim.cmd('startinsert')
end

local function create_highlights()
  vim.api.nvim_set_hl(0, 'CmdWindowBorder', { fg = '#FF00FF' })
  vim.api.nvim_set_hl(0, 'CmdWindowTitle', { fg = '#000000', bg = '#FF00FF' })
end

---@param win_opts WinOpts
---@param kind Kind
function ui._create_window(win_opts, kind)
  local title = ''
  local contents = { '' }

  if kind ~= 'normal_cmd' and kind ~= 'normal_search' then
    contents = data.display_history_data(kind)
    title = kind .. ' history'
  else
    if kind == 'normal_search' then
      vim.api.nvim_exec_autocmds(
        'CmdlineEnter',
        { group = 'CmdWindow', pattern = 'CmdWindow', data = 'search' }
      )
    end
    title = ''
  end

  ui.win_id = require('plenary.popup').create(contents, {
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
  ui.is_open = true

  map('n', 'q', function()
    ui._close()
  end, map_opts)

  map({ 'n', 'i' }, '<Esc>', function()
    ui._close()
  end, map_opts)

  map({ 'n', 'i' }, '<CR>', function()
    ui._select(kind)
  end, map_opts)

  ui.bufnr = vim.api.nvim_get_current_buf()
  apply_settings(ui.win_id, ui.bufnr, kind)
  create_highlights()
  vim.api.nvim_exec_autocmds('CmdlineEnter', { pattern = 'CmdWindow', data = 'entering' })
end

function ui._close()
  if ui.bufnr ~= nil and vim.api.nvim_buf_is_valid(ui.bufnr) then
    vim.api.nvim_buf_delete(ui.bufnr, { force = true })
  end

  if ui.win_id ~= nil and vim.api.nvim_win_is_valid(ui.win_id) then
    vim.api.nvim_win_close(ui.win_id, true)
  end

  vim.cmd('stopinsert')
end

--- Executes the line the cursor is on.
--- @param kind Kind
function ui._select(kind)
  local line = vim.fn.line('.')
  ---@diagnostic disable-next-line
  local command = get_lines(ui.bufnr, line - 1, line, false)[1]

  ui._close()

  logger:log(command)
  if kind == 'search' or kind == 'normal_search' then
    vim.cmd('let @/=' .. '"' .. command .. '"')
    feedkeys('n', 'n')
    return
  end

  vim.cmd(command)
end

return ui
