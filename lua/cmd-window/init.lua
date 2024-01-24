local ui = require('cmd-window.ui')
local logger = require('cmd-window.logger')
local Config = require('cmd-window.config')
local start_autocmds = require('cmd-window.autocmds').start_autocmds

local M = {}

---@param opts? PartialConfig
function M.setup(opts)
  M.config = Config.merge_config(opts)
  start_autocmds(M.config.display)

  if M.config.debug then
    logger:show()
  end
end

--- Replaces the built-in command line
function M.cmdline()
  ui:__create_window(M.config.display.cmdline, 'cmd', false)
end

--- Replaces the built-in command history window
function M.cmdline_window()
  ui:__create_window(M.config.display.history.cmd, 'cmd', true)
end

--- Replaces the built-in search
function M.search()
  ui:__create_window(M.config.display.search, 'search', true)
end

--- Replaces the built-in search history window
function M.search_window()
  ui:__create_window(M.config.display.history.search, 'search', true)
end

return M
