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
---@param win_opts WinOpts
function M.start_autocmds(win_opts)
  -- logger:log('autocmds started')
  autocmd('CmdwinEnter', {
    group = group,
    callback = function(args)
      -- Close the default command window
      vim.cmd(':q')

      -- args.file will tell us what the type should be.
      -- hard coded to command history for now, it's the only thing implemented

      -- Must delay a bit to avoid error.
      vim.schedule(function()
        logger:log(args)
        ui._open(win_opts, 'command')
      end)
    end,
  })
end

return M
