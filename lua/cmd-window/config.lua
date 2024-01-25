local M = {}
local w_width = 100
local w_height = 20
local width = 50
local height = 1

---@return PluginOptions
function M.get_default_config()
  return { ---@type PluginOptions
    opts = {
      debug = true,
    },
    display = {
      cmdline = {
        title = {
          text = ' Command ',
          pos = 'center',
          hl = 'CmdWindowTitle',
        },
        border = {
          style = 'rounded',
          hl = 'CmdWindowBorder',
        },
        prompt = {
          icon = '',
          hl = 'CmdWindowPrompt',
        },
        -- row = math.floor(((vim.o.lines - height) / 2) - 1),
        -- col = math.floor((vim.o.columns - width) / 2),
        row = 5,
        col = math.floor((vim.o.columns - width) / 2),
        width = width,
        height = height,
      },
      search = {
        title = {
          text = ' Search ',
          pos = 'center',
          hl = 'CmdWindowTitle',
        },
        border = {
          style = 'rounded',
          hl = 'CmdWindowBorder',
        },
        prompt = {
          icon = '',
          hl = 'CmdWindowPrompt',
        },
        row = math.floor(((vim.o.lines - height) / 2) - 1),
        col = math.floor((vim.o.columns - width) / 2),
        width = width,
        height = height,
      },
      history = {
        cmd = {
          title = {
            text = ' Command History ',
            pos = 'center',
            hl = 'CmdWindowTitle',
          },
          border = {
            style = 'rounded',
            hl = 'CmdWindowBorder',
          },
          prompt = {
            icon = '',
            hl = 'CmdWindowPrompt',
          },
          row = math.floor(((vim.o.lines - w_height) / 2) - 1),
          col = math.floor((vim.o.columns - w_width) / 2),
          width = w_width,
          height = w_height,
        },
        search = {
          title = {
            text = ' Search History ',
            pos = 'center',
            hl = 'CmdWindowTitle',
          },
          border = {
            style = 'rounded',
            hl = 'CmdWindowBorder',
          },
          prompt = {
            icon = '',
            hl = 'CmdWindowPrompt',
          },
          row = math.floor(((vim.o.lines - w_height) / 2) - 1),
          col = math.floor((vim.o.columns - w_width) / 2),
          width = w_width,
          height = w_height,
        },
      },
    },
  }
end

--- Merges the default and user configuration tables.
---
---@param partial_config? PartialConfig User configuration for |cmd-window|
---      - win_opts: The available window options for |nvim-win-open|
---      - options: NOT IMPLEMENTED YET
---@return PluginOptions
function M.merge_config(partial_config)
  partial_config = partial_config or {}
  local config = M.get_default_config()

  if partial_config == {} then
    return config
  end

  for k, v in pairs(partial_config) do
    config[k] = vim.tbl_extend('force', config[k] or {}, v)
  end
  return config
end

return M
