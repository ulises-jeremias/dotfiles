# Translations

These translations were generated using [bash-i18n](https://github.com/Royal-Linux/bash-i18n) and used with `gettext`.

## Generate locales

```sh
mkdir -p ./locale/dialog/dialog
<path/to/i18n> --module=dialog --project-dir=locale --lang=en
```

## Usage

```sh
TEXTDOMAINDIR=./locale/dialog/dialog/locale
TEXTDOMAIN=dialog
echo $(gettext -s "title") | envsubst
```
