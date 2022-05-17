#!/bin/bash

[ "$VERBOSE_SCRIPT" = true ] && echo "Importing bash aliases"

# ------------------------------- alias section ------------------------------ #

# unfuck wifi
alias unfuck_wifi="sudo service NetworkManager restart"

# ---------------------------------------------------------------------------- #

[ "$VERBOSE_SCRIPT" = true ] && echo "All aliases imported"