# Dotfiles's contributing guide

You can help contribute to Dotfiles in many ways, including

## Writing code

* Follow shell scripting best practices (e.g. as described in
[Google's shell style guide](https://google.github.io/styleguide/shell.xml))
* Try to be POSIX compliant
* Use `"${variable}"` instead of `$variable`
* Constants (and global variables) should be in `UPPER_CASE`, other variables
should be in `lower_case`
* Use single square brackets (`[ condition ]`) for conditionals
(e.g. in 'if' statements)
* Write clean and readable code
* Write comments where needed (e.g. explaining functions)
* Explain what arguments a function takes (if any)
* Use different error codes when exiting and explain when they occur
at the top of the file
* If you've created a new file or have made a lot of changes
(judge this by yourself), you can add a copyright disclaimer below the shebang
line and below any other copyright notices
(e.g. `Copyright (C) Jane Doe <contact@jane.doe>`)
* Always line wrap at 80 characters
* Scripts should be named `setup-<function>` and should not have an extension
* Libraries should always have a `.sh` extension and should not have a shebang
* Neither scripts nor libraries should be executable (their permissions are
set during compilation)
* Use `shellscript` to error-check your code
* Test your code before submitting a PR (not required if it's a draft)
* Write long and informative commit messages
