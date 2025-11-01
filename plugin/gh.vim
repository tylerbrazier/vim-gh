" Open a file on github.com
"
" TODO
" - make it work for https remote urls
" - allow remotes other than origin
" - allow branches/commits other than HEAD
" - will the `open` command work everywhere?

if exists("g:loaded_gh") || &cp
	finish
endif
let g:loaded_gh = 1

silent! nnoremap <unique> gh :.GH %

command -count -nargs=1 -complete=file GH call GH(<q-args>, <count>)

function GH(file, line) abort
	let wd = fnamemodify(a:file, ':p:h')
	let fname = fnamemodify(a:file, ':t')
	let path = s:git('ls-files --full-name -- '..shellescape(fname), wd)
	let remote_url = s:git('remote get-url origin', wd)
	" git@github.com:tylerbrazier/vim-gh.git
	let repo = substitute(remote_url, '^.*:\(.\{-}\)\(\.git\)\?$', '\1', '')
	let commit = s:git('rev-parse HEAD', wd)
	let gh_url = 'https://github.com/'..repo..'/blob/'..commit..'/'..path
	if a:line
		let gh_url ..= '#L'..a:line
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
