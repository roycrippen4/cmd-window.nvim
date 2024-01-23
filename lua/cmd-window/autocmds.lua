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
  autocmd('CmdwinEnter', {
    group = group,
    callback = function(args)
      local buf = vim.api.nvim_get_current_buf()
      if vim.bo[buf].buftype == 'nofile' then
        vim.cmd(':q')
        vim.schedule(function()
          if args.file == '?' or args.file == '/' then
            ui._create_window(win_opts, 'search')
          else
            ui._create_window(win_opts, 'command')
          end
        end)
      end
    end,
  })

  autocmd('CmdlineEnter', {
    group = group,
    pattern = 'CmdWindow',
    callback = function(args)
      logger:log(args)
    end,
  })
  -- autocmd('CmdwinLeave', {
  --   group = group,
  --   pattern = 'CmdWindow',
  --   callback = function(args)
  --     logger:log(args)
  --   end,
  -- })
  autocmd('TextChangedP', {
    group = group,
    -- pattern = 'CmdWindow',
    callback = function(args)
      logger:log(args)
    end,
  })
end

return M
