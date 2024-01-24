---@alias title_pos "left"|"center"|"right".
---@alias border "none"|"single"|"double"|"rounded"|"solid"|"shadow"
---@alias relative "editor"|"win"|"cursor"|"mouse"
---@alias DataType 'command'|'search'
---@alias WinType 'command'|'search'|'normal_cmd'|'normal_search'

---@class WinOpts
---@field title_pos? title_pos Title position value passed to nvim_open_win
---@field relative? relative Where to open the window. Passed into nvim_open_win
---@field border? border Border value passed to nvim_open_win
---@field width? integer Width value passed to nvim_open_win
---@field height? integer Height value passed to nvim_open_win

---@class UI
---@field win_id integer
---@field bufnr integer
---@field win_opts WinOpts
---@field kind WinType

---@class PartialConfig
---@field win_opts? WinOpts
---@field opts? table|nil

---@class Opts
---@field debug? boolean

---@class CmdWindowOptions
---@field win_opts WinOpts
---@field opts Opts

---@class DataItem
---@field cmd string
---@field id integer

---@class item
---@field id integer
---@field cmd string

---@class Data
---@field command item[]
---@field search item[]
