local logger = require('cmd-window.logger')

M = {}

---@param ok boolean
---@param err unknown|nil
local function handle_error(ok, err)
  if not ok and err then
    logger:log('ok: ', ok, ' err: ', err)
    local idx = err:find(':E')
    if type(idx) ~= 'number' then
      return
    end
    local msg = err:sub(idx + 1):gsub('\t', '    ')
    vim.notify(msg, vim.log.levels.ERROR)
  end
end

---@param fn any
---@param args? any
function M.pcall(fn, args)
  local ok, err = pcall(function()
    fn(args)
  end)
  handle_error(ok, err)
end

-- I might need this later for cmp_cmdline - not sure yet.
-- ---@param fn fun(mod)
-- function M.on_module(module, fn)
--   if package.loaded[module] then
--     return fn(package.loaded[module])
--   end

--   package.preload[module] = function()
--     package.preload[module] = nil
--     for _, loader in pairs(package.loaders) do
--       local ret = loader(module)
--       if type(ret) == 'function' then
--         local mod = ret()
--         fn(mod)
--         return mod
--       end
--     end
--   end
-- end

return M
