# sandclaude

My personal, opinionated way to run [Codex](https://developers.openai.com/codex/) or [Claude Code](https://docs.anthropic.com/en/docs/claude-code) in a sandboxed Podman container. The image is tailored to the tools I use on a daily basis — it's not meant to be a generic solution for others, but feel free to fork and adapt it to your own needs.

## Prerequisites

- Podman
- Codex installed and authenticated locally (for reusing your login and configuration)
- Claude Code installed and authenticated locally if you want to use Claude
- `gh` CLI authenticated (optional, for GitHub access inside the container)

## Installation

Clone the repo and make the script executable:

```bash
chmod +x sand
```

Optionally, add it to your PATH:

```bash
sudo ln -s "$(pwd)/sand" /usr/local/bin/sand
```

## Usage

```
sand {codex|claude} [-s] [-b] [-r] [-h] [workspace]
```

### Options

| Flag | Description |
|------|-------------|
| `-s` | Open a bash shell instead of an agent |
| `-b` | Force rebuild of the Docker image |
| `-r` | Resume a previous session for the selected agent |
| `-h` | Show help |

### Arguments

| Argument | Description |
|----------|-------------|
| `workspace` | Path to mount as `/workspace` (default: current directory) |

### Examples

```bash
# Run Codex in the current directory
sand codex

# Run Codex in a specific project
sand codex ~/projects/myapp

# Run Claude Code
sand claude

# Open a shell in the container for debugging
sand codex -s

# Force rebuild the image and resume a Codex session
sand codex -b -r
```

## What's in the container

The Docker image is based on Ubuntu 24.04 and includes:

- Node.js 22
- Go 1.26.1
- Python 3
- GCC cross-compilers (aarch64, arm, mingw-w64)
- GoReleaser
- GitHub CLI (`gh`)
- Jira CLI

## How it works

1. Install and authenticate the agent you want to use locally.
2. The script builds the container image automatically on first run or when the Containerfile changes.
3. Your workspace and agent configuration are mounted into the container.
4. The first argument selects Codex or Claude Code.
5. The container uses the host network so browser-based OAuth callbacks and host VPN routes work.

## License

[Apache License 2.0](LICENSE)
