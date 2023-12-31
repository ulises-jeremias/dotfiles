Thank you for considering contributing to Dotfiles! We appreciate your interest in improving the project. To ensure a smooth and collaborative contribution process, please review the following guidelines.

## Communication

Before making any changes or submitting a pull request, we recommend discussing your proposed changes with the repository owners. This can be done through creating an issue, sending an email, or any other method of communication that suits you. Engaging in a discussion beforehand helps ensure that your contributions align with the project's goals and guidelines.

Please note that Dotfiles has a [Code of Conduct](https://github.com/ulises-jeremias/dotfiles/blob/master/.github/CODE_OF_CONDUCT.md) that we expect all contributors to adhere to. Kindly follow the code of conduct in all your interactions within the project community.

## Ways to Contribute

You can contribute to Dotfiles in various ways, including:

### Pull Requests

To contribute through a pull request, please follow these steps:

1. Fork the Dotfiles repository to your own GitHub account.
2. Create a new branch for each feature or improvement you plan to work on.
3. Submit a pull request from each feature branch to the **master** branch of the main repository.

It's essential to separate new features or improvements into separate feature branches and submit a pull request for each branch. This allows us to review and merge new contributions individually, ensuring better visibility and management of changes.

## Code Guidelines

When writing code for Dotfiles, please adhere to the following guidelines:

- Follow shell scripting best practices, such as those outlined in [Google's Shell Style Guide](https://google.github.io/styleguide/shell.xml).
- Aim for POSIX compliance to ensure compatibility across different environments.
- Use double quotes around variables (`"${variable}"`) instead of bare variables (`$variable`).
- Use `UPPER_CASE` for constants and global variables, and `lower_case` for other variables.
- Utilize single square brackets (`[ condition ]`) for conditionals, such as in 'if' statements.
- Write clean and readable code, emphasizing clarity and maintainability.
- Add comments where necessary, especially to explain complex functions or provide context.
- Clearly document the arguments that a function accepts (if any).
- Use different error codes when exiting a script and provide explanations for them at the top of the file.
- Include a copyright disclaimer below the shebang line and any other relevant copyright notices when creating new files or making significant changes.
- Limit lines to a maximum of 80 characters for improved readability.
- Name setup scripts as `setup-<function>` without file extensions.
- Use the `.sh` extension for libraries and exclude the shebang line.
- Scripts and libraries should not be executable, as permissions will be set during compilation.
- Validate your code using a shell linter, such as `shellcheck`.
- Test your code before submitting a pull request (unless it's a draft).
- Provide detailed and informative commit messages that accurately describe the changes made.

Thank you for considering these guidelines when contributing to Dotfiles. Your efforts contribute to the project's quality and overall success. Happy coding!
