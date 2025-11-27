" :GH to open github.com
"
" TODO
" - make it work for https remote urls
" - will the `open` command work everywhere?
" - open commit hash under cursor in github?

if exists("g:loaded_gh") || &cp
	finish
endif
let g:loaded_gh = 1

silent! nnoremap <unique> gh :GH <Up>

command -nargs=* -complete=file GH call s:gh(<f-args>)

function s:gh(remote=0, ref=0, file=0, line=0) abort
	let gh_url = 'https://github.com'
	let wd = empty(a:file) ? getcwd() : fnamemodify(a:file, ':p:h')

	if !empty(a:remote)
		let remote_url = s:git('remote get-url '..a:remote, wd)
		" e.g. git@github.com:tylerbrazier/vim-gh.git
		let repo = substitute(remote_url,
					\'^.*:\(.\{-}\)\(\.git\)\?$',
					\'/\1', '')
		let gh_url ..= repo
	endif

	if !empty(a:ref)
		let gh_url = join([
					\gh_url,
					\empty(a:file) ? 'tree' : 'blob',
					\s:resolve(a:ref, wd)
					\], '/')
	endif

	if !empty(a:file)
		let fname = fnamemodify(a:file, ':t')
		let path = s:git('ls-files --full-name -- '
					\..shellescape(fname), wd)
		let gh_url ..= '/'..path
	endif

	if !empty(a:line)
		let line_num = line(a:line) ?? a:line
		let gh_url ..= '#L'..line_num
	endif

	call system('open '..gh_url)
endfunction

function s:git(args, wd)
	let cmd = 'git -C '..shellescape(a:wd)..' '..a:args
	let result = trim(system(cmd))
	if v:shell_error
		echohl ErrorMsg | echo 'Error executing: '..cmd | echohl None
		throw result
	endif
	return result
endfunction

function s:resolve(ref, wd)
	" resolve symbolic refs (all caps) like HEAD to commits
	" but leave anything else as is
	return match(a:ref, '^[A-Z_]\+$') > -1
				\? s:git('rev-parse '..a:ref, a:wd)
				\: a:ref
endfunction
