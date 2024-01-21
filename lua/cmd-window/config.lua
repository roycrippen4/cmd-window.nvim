local M = {}

---@return CmdWindowOptions
function M.get_default_config()
  return {
    opts = {
      debug = true,
    },
    win_opts = {
      title = 'hello',
      title_pos = 'right',
      relative = 'editor',
      border = 'rounded',
      width = 100,
      height = 10,
    },
  }
end

--- Merges the default and user configuration tables.
---
---@param partial_config? PartialConfig User configuration for |cmd-window|
---      - win_opts: The available window options for |nvim-win-open|
---      - options: NOT IMPLEMENTED YET
---@return CmdWindowOptions
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
