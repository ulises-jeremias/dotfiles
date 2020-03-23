#!/bin/bash

. ./declares.sh

# any variables you want to use here
# on the left left side is argument label or key (entered at the command line along with it's value) 
# on the right side is the variable name the value of these arguments should be mapped to.
# (the examples above show how these are being passed into this script)
variables["-gu"]="git_user";
variables["--git-user"]="git_user";
variables["-gb"]="git_branch";
variables["--git-branch"]="git_branch";
variables["-dbr"]="db_fqdn";
variables["--db-redirect"]="db_fqdn";
variables["-e"]="environment";
variables["--environment"]="environment";

. ./arguments.sh

# then you could simply use the variables like so:
echo "$git_user";
echo "$git_branch";
echo "$db_fqdn";
echo "$environment";
