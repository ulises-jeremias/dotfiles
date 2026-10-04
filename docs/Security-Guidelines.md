# Workstation security guidelines

## Handle secrets carefully

- Keep credentials, private keys, tokens, and personal identity out of tracked
  files. Use the existing chezmoi secret flow for files that genuinely require
  secrets.
- Do not print secret-bearing files into CI logs or support reports.
- Keep SSH private keys restricted to the owning user and use `ssh-agent` or
  an OS keyring rather than copying private material between profiles.
- Review application clipboard history and shell history as sensitive data.

## Keep configuration changes narrow

- Do not run remote scripts during chezmoi template rendering.
- Prefer package-managed updates and signed repositories.
- Avoid adding privileged commands to login hooks. Any system service change
  must be explicit, documented, and independently reviewable.
- Never run validation against the live desktop or personal HOME. Use a
  temporary HOME and isolated XDG directories.

## Report vulnerabilities

Follow the private reporting instructions in the repository's
[Security Policy](../SECURITY.md). Do not open a public issue containing
credentials, exploit details, private machine information, or user data.
