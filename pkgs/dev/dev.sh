if [ -z "$TMUX" ]; then
    # 1. Determine the command string
    if [ $# -eq 0 ]; then
        # No args? Just run nvim
        CMD="nvim"
    else
        # Args exist? Escape them safely
        ARGS=$(printf " %q" "$@")
        CMD="nvim $ARGS"
    fi

    # 2. Create a new detached session (starts your default shell)
    SESSION_ID=$(tmux new-session -d -P)

    # 3. Send the command to the running shell
    tmux send-keys -t "$SESSION_ID" "$CMD" C-m

    # 4. Attach to the session
    tmux attach-session -t "$SESSION_ID"
else
    # Already inside tmux? Just run nvim normally
    nvim "$@"
fi
