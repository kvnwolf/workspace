set -gx BUN_INSTALL $HOME/.bun
fish_add_path $BUN_INSTALL/bin

abbr -a b 'bun'
abbr -a ba 'bun add'
abbr -a bad 'bun add --dev'
abbr -a bag 'bun add --global'
abbr -a bi 'bun init'
abbr -a bin 'bun install'
abbr -a br 'bun run'
abbr -a brl 'bun run lint'
abbr -a brm 'bun remove'
abbr -a brs 'bun run setup'
abbr -a bru 'bun run update'
abbr -a brun 'bun run unused'
abbr -a brv 'bun run validate'
abbr -a bx 'bunx'
abbr -a sk 'bunx skills@latest'
abbr -a vc 'bunx vercel@latest'