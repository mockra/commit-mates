# commit-mates.nvim

A Neovim plugin to easily add co-authors to git commits using GitHub handles.

## Features

- Fetch GitHub user information automatically
- Add multiple co-authors by handle
- Insert co-author lines into commit messages
- Session-based co-author management

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'mockra/commit-mates',
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use 'mockra/commit-mates'
```

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'mockra/commit-mates'
```

## Usage

### Commands

- `:CommitMates` - Open a floating window to enter a GitHub handle, press Enter to confirm and auto-insert

### Usage

```vim
:CommitMates
```

Type the GitHub handle (with or without @), press Enter, and it will automatically fetch and insert the
co-author line in Git's standard format:

```
Co-authored-by: The Octocat <583231+octocat@users.noreply.github.com>
```

## Configuration

The plugin works out of the box with no configuration needed.

## Requirements

- Neovim 0.5+
- `gh` (GitHub CLI) installed and authenticated
- Internet connection to fetch GitHub user data

## How It Works

1. Opens a floating window for input
2. Queries the GitHub API for user information via `gh` CLI
3. Extracts the user's name and email (or uses noreply email if not public)
4. Automatically inserts a properly formatted `Co-authored-by:` line into your commit message

## License

MIT
