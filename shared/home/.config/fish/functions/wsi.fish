function wsi -d "Run Claude in workspace directory (interactive)"
    set -l cwd $PWD
    builtin cd $WORKSPACE_SETUP_DIR
    claude $argv
    builtin cd $cwd
end
