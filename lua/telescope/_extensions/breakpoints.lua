local breakpointPicker = {}
local conf = require('telescope.config').values
--:local conf = require('telescope.make_entry')
local function new(opts)
	return setmetatable({}, { __index = breakpointPicker })
end

local function get(opts)
	local breakpoints = require("dap.breakpoints")
	local current_breakpoints = breakpoints.get()
	-- enrich breakpoints data
	local enriched_breakpoints = {}
	local idx = 1
	for bufnum, bp in pairs(current_breakpoints) do
		local filename = vim.api.nvim_buf_get_name(bufnum)
		for _, lineNum in pairs(bp) do
			table.insert(enriched_breakpoints, {
				path = filename,
				bufnum = bufnum,
				lnum = lineNum.line,
			})
			idx = idx + 1
		end
	end
	return enriched_breakpoints
end

local function select(ops)
	return "select"
end

local function create()
	finders = require("telescope.finders")
	-- opts = require("telescope.themes").get_ivy({})
	local sorters = require("telescope.sorters")
	require("telescope.pickers")
		.new(opts, {
			prompt_title = "list breakpoints",
			finder = finders.new_table({
				results = get(opts),
				entry_maker = function(entry)
					print(vim.inspect(entry))
					return {
						value = entry,
						display = entry.path .. ":" .. entry.lnum,
						ordinal = entry.bufnum,
            filename = entry.path,
            lnum = entry.lnum,
					}
				end,
			}),
      previewer = conf.grep_previewer(opts),
			sorter = sorters.highlighter_only(opts),
		})
		:find()
end

local telescope = require("telescope")
return telescope.register_extension({
	setup = function(ext_config, config)
		-- access extension config and user config
	end,
	exports = {
		breakpoints = create,
	},
})
