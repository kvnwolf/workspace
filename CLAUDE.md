## Structure

- `macos/home/` → macOS-specific dotfiles
- `shared/home/` → Cross-platform dotfiles
- `macos/Brewfile` → Homebrew packages

Files in `home/` directories mirror `~/` structure and are symlinked via stow.

## Adding Packages

On macOS, first install with Homebrew CLI, then add to Brewfile:

```bash
brew install PACKAGE
# Then add to macos/Brewfile
```

Brewfile organization:
1. Standard brews (alphabetical)
2. Custom taps with their brews/casks
3. Casks (alphabetical)

## Configuring Fish

All Fish config lives in `.config/fish/`.

**conf.d/{tool}.fish** - Tool-specific configuration:
- Abbreviations: `abbr -a gst 'git status'`
- Environment variables: `set -gx VAR value`
- Path additions: `fish_add_path $HOME/.tool/bin`
- Tool initialization: `starship init fish | source`

**conf.d/path.fish** - General PATH additions not related to any specific tool:
```fish
fish_add_path $HOME/.local/bin
```

**functions/{name}.fish** - Reusable functions:
```fish
function name -d "Description"
    # implementation using $argv[1], $argv[2], etc.
end
```

**conf.d/abbrs.fish** - General abbreviations not tied to any specific tool:
```fish
abbr -a md 'mkdir -p'
```

**conf.d/aliases.fish** - Command replacements (tool X replaces tool Y):
```fish
alias cat 'bat'
```

Naming patterns: git abbrs = `g*` (gst, gd, gp), directory listing = `l*` (l, la, lf, lt, ltaf3, etc.)

## Configuring Git

Edit `shared/home/.config/git/config`. INI format with tab indentation.
Edit `shared/home/.config/git/attributes` for diff/merge behavior per file pattern.

## Configuring GitHub CLI

Edit `shared/home/.config/gh/config.yml`. Add aliases under `aliases:` key.

## Configuring Ghostty

Edit `shared/home/.config/ghostty/config`. Simple `key = value` format.

## Configuring Starship

Edit `shared/home/.config/starship.toml`. TOML format with module sections.

## Configuring tmux

Edit `shared/home/.config/tmux/tmux.conf`. Standard tmux config format.

## Configuring Neovim

Edit `shared/home/.config/nvim/`. LazyVim-based. Config in `lua/config/*.lua`, plugins in `lua/plugins/*.lua`. Extras in `init.lua`. Snippets in `snippets/*.json`.

## Configuring Claude CLI

- `shared/home/.claude/CLAUDE.md` → personal global instructions for Claude CLI
- `shared/home/.claude/settings.json` → statusline config, permissions, plugins
- `shared/home/.claude/statusline.sh` → custom statusline script (receives JSON via stdin)
- `shared/home/.claude/hooks/` → PreToolUse hook scripts (bash, executable)
- `shared/home/.claude/skills/` → custom skills (each in its own subdirectory with SKILL.md)

Permissions in `settings.json` `permissions.allow` array must be sorted alphabetically. Group by tool name: `Bash(...)` entries first, then bare tool names (`WebFetch`, `WebSearch`).

Settings key order: `includeCoAuthoredBy` → `permissions` → `statusLine` → `language` → `voiceEnabled` → `skipDangerousModePermissionPrompt`.

## Adopting Local Files

To move an existing local file into the repo:

```bash
# 1. Create directory structure and empty placeholder (required - stow needs it to know what to adopt)
mkdir -p shared/home/.config/tool
touch shared/home/.config/tool/config

# 2. Adopt (moves local file content to repo, replaces local with symlink)
stow --adopt --no-folding -d shared -t ~ home
```

Use `shared/` for cross-platform config, `macos/` for macOS-only.

