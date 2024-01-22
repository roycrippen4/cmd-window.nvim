-- local ui = require('cmd-window.ui')
local ui = require('cmd-window.ui')
local logger = require('cmd-window.logger')
local Config = require('cmd-window.config')

local M = {}

---@param opts? PartialConfig
function M.setup(opts)
  M.config = Config.merge_config(opts)
  logger:log(M.config)
  logger:show()
end

function M.open()
  ui.open(M.config.win_opts)
end

return M
