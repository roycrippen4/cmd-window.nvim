local autocmd = vim.api.nvim_create_autocmd
local group = vim.api.nvim_create_augroup('CmdWindow', { clear = true })
local ui = require('cmd-window.ui')
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
          ui:__create_window(display_opts.history.search, 'search', true)
        else
          ui:__create_window(display_opts.history.cmd, 'cmd', true)
        end
      end)
    end,
  })
end

return M
