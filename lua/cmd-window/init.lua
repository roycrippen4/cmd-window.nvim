local ui = require('cmd-window.ui')
local logger = require('cmd-window.logger')
local Config = require('cmd-window.config')
local autocmds = require('cmd-window.autocmds')

local M = {}

---@param opts? PartialConfig
function M.setup(opts)
  M.config = Config.merge_config(opts)
  autocmds.start_autocmds(M.config.win_opts)

  if M.config.opts.debug then
    logger:show()
  end
end

---@param history_type HistoryType
function M.open(history_type)
  ui._open(M.config.win_opts, history_type)
  logger:log(history_type, ' window opened')
end

return M
