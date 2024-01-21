---@alias title_pos "left"|"center"|"right".
---@alias border "none"|"single"|"double"|"rounded"|"solid"|"shadow"
---@alias relative "editor"|"win"|"cursor"|"mouse"

---@class UICache
---@field bufnr? integer The bufnr for the UI.
---@field win_id? integer The window id for the UI.

---@class WinOpts
---@field title? string Title value passed to nvim_open_win
---@field title_pos? title_pos Title position value passed to nvim_open_win
---@field relative? relative Where to open the window. Passed into nvim_open_win
---@field border? border Border value passed to nvim_open_win
---@field width? integer Width value passed to nvim_open_win
---@field height? integer Height value passed to nvim_open_win

---@class UI
---@field win_id integer
---@field bufnr integer
---@field win_opts WinOpts
---@field cache UICache

---@class PartialConfig
---@field win_opts? WinOpts
---@field opts? table|nil

---@class Opts table
---@field debug? boolean

---@class CmdWindowOptions
---@field win_opts WinOpts
---@field opts Opts

---@class History
---@field history HistoryItem[]

---@class HistoryItem
---@field cmd string
---@field id integer
