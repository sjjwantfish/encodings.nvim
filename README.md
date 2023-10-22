# encodings.nvim
Quickly set encoding for current buffer by [telescope](https://github.com/nvim-telescope/telescope.nvim).

# Install
Using your favorate plugin manager, for example [lazy.nvim](https://github.com/folke/lazy.nvim).
```lua
{ "sjjwantfish/encodings.nvim" }
```

# Configuration
You don't have to config `encodings.nvim` unless you need to custom encodings or telescope action.
Here is a configuration example.
```lua
local telescope = require("telescope")
telescope.setup({
	extensions = {
        encodings = {
            action = function(encoding) end, -- see `:help telescope.actions`
            -- @param encoding table
            encodings = {
                {
                    value = "gbk", -- required
                    description = "custom encodin GBK",
                    category = "",
                },
            },
        }
	},
})
telescope.load_extension("encodings")
```

# Useage
```lua
Telescope encodings
```
