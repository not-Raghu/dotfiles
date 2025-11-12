-- Exit terminal mode with Escape
vim.keymap.set("t", "<leader>t", "<c-\\><c-n>")

local state = {
	floating = {
		buf = -1,
		win = -1,
	},
}

-- Get the current working directory, accounting for tmux
local function get_current_cwd()
	-- First try to get the current buffer's directory
	local current_file = vim.api.nvim_buf_get_name(0)
	if current_file ~= "" then
		return vim.fn.fnamemodify(current_file, ":h")
	end
	
	-- If in tmux, try to get the pane's working directory
	if vim.env.TMUX then
		local handle = io.popen("tmux display-message -p '#{pane_current_path}' 2>/dev/null")
		if handle then
			local tmux_cwd = handle:read("*l")
			handle:close()
			if tmux_cwd and tmux_cwd ~= "" then
				return tmux_cwd
			end
		end
	end
	
	-- Fallback to vim's current working directory
	return vim.fn.getcwd()
end

local function create_floating_window(opts)
	opts = opts or {}
	local width = opts.width or math.floor(vim.o.columns * 0.75)
	local height = opts.height or math.floor(vim.o.lines * 0.75)

	-- Calculate the position to center the window
	-- Account for command line and status line
	local col = math.max(0, math.floor((vim.o.columns - width) / 2))
	local row = math.max(0, math.floor((vim.o.lines - height) / 2) - 1)
	
	-- Ensure the window fits on screen
	if col + width > vim.o.columns then
		col = vim.o.columns - width
	end
	if row + height > vim.o.lines - 2 then -- Leave room for command line
		row = vim.o.lines - height - 2
	end

	-- Create a buffer
	local buf = nil
	if vim.api.nvim_buf_is_valid(opts.buf) then
		buf = opts.buf
	else
		buf = vim.api.nvim_create_buf(false, true) -- No file, scratch buffer
	end

	-- Define window configuration
	local win_config = {
		relative = "editor",
		width = width,
		height = height,
		col = col,
		row = row,
		style = "minimal", -- No borders or extra UI elements
		border = "rounded",
	}

	-- Create the floating window
	local win = vim.api.nvim_open_win(buf, true, win_config)
	
	-- Set window-local options for better terminal experience
	vim.wo[win].winblend = 0
	vim.wo[win].signcolumn = "no"

	return { buf = buf, win = win }
end

local toggle_terminal = function()
	if not vim.api.nvim_win_is_valid(state.floating.win) then
		state.floating = create_floating_window({ buf = state.floating.buf })
		if vim.bo[state.floating.buf].buftype ~= "terminal" then
			-- Get the current working directory
			local cwd = get_current_cwd()
			-- Change to the directory before opening terminal
			local original_cwd = vim.fn.getcwd()
			vim.cmd("cd " .. vim.fn.fnameescape(cwd))
			vim.cmd.terminal()
			-- Restore original cwd for vim
			vim.cmd("cd " .. vim.fn.fnameescape(original_cwd))
		end
		-- Enter insert mode automatically
		vim.cmd("startinsert")
	else
		vim.api.nvim_win_hide(state.floating.win)
	end
end

-- Close terminal on exit
vim.api.nvim_create_autocmd("TermClose", {
	callback = function()
		if vim.api.nvim_win_is_valid(state.floating.win) then
			vim.api.nvim_win_close(state.floating.win, true)
			state.floating.win = -1
			state.floating.buf = -1
		end
	end,
})

-- Create user command and keymap
vim.api.nvim_create_user_command("Floaterminal", toggle_terminal, {})
vim.keymap.set("n", "<leader>ft", toggle_terminal, { desc = "Toggle floating terminal" })
