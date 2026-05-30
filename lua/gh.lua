local function git(args, wd)
	local cmd = 'git -C '..(wd or vim.fn.getcwd())
	local result = vim.system(vim.split(cmd..' '..args, ' ')):wait()
	if result.code ~= 0 then error(result.stderr) end
	return vim.trim(result.stdout)
end

local function repo(remote, wd)
	local remote_url = git('remote get-url '..remote, wd)
	-- e.g. git@github.com:tylerbrazier/nvim-gh(.git)
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

local function open(opts)
	opts = opts or {}

	local gh_url = 'https://github.com'
	local wd = opts.file ~= nil
		and vim.fn.fnamemodify(opts.file, ':p:h')
		or vim.fn.getcwd()

	if opts.remote ~= nil then
		gh_url = gh_url..'/'..repo(opts.remote, wd)
	end

	if opts.ref ~= nil then
		gh_url = vim.fn.join({
			gh_url, 
			opts.file ~= nil and 'blob' or 'commit',
			git('rev-parse '..opts.ref, wd),
		}, '/')
	end

	if opts.file ~= nil then
		local fname = vim.fn.fnamemodify(opts.file, ':t')
		local path = git('ls-files --full-name -- '..fname, wd)
		gh_url = gh_url..'/'..path
	end

	if opts.line ~= nil then
		local line = vim.fn.line(opts.line) -- parse "." etc.
		line = line > 0 and line or opts.line
		gh_url = gh_url..'#L'..line
	end

	return vim.ui.open(gh_url)
end

local function pr(title)
	local branch = git('branch --show-current')
	local q = string.format('expand=1&title=%s&body=%s',
		url_encode(title),
		url_encode(pr_description())
	)
	vim.ui.open(
		string.format('https://github.com/%s/compare/%s?%s',
		repo('origin'), branch, q)
	)
end

return { open = open, pr = pr }
