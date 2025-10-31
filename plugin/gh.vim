" Open a file on github.com
"
" TODO
" - make it work when cwd is not in a git repo
" - make it work for https remote urls
" - allow remotes other than origin
" - allow branches/commits other than HEAD
" - add error handling
" - will the `open` command work everywhere?

if exists("g:loaded_gh") || &cp
	finish
endif
let g:loaded_gh = 1

silent! nnoremap <unique> gh :.GH %

command -count -nargs=1 -complete=file GH call GH(<q-args>, <count>)

function GH(file, line)
	let path = trim(system('git ls-files --full-name -- '..a:file))
	let remote_url = trim(system('git remote get-url origin'))
	" git@github.com:tylerbrazier/vim-gh.git
	let repo = substitute(remote_url, '^.*:\(.\{-}\)\(\.git\)\?$', '\1', '')
	let commit = trim(system('git rev-parse HEAD'))
	let gh_url = 'https://github.com/'..repo..'/blob/'..commit..'/'..path
	if a:line
		let gh_url ..= '#L'..a:line
	endif
	call system('open '..gh_url)
endfunction
