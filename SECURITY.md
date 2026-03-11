# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.x.x   | :white_check_mark: |

## Reporting a Vulnerability

To report a security vulnerability, please open a [GitHub Security Advisory](https://github.com/rknell/dart-openai-agent/security/advisories/new) or email the maintainers directly. Do not open a public issue for security vulnerabilities.

## Security Considerations

- **API keys**: Never commit API keys or secrets. Use environment variables (e.g. `DEEPSEEK_API_KEY`, `OPENAI_API_KEY`).
- **Tool callbacks**: `AgentTool` callbacks receive raw LLM output. Validate and sanitize inputs before passing to external systems or shell commands.
- **Dependencies**: Keep `openai_dart` and other dependencies up to date.
