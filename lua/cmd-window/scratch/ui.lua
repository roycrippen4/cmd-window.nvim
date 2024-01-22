-- -- local logger = require('cmd-window.logger')
-- -- local history = require('cmd-window.history')

-- local api = vim.api
-- local ui = {}

-- ui.title = {}
-- ui.content = {}
-- ui.cache = {}

-- -- Define dimensions
-- local width = math.ceil(vim.o.columns * 0.8)
-- local height = math.ceil(vim.o.lines * 0.8)
-- local title_height = 1 -- Height of the title window

-- -- Position calculations
-- local col = math.ceil((vim.o.columns - width) / 2)
-- local title_row = math.ceil((vim.o.lines - height) / 2)
-- local content_row = title_row + title_height

-- -- Create buffers
-- ui.title.bufnr = api.nvim_create_buf(false, true)
-- ui.content.bufnr = api.nvim_create_buf(false, true)

-- -- Title window options
-- local title_opts = {
--   style = 'minimal',
--   relative = 'editor',
--   width = width,
--   height = title_height,
--   row = title_row,
--   col = col,
--   focusable = false,
-- }

-- -- Content window options
-- local content_opts = {
--   style = 'minimal',
--   relative = 'editor',
--   width = width,
--   height = height - title_height,
--   row = content_row,
--   col = col,
-- }

-- function ui.open()
--   -- make the windows
--   ui.content.winnr = api.nvim_open_win(ui.content.bufnr, true, content_opts)
--   ui.title.win_id = api.nvim_open_win(ui.title.bufnr, true, title_opts)

--   -- get their content
--   ui.title.val = 'My Custom Window'
--   ui.content.val = { 'Scrollable line 1', 'Scrollable line 2', '...' }

--   -- set their content
--   api.nvim_buf_set_lines(ui.title.bufnr, 0, 1, false, { ui.title.val })
--   api.nvim_buf_set_lines(ui.content.bufnr, 0, -1, false, ui.content.val)
-- end

-- function ui.close()
--   vim.api.nvim_buf_delete(ui.title.bufnr, { force = true })
--   vim.api.nvim_buf_delete(ui.content.bufnr, { force = true })
--   vim.api.nvim_win_close(ui.title.win_id, true)
--   vim.api.nvim_win_close(ui.content.win_id, true)
-- end

-- return ui

-- -- Add content

-- -- Customize appearance (optional)
-- -- api.nvim_win_set_option(title_win, 'winhl', 'Normal:Floating')
-- -- api.nvim_win_set_option(content_win, 'winhl', 'Normal:Floating')
