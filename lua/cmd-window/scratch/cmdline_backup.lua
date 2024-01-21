
-- Public

-- M.autocomplete = function(text)
--   local split = vim.split(text, ' ')
--   table.remove(split)
--   local input_start = table.concat(split, ' ')
--   local completions = assert(vim.fn.getcompletion(text, 'cmdline'), 'No completions found')
--   cache.commands = {}

--   for i = #completions, 1, -1 do
--     local suggestion = table.concat({ input_start, completions[i] }, ' ')
--     fn.add_command(i, vim.trim(suggestion))
--   end

--   return cache.commands
-- end

-- fn.add_command = function(index, cmd)
--   table.insert(cache.commands, { id = 1000 + index, cmd = cmd, type = 'command' })
-- end
-- cache.commands = {}
-- cache.system = {}

-- fn.add_system = function(index, cmd)
--   table.insert(cache.system, { id = index, cmd = '!' .. cmd, type = 'system' })
-- end

-- M.system_command = function(text)
--   local split = vim.split(text, ' ')
--   local parts = #split
--   local input_start = ''

--   if parts > 1 then
--     table.remove(split)
--     input_start = table.concat(split, ' ')
--     input_start = string.gsub(input_start, '!', '', 1)
--   end

--   cache.system = {}
--   local completions = assert(vim.fn.getcompletion(text, 'cmdline'), 'No completions found')

--   for i = #completions, 1, -1 do
--     if parts > 1 then
--       local suggestion = table.concat({ input_start, vim.trim(completions[i]) }, ' ')
--       fn.add_system(i, suggestion)
--     else
--       fn.add_system(i, completions[i])
--     end
--   end

--   return cache.system
-- end

-- Arrays to store results
