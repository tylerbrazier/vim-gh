local function git(args)
	local result = vim.system(vim.split('git '..args, ' ')):wait()
	if result.code ~= 0 then error(result.stderr) end
	return vim.trim(result.stdout)
end

local function repo()
	local remote_url = git('remote get-url origin')
	-- e.g. git@github.com:tylerbrazier/vim-gh(.git)
	return remote_url:match(':(.-)%.?g?i?t?$')
end

local function pr_description()
	local n = tonumber(git('rev-list --count --no-merges origin/HEAD..'))
	local f = n == 1 and '%b' or '-%x20%s%n%b'
	return git('log --reverse --no-merges origin/HEAD.. --format='..f)
end

local function url_encode(str)
	if not str then return '' end
	return str:gsub(" ", "+"):gsub("([^%+%w%-_%.~])", function(c)
		return string.format("%%%02X", string.byte(c))
	end)
end

vim.api.nvim_create_user_command('PR',
	function(opts)
		local branch = git('branch --show-current')
		local q = string.format('expand=1&title=%s&body=%s',
			url_encode(opts.args),
			url_encode(pr_description())
		)
		vim.ui.open(
			string.format('https://github.com/%s/compare/%s?%s',
				repo(), branch, q)
		)
	end,
	{ nargs = '*' }
)
