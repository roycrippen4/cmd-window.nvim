local logger = require('cmd-window.logger')
local history = require('cmd-window.history')

--- ┌──────────────────────────────────────┐
--- │                Title                 │
--- │┌────────────────────────────────────┐│
--- ││                                    ││
--- ││                                    ││
--- ││               Results              ││
--- ││                                    ││
--- ││                                    ││
--- │└────────────────────────────────────┘│
--- └──────────────────────────────────────┘
-- borderchars =  { '─', '│', '─', '│', '╭', '╮', '╯', '╰' }
-- borderchars = { '', '', '', '', '', '', '', '' },

---@class UI
local ui = {}

---@param win_id integer
local set_cursor = function(win_id)
  vim.api.nvim_win_set_cursor(win_id, { vim.fn.line('$'), 0 })
end

local get_current_buf = vim.api.nvim_get_current_buf

---@param win_id integer
---@param bufnr integer
local function apply_settings(win_id, bufnr)
  vim.wo[win_id].number = true
  vim.bo[bufnr].filetype = 'vim'
  vim.cmd('normal A')
  vim.cmd('startinsert')
end

local function create_highlights()
  vim.api.nvim_set_hl(0, 'CmdWindowBorder', { fg = '#FF00FF' })
  vim.api.nvim_set_hl(0, 'CmdWindowTitle', { fg = '#000000', bg = '#FF00FF' })
end

local function set_keymaps()
  vim.keymap.set('n', 'q', function()
    ui._close()
  end, { buffer = 0, silent = true })

  vim.keymap.set('n', '<Esc>', function()
    ui._close()
  end, { buffer = 0, silent = true })

  vim.keymap.set('n', '<CR>', function()
    ui._select()
  end, { buffer = 0, silent = true })
end

---@param win_opts WinOpts
---@param type HistoryType
function ui._create_window(win_opts, type)
  local contents = history.get_list(type)
  ui.win_id = require('plenary.popup').create(contents, {
    relative = win_opts.relative,
    title = win_opts.title,
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

  ui.bufnr = get_current_buf()
  set_keymaps()
  set_cursor(ui.win_id)
  apply_settings(ui.win_id, ui.bufnr) -- enables line numbering
  create_highlights()
end

function ui._close()
  if ui.bufnr ~= nil and vim.api.nvim_buf_is_valid(ui.bufnr) then
    vim.api.nvim_buf_delete(ui.bufnr, { force = true })
  end

  if ui.win_id ~= nil and vim.api.nvim_win_is_valid(ui.win_id) then
    vim.api.nvim_win_close(ui.win_id, true)
  end
end

---@param win_opts WinOpts
---@param type HistoryType
function ui._open(win_opts, type)
  ui._create_window(win_opts, type)
end

--- Executes the line the cursor is on.
function ui._select()
  local line = vim.fn.line('.')
  if not line then
    error('Unable to find the current line')
  end
  local command = vim.api.nvim_buf_get_lines(ui.bufnr, line - 1, line, false)
  ui._close()
  vim.cmd(command[1])
end

return ui
