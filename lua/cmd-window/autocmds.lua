local autocmd = vim.api.nvim_create_autocmd
local group = vim.api.nvim_create_augroup('CmdWindow', { clear = true })
local UI = require('cmd-window.ui')
local Search = require('cmd-window.hlsearch')
local Utils = require('cmd-window.utils')
local logger = require('cmd-window.logger')

M = {}

--- The default cmdline window has some quirks.
--- Neovim will wait after you press `q` until another key is pressed.
--- If you press `:` after, no matter how long you have waited, the default cmdline-win will open.
--- We listen for the CmdwinEnter event and close the default upon it firing.
--- We also open our window.
---@param display_opts Display
function M.start_autocmds(display_opts)
  autocmd('CmdwinEnter', {
    group = group,
    callback = function(args)
      vim.cmd('q')
      vim.schedule(function()
        if args.file == '?' or args.file == '/' then
          UI:__create_window(display_opts.history.search, 'search', true)
        else
          UI:__create_window(display_opts.history.cmd, 'cmd', true)
        end
      end)
    end,
  })

  autocmd('BufLeave', {
    group = group,
    callback = function()
      if Search.searching then
        Search.clear()
      end
    end,
  })

  autocmd({ 'TextChangedI', 'CursorMoved' }, {
    group = group,
    callback = function()
      if vim.bo.ft == 'CmdWindow' then
        local win_id = vim.api.nvim_get_current_win()
        local current_line = vim.fn.line('.', win_id)

        if current_line and UI.type == 'search' then
          -- local search = 'let @/=' .. '"' .. vim.fn.getline(current_line) .. '"'
          logger:log(current_line)
          -- Utils.pcall(vim.cmd, search)
        end
      end
    end,
  })
end
return M
