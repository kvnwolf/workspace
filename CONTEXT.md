# Kevin Wolf's Workspace

A personal macOS development environment for installing and maintaining system defaults, tools, and dotfiles with Homebrew and GNU Stow.

## Language

### Dotfile management

**Dotfile**: A version-controlled configuration file mirrored into the home directory.
_Avoid_: "local config" when referring to a file managed by this repository.

**GNU Stow package**: A repository subtree whose contents mirror paths beneath the target home directory.
_Avoid_: "copy" or "installer" for the symlink operation.

**Adopt**: Move an existing local file into a GNU Stow package and replace it with a managed symlink.
_Avoid_: "import" when the operation specifically uses `stow --adopt`.

### Platform scope

**Shared configuration**: Dotfiles under `shared/home/` intended to work across supported operating systems.
_Avoid_: "global configuration", which can imply system-wide scope.

**macOS configuration**: Packages and dotfiles under `macos/` that depend on macOS or Homebrew.
_Avoid_: "shared" for platform-specific settings.

## Relationships

- A **GNU Stow package** contains many **dotfiles** and targets one home directory.
- **Shared configuration** and **macOS configuration** are complementary scopes within the workspace.
- **Adopt** moves one existing local file into the appropriate **GNU Stow package**.

## Flagged ambiguities

None yet.
