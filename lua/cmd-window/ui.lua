local logger = require('cmd-window.logger')
local history = require('cmd-window.history')
logger:log('UI -> UI required')

---@class UI
local ui = {}
---@class UICache
ui.cache = {}

---@param win_opts WinOpts
function ui._create_window(win_opts)
  logger:log('UI -> ui._create_window called')
  logger:log('UI -> Window options: ', win_opts)
  local bufnr = vim.api.nvim_create_buf(false, true)
  local win_id = vim.api.nvim_open_win(bufnr, true, {
    relative = win_opts.relative,
    title = win_opts.title or 'Command History',
    title_pos = win_opts.title_pos or 'center',
    row = math.floor(((vim.o.lines - win_opts.height) / 2) - 1),
    col = math.floor((vim.o.columns - win_opts.width) / 2),
    width = win_opts.width,
    height = win_opts.height,
    style = 'minimal',
    border = win_opts.border or 'single',
  })

  -- Buffer.setup_autocmds_and_keymaps(bufnr)

  ui.win_id = win_id
  vim.api.nvim_set_option_value('number', true, {
    win = win_id,
  })

  logger:log('UI -> Caching win_id and bufnr')
  ui._cache(bufnr, win_id)

  vim.keymap.set('n', 'q', function()
    ui.close()
  end, { buffer = bufnr, silent = true })

  vim.keymap.set('n', '<Esc>', function()
    ui.close()
  end, { buffer = bufnr, silent = true })

  vim.keymap.set('n', '<CR>', function()
    ui.select()
  end, { buffer = bufnr, silent = true })
end

function ui.close()
  local bufnr = ui.cache.bufnr
  local win_id = ui.cache.win_id

  if bufnr ~= nil and vim.api.nvim_buf_is_valid(bufnr) then
    vim.api.nvim_buf_delete(bufnr, { force = true })
    logger:log('UI -> Deleting buffer')
  end

  if win_id ~= nil and vim.api.nvim_win_is_valid(win_id) then
    vim.api.nvim_win_close(win_id, true)
    logger:log('UI -> Closing window')
  end
end

---@param win_opts WinOpts
function ui.open(win_opts)
  logger:log('UI -> ui.open() called')
  ui._create_window(win_opts)
  ui._set_contents()
end

---@param win_id integer
---@param bufnr integer
function ui._cache(bufnr, win_id)
  logger:log('UI -> ui._cache() called')

  ui.cache.bufnr = bufnr
  ui.cache.win_id = win_id
  logger:log('UI -> ui.cache: ', ui.cache)
end

--- Sets the contents of the floating window and scrolls the cursor to the bottom
function ui._set_contents()
  vim.api.nvim_buf_set_lines(ui.cache.bufnr, 0, -1, false, history.get_history())
  vim.api.nvim_win_set_cursor(ui.cache.win_id, { vim.fn.line('$'), 0 })
end

--- Executes the line the cursor is on.
function ui.select()
  local line = vim.fn.line('.')
  if not line then
    error('Unable to find the current line')
  end
  local command = vim.api.nvim_buf_get_lines(ui.cache.bufnr, line - 1, line, false)
  vim.cmd(command[1])
end

return ui
