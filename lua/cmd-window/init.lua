local UI = require('cmd-window.ui')
local logger = require('cmd-window.logger')
local Config = require('cmd-window.config')
local Data = require('cmd-window.data')
local Utils = require('cmd-window.utils')
local Search = require('cmd-window.hlsearch')
local start_autocmds = require('cmd-window.autocmds').start_autocmds

local M = {}

---@param opts? PartialConfig
function M.setup(opts)
  M.config = Config.merge_config(opts)
  start_autocmds(M.config.display)
  Data.setup()
  vim.defer_fn(function()
    logger:show()
  end, 100)
end

--- Replaces the built-in command line
function M.cmdline()
  UI:__create_window(M.config.display.cmdline, 'cmd', false)
end

--- Replaces the built-in command history window
function M.cmdline_window()
  UI:__create_window(M.config.display.history.cmd, 'cmd', true)
end

--- Replaces the built-in search
function M.search()
  Search.hl_search(Utils.get_win_info())
  UI:__create_window(M.config.display.search, 'search', false)
end

--- Replaces the built-in search history window
function M.search_window()
  Search.hl_search(Utils.get_win_info())
  UI:__create_window(M.config.display.history.search, 'search', true)
end

return M
