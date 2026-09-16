#!/bin/bash
# Launch the requested agent, then drop to an interactive shell when it exits.
agent="$1"
shift
if [ "$agent" = claude ]; then
    claude --permission-mode auto "$@"
else
    codex --approve-for-me "$@"
fi
exec bash
