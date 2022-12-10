# Contributing guide

When contributing to this repository, please first discuss the change you wish to make via issue, email, or any other method with the owners of this repository before making a change.

Please note we have a [code of conduct](./.github/CODE_OF_CONDUCT.md), please follow it in all your interactions with the project.

You can help contribute to this project in many ways, including:

## Reporting Bugs/Feature Requests

We welcome you to use the GitHub issue tracker to report bugs or suggest features.

When filing an issue, please check existing open, or recently closed, issues to make sure somebody else hasn't already
reported the issue. Please try to include as much information as you can. Details like these are incredibly useful:

* A reproducible test case or series of steps
* The version of our code being used
* Any modifications you've made relevant to the bug
* Anything unusual about your environment or deployment

### Reporting Bugs

This section guides you through submitting a bug report for this project. Following these guidelines helps maintainers and the community understand your report, reproduce the behavior, and find related reports.

When creating bug reports please fill out [the required template](./.github/ISSUE_TEMPLATE/bug_report.md), the information it asks for helps us resolve issues faster.

### Suggesting Enhancements

This section guides you through submitting an enhancement suggestion for this project, including completely new features and minor improvements to existing functionality. Following these guidelines helps maintainers and the community understand your suggestion and find related suggestions.

When creating enhancement suggestions, please fill in [the template](./.github/ISSUE_TEMPLATE/feature_request.md), including the steps that you imagine you would take if the feature you're requesting existed.

## Contributing via Pull Requests

Contributions via pull requests are much appreciated. Before sending us a pull request, please ensure that:

1. You are working against the latest source on the *main* branch.
2. You check existing open, and recently merged, pull requests to make sure someone else hasn't addressed the problem already.
3. You open an issue to discuss any significant work - we would hate for your time to be wasted.

To send us a pull request, please:

1. Fork the repository.
2. Modify the source; please focus on the specific change you are contributing. If you also reformat all the code, it will be hard for us to focus on your change.
3. Ensure local tests pass (*if applicable*).
4. Commit to your fork using clear commit messages.
5. Send us a pull request, answering any default questions in the pull request template.
6. Pay attention to any automated CI failures reported in the pull request, and stay involved in the conversation.

GitHub provides additional document on [forking a repository](https://help.github.com/articles/fork-a-repo/) and
[creating a pull request](https://help.github.com/articles/creating-a-pull-request/).

## Finding contributions to work on

Looking at the existing issues is a great way to find something to contribute on. As our projects, by default, use the default GitHub issue labels (enhancement/bug/duplicate/help wanted/invalid/question/wontfix), looking at any 'help wanted' issues is a great place to start.

## Coding Guidelines

### Writing Shell Scripting code

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

### Writing Dockerfiles

* Follow the [Dockerfile best practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
