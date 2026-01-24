> **IMPORTANT**: Keep this file updated when making significant changes to the repo structure, conventions, or workflows.

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
2. Custom taps with their brews
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

**conf.d/aliases.fish** - Command replacements:
```fish
alias cat 'bat'
```

Naming patterns: git abbrs = `g*` (gst, gd, gp), directory listing = `l*` (l, la, lf, lt, ltaf3, etc.)

## Configuring Git

Edit `shared/home/.config/git/config`. INI format with tab indentation.

## Configuring GitHub CLI

Edit `shared/home/.config/gh/config.yml`. Add aliases under `aliases:` key.

## Configuring Ghostty

Edit `shared/home/.config/ghostty/config`. Simple `key = value` format.

## Configuring Starship

Edit `shared/home/.config/starship.toml`. TOML format with module sections.

## Configuring Claude CLI

- `shared/home/.claude/settings.json` → model, statusline config
- `shared/home/.claude/CLAUDE.md` → global instructions
- `shared/home/.claude/statusline.sh` → custom statusline script (receives JSON via stdin)

## Syncing Dotfiles

**IMPORTANT**: After creating files in any of the home folders, sync to local machine:

```bash
stow --no-folding -d shared -t ~ home
stow --no-folding -d macos -t ~ home
```

Only needed for **new files** - existing symlinks update automatically.

## Removing Dotfiles

After deleting files from the repo, use `-R` (restow) to remove orphaned symlinks:

```bash
rm -rf shared/home/.config/tool
stow -R --no-folding -d shared -t ~ home
```

The `-R` flag unstows (removes symlinks) then re-stows, so deleted files won't have symlinks recreated.

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

## IMPORTANT: Keeping Documentation Updated

When making changes to this repo, **ALWAYS** update the corresponding documentation **in the same session**:

- `README.md` → User-facing documentation (tools, shortcuts, configurations)
- `CLAUDE.md` → Developer/AI instructions (conventions, workflows)

Examples of when to update:
- Adding/removing/renaming abbreviations or functions → Update README.md shortcuts tables
- Changing naming conventions or patterns → Update CLAUDE.md naming patterns
- Adding new tools or configurations → Update both files as appropriate
- Modifying file structure or workflows → Update CLAUDE.md conventions
