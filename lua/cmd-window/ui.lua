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

---@class UI
local ui = {}

---@param win_opts WinOpts
function ui._create_window(win_opts)
  local contents = history.get_history()
  local win_id = require('plenary.popup').create(contents, {
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
  })

  ui.win_id = win_id
  ui.bufnr = vim.api.nvim_get_current_buf()

  vim.api.nvim_win_set_cursor(ui.win_id, { vim.fn.line('$'), 0 })
  vim.api.nvim_set_option_value('number', true, {
    win = win_id,
  })

  vim.keymap.set('n', 'q', function()
    ui.close()
  end, { buffer = 0, silent = true })

  vim.keymap.set('n', '<Esc>', function()
    ui.close()
  end, { buffer = 0, silent = true })

  vim.keymap.set('n', '<CR>', function()
    ui.select()
  end, { buffer = 0, silent = true })
end

function ui.close()
  if ui.bufnr ~= nil and vim.api.nvim_buf_is_valid(ui.bufnr) then
    vim.api.nvim_buf_delete(ui.bufnr, { force = true })
  end

  if ui.win_id ~= nil and vim.api.nvim_win_is_valid(ui.win_id) then
    vim.api.nvim_win_close(ui.win_id, true)
  end
end

---@param win_opts WinOpts
function ui.open(win_opts)
  ui._create_window(win_opts)
end

--- Executes the line the cursor is on.
function ui.select()
  local line = vim.fn.line('.')
  if not line then
    error('Unable to find the current line')
  end
  local command = vim.api.nvim_buf_get_lines(ui.bufnr, line - 1, line, false)
  ui.close()
  vim.cmd(command[1])
end

return ui
