`:GH` to open [github.com](https://github.com)

`gh` is a shortcut to bring up the previous `:GH` command

Usage:

    :GH [remote] [ref] [file] [line]

Most commonly I use this to open the current file on the current line:

    :GH origin HEAD % .

To open a pull request after pushing a branch:

    :PR [title of pull request]

this also populates the description using the commit messages on the branch.

**TODO**

- make it work for https remote urls
- make `:PR` work for remotes other than `origin`
