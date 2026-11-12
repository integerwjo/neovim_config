-- Language settings for HLA (High Level Assembly).
-- The ~/.local/bin/hla launcher sets the lowercase include/lib variables and
-- writes <name>.o next to the source file; `:make` therefore uses %:p.

vim.bo.commentstring = "// %s"
vim.bo.expandtab = true
vim.bo.tabstop = 4
vim.bo.shiftwidth = 4
vim.bo.softtabstop = 4
vim.bo.smartindent = true

vim.bo.makeprg = "hla %:p"
vim.bo.errorformat = table.concat({
	'%EError in file "%f" at line %l %m',
	"%C%m",
	"%ZHLAPARSE assembly failed%.%#",
}, ",")

local function run_hla()
	local exe = vim.fn.expand("%:p:r")
	if vim.fn.executable(exe) == 1 then
		vim.cmd("!" .. vim.fn.shellescape(exe))
	else
		vim.notify("Not built yet: " .. exe .. " (run :make or <leader>mm)", vim.log.levels.WARN)
	end
end

vim.api.nvim_buf_create_user_command(0, "HlaRun", run_hla, {
	desc = "Run the compiled HLA program",
})
vim.keymap.set("n", "<leader>mr", run_hla, { buffer = true, desc = "Run HLA program" })

vim.b.undo_ftplugin = (vim.b.undo_ftplugin or "")
	.. "\nsetlocal commentstring< expandtab< tabstop< shiftwidth< softtabstop< smartindent< makeprg< errorformat<"
