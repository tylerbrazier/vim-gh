" Open a file on github.com
"
" TODO
" - make it work for https remote urls
" - will the `open` command work everywhere?

if exists("g:loaded_gh") || &cp
	finish
endif
let g:loaded_gh = 1

silent! nnoremap <unique> gh :.GH origin HEAD %

command -count -nargs=* -complete=file GH call GH(<f-args>, <count>)

function GH(remote, ref, file, line) abort
	let wd = fnamemodify(a:file, ':p:h')
	let fname = fnamemodify(a:file, ':t')
	let path = s:git('ls-files --full-name -- '..shellescape(fname), wd)
	let remote_url = s:git('remote get-url '..a:remote, wd)
	" git@github.com:tylerbrazier/vim-gh.git
	let repo = substitute(remote_url, '^.*:\(.\{-}\)\(\.git\)\?$', '\1', '')
	let commit = s:git('rev-parse '..a:ref, wd)
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
