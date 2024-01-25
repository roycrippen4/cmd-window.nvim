---@alias TitlePosition "left"|"center"|"right".
---@alias BorderStyle "none"|"single-h"|"single-l"|"double"|"rounded"|"solid"
---@alias WindowType 'cmd'|'search'

---@class HistoryDisplayOpts
---@field cmd? DisplayOpts
---@field search? DisplayOpts

---@class Title
---@field text? string The title text.
---@field pos? TitlePosition Position of the title.
---@field hl? string Highlight group for the title.

---@class Border
---@field style? BorderStyle The styling for the border.
---@field hl? string Highlight group for the border.

---@class Prompt
---@field icon? string Icon for the prompt.
---@field hl? string Highlight group for the icon.

---@class DisplayOpts
---@field title? Title Table of title settings.
---@field border? Border Table of border settings.
---@field row? integer The start row for the window.
---@field col? integer The start col for the window.
---@field width? integer Width value passed to nvim_open_win.
---@field height? integer Height value passed to nvim_open_win.
---@field prompt? Prompt Icon/hl_group pair

---@class Display
---@field cmdline? DisplayOpts
---@field search? DisplayOpts
---@field history? HistoryDisplayOpts

---@class PartialConfig
---@field opts? PluginOptions

---@class PluginOptions
---@field debug? boolean
---@field display? Display

---@class DataItem
---@field cmd string
---@field id integer

---@class item
---@field id integer
---@field cmd string

---@class Data
---@field command item[]
---@field search item[]
