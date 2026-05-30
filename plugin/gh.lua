local gh = require('gh')

vim.api.nvim_create_user_command('PR',
	function(opts) gh.pr(opts.args) end,
	{ nargs = '*' }
)

vim.api.nvim_create_user_command('GH',
	function(opts)
		gh.open({
			remote = opts.fargs[1],
			ref = opts.fargs[2],
			file = opts.fargs[3],
			line = opts.fargs[4],
		})
	end,
	{ nargs = '*', complete = 'file' }
)

vim.keymap.set('n', 'gh', ':GH <Up>')
