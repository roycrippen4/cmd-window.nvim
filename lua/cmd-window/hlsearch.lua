local logger = require('cmd-window.logger')
local UI = require('cmd-window.ui')

local M = {}

function M.is_new_search(char)
  return vim.fn.mode() == 'c' and vim.fn.keytrans(char) == '<CR>' and vim.fn.getcmdtype() == '/'
end

M.id = nil
M.ns = vim.api.nvim_create_namespace('search_virt')

function M.clear()
  if M.id ~= nil then
    vim.api.nvim_buf_del_extmark(0, M.ns, M.id)
  end
end

---@param bufnr integer buffer id
---@param win_id integer window id
---@param cur integer search item the mouse is on
---@param total integer total count of search items
function M.draw_virt_text(bufnr, win_id, cur, total)
  M.searching = true
  M.clear()
  if cur == 0 and total == 0 then
    return
  end
  return vim.api.nvim_buf_set_extmark(bufnr, M.ns, vim.api.nvim_win_get_cursor(win_id)[1] - 1, 0, {
    virt_text = { { '[' .. cur .. '/' .. total .. ']', 'CmdWindowVirtualText' } },
    virt_text_pos = 'eol',
  })
end

local function callback(bufnr, win_id)
  return function(char)
    if M.is_new_search(char) then
      vim.schedule(function()
        local searchcount = vim.fn.searchcount()
        M.id = M.draw_virt_text(bufnr, win_id, searchcount.current, searchcount.total)
      end)
    end

    if vim.fn.mode() == 'n' then
      vim.schedule(function()
        local new_hlsearch =
          vim.tbl_contains({ 'n', 'N', '*', '#', '?', '/' }, vim.fn.keytrans(char))
        local searchcount = vim.fn.searchcount()

        if new_hlsearch and searchcount.current ~= 0 then
          M.id = M.draw_virt_text(bufnr, win_id, searchcount.current, searchcount.total)
        end

        if vim.opt.hlsearch:get() ~= new_hlsearch then
          vim.opt.hlsearch = new_hlsearch
          if not new_hlsearch then
            M.searching = false
            M.clear()
          end
        end
      end)
    end
  end
end

---@param bufnr integer buffer id
---@param win_id integer window id
function M.hl_search(bufnr, win_id)
  vim.on_key(callback(bufnr, win_id), vim.api.nvim_create_namespace('auto_hlsearch'))

  -- This is kinda close to what I need
  -- vim.api.nvim_create_autocmd({ 'TextChangedI', 'CursorMoved' }, {
  --   group = vim.api.nvim_create_augroup('CmdWindowHlSearch', { clear = true }),
  --   callback = function()
  --     if vim.bo.ft == 'CmdWindow' then
  --       local cmd_win_id = vim.api.nvim_get_current_win()
  --       local current_line = vim.fn.line('.', cmd_win_id)

  --       if current_line and UI.type == 'search' then
  --         local search = vim.fn.getline(current_line)
  --         vim.fn.matchadd('CurSearch', search, _, -1, { window = win_id })
  --       end
  --     end
  --   end,
  -- })
end

return M
