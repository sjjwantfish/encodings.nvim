local actions = require("telescope.actions")
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values
local entry_display = require("telescope.pickers.entry_display")
local action_state = require("telescope.actions.state")

local encodings = {
	{
		category = "8bit",
		value = "latin1",
		description = "8-bit characters (ISO 8859-1, also used for cp1252)",
	},
	{ category = "8bit", value = "iso-8859-n", description = "ISO_8859 variant (n = 2 to 15)" },
	{ category = "8bit", value = "koi8-r", description = "Russian" },
	{ category = "8bit", value = "koi8-u", description = "Ukrainian" },
	{ category = "8bit", value = "macroman", description = "MacRoman (Macintosh encoding)" },
	-- { category = "8bit", value = "8bit-{name} any 8-bit encoding (Vim specific name)" },
	{ category = "8bit", value = "cp437", description = "similar to iso-8859-1" },
	{ category = "8bit", value = "cp737", description = "similar to iso-8859-7" },
	{ category = "8bit", value = "cp775", description = "Baltic" },
	{ category = "8bit", value = "cp850", description = "similar to iso-8859-4" },
	{ category = "8bit", value = "cp852", description = "similar to iso-8859-1" },
	{ category = "8bit", value = "cp855", description = "similar to iso-8859-2" },
	{ category = "8bit", value = "cp857", description = "similar to iso-8859-5" },
	{ category = "8bit", value = "cp860", description = "similar to iso-8859-9" },
	{ category = "8bit", value = "cp861", description = "similar to iso-8859-1" },
	{ category = "8bit", value = "cp862", description = "similar to iso-8859-1" },
	{ category = "8bit", value = "cp863", description = "similar to iso-8859-8" },
	{ category = "8bit", value = "cp865", description = "similar to iso-8859-1" },
	{ category = "8bit", value = "cp866", description = "similar to iso-8859-5" },
	{ category = "8bit", value = "cp869", description = "similar to iso-8859-7" },
	{ category = "8bit", value = "cp874", description = "Thai" },
	{ category = "8bit", value = "cp1250", description = "Czech, Polish, etc." },
	{ category = "8bit", value = "cp1251", description = "Cyrillic" },
	{ category = "8bit", value = "cp1253", description = "Greek" },
	{ category = "8bit", value = "cp1254", description = "Turkish" },
	{ category = "8bit", value = "cp1255", description = "Hebrew" },
	{ category = "8bit", value = "cp1256", description = "Arabic" },
	{ category = "8bit", value = "cp1257", description = "Baltic" },
	{ category = "8bit", value = "cp1258", description = "Vietnamese" },
	-- {
	--   category = "8bit",
	--   value = "cp{number}",
	--   description = "MS-Windows: any installed single-byte codepage",
	-- },
	{ category = "2byte", value = "cp932", description = "Japanese (Windows only)" },
	{ category = "2byte", value = "euc-jp", description = "Japanese" },
	{ category = "2byte", value = "sjis", description = "Japanese" },
	{ category = "2byte", value = "cp949", description = "Korean" },
	{ category = "2byte", value = "euc-kr", description = "Korean" },
	{ category = "2byte", value = "cp936", description = "simplified Chinese (Windows only)" },
	{ category = "2byte", value = "euc-cn", description = "simplified Chinese" },
	{ category = "2byte", value = "cp950", description = "traditional Chinese (alias for big5)" },
	{ category = "2byte", value = "big5", description = "traditional Chinese (alias for cp950)" },
	{ category = "2byte", value = "euc-tw", description = "traditional Chinese" },
	-- { category = "2byte", value = "2byte-{name} any double-byte encoding (Vim-specific name)" },
	-- {
	--   category = "2byte",
	--   value = "cp{number}",
	--   description = "MS-Windows: any installed double-byte codepage",
	-- },
	{
		category = "Unicode",
		value = "utf-8",
		description = "32 bit UTF-8 encoded Unicode (ISO/IEC 10646-1)",
	},
	{
		category = "Unicode",
		value = "ucs-2",
		description = "16 bit UCS-2 encoded Unicode (ISO/IEC 10646-1)",
	},
	{ category = "Unicode", value = "ucs-2le", description = "like ucs-2, little endian" },
	{
		category = "Unicode",
		value = "utf-16",
		description = "ucs-2 extended with double-words for more characters",
	},
	{ category = "Unicode", value = "utf-16le", description = "like utf-16, little endian" },
	{
		category = "Unicode",
		value = "ucs-4",
		description = "32 bit UCS-4 encoded Unicode (ISO/IEC 10646-1)",
	},
	{ category = "Unicode", value = "ucs-4le", description = "like ucs-4, little endian" },
}

local function merge_encodings(custom_encodings)
	if custom_encodings == nil then
		return encodings
	end
	for _, encoding in ipairs(custom_encodings or {}) do
		if encoding.value == nil then
			encoding.value = ""
		end
		encoding.category = "custom"
		if encoding.description == nil then
			encoding.description = ""
		end
		encodings[#encodings + 1] = encoding
	end
	return encodings
end

local function action(encoding)
	vim.cmd("e ++enc=" .. encoding.value .. " %")
end

local function search_encodings(opts)
	local displayer = entry_display.create({
		separator = "|",
		items = {
			{ width = 30 },
			{ width = 20 },
			{ remaining = true },
		},
	})
	local make_display = function(entry)
		return displayer({
			entry.value,
			entry.category,
			entry.description,
		})
	end

	pickers
		.new(opts, {
			prompt_title = "Encodings",
			sorter = conf.generic_sorter(opts),
			finder = finders.new_table({
				results = encodings,
				entry_maker = function(encoding)
					return {
						ordinal = encoding.value .. encoding.category .. encoding.description,
						display = make_display,
						value = encoding.value,
						category = encoding.category,
						description = encoding.description,
					}
				end,
			}),
			attach_mappings = function(prompt_bufnr)
				actions.select_default:replace(function()
					local encoding = action_state.get_selected_entry()
					actions.close(prompt_bufnr)
					action(encoding)
				end)
				return true
			end,
		})
		:find()
end

return require("telescope").register_extension({
	setup = function(config)
		action = config.action or action
		encodings = merge_encodings(config.encodings)
	end,
	exports = { encodings = search_encodings },
})
