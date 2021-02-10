# Important:
# * Make sure you are using the UTF-8 encoding
# * Don't change the variable names (e.g. intro_msg=)
# * Don't remove any occurrence of (e.g. \n or \n\n - new lines)
# * Don't remove any special characters (e.g. $a, or quotes)
# * Don't edit variables within the text (e.g. /dev/${DRIVE} or ${user})

translate() {
  key="$*"
  gettext -s "$key" | envsubst
}

translate_this() {
  clear
}

translate_this_var() {
  clear
}

dialog_msg() {
  export TEXTDOMAINDIR="${archroyal_directory}"/lang/locale/dialog/dialog/locale
  export TEXTDOMAIN=dialog

  title="$(translate "title")"
  backtitle="$(translate "backtitle")"
}

main_msg() {
  export TEXTDOMAINDIR="${archroyal_directory}"/lang/locale/main/main/locale
  export TEXTDOMAIN=main

  error="$(translate "error")"
  yes="$(translate "yes")"
  no="$(translate "no")"
  ok="$(translate "ok")"
  cancel="$(translate "cancel")"
  other="$(translate "other")"
  default="$(translate "default")"
  edit="$(translate "edit")"
  back="$(translate "back")"
  done_msg="$(translate "done_msg")"
}

export a="\Z2*\Zn"
export h="\Z2<\Z1#\Z2>\Zn"

if "${reload}"; then
  translate_this_var
else
  dialog_msg
  main_msg
  translate_this
fi
