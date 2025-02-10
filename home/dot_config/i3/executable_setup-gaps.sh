#!/usr/bin/env bash

# Identify the primary monitor
primary_monitor=$(xrandr --query | grep " primary" | cut -d' ' -f1)

# Gaps settings for the other monitors
other_gaps_inner=12
other_gaps_top=18
other_gaps_right=18
other_gaps_bottom=18
other_gaps_left=18

# Get the list of workspaces and their corresponding outputs
workspaces=$(i3-msg -t get_workspaces | jq -r '.[] | "\(.name) \(.output)"')

# Iterate over the workspaces and their outputs
while IFS= read -r line; do
    workspace_name=$(echo "$line" | awk '{print $1}')
    workspace_output=$(echo "$line" | awk '{print $2}')

    # Apply gaps settings to workspaces that are not on the primary monitor
    if [ "$workspace_output" != "$primary_monitor" ]; then
        i3-msg "workspace $workspace_name"
        i3-msg "gaps inner current set $other_gaps_inner"
        i3-msg "gaps top current set $other_gaps_top"
        i3-msg "gaps right current set $other_gaps_right"
        i3-msg "gaps bottom current set $other_gaps_bottom"
        i3-msg "gaps left current set $other_gaps_left"
    fi
done <<< "$workspaces"
