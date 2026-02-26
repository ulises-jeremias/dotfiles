#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║              HorneroConfig — Ranger Preview Script (scope.sh)               ║
# ║                                                                              ║
# ║  Generates rich file previews for the ranger preview pane.                   ║
# ║  Each previewer is optional — missing deps degrade gracefully.               ║
# ║                                                                              ║
# ║  Supported previews:                                                         ║
# ║    Code/Text   — syntax highlighted via bat (respects terminal theme)        ║
# ║    Images      — rendered via kitty icat protocol                            ║
# ║    PDFs        — first page rendered as image via pdftoppm                   ║
# ║    Videos      — thumbnail frame via ffmpegthumbnailer                       ║
# ║    Archives    — file listing via atool/bsdtar                               ║
# ║    Markdown    — rendered via glow or bat                                    ║
# ║    JSON/YAML   — pretty-printed via jq/yq or bat                            ║
# ║    Fonts       — displayed via fc-query metadata                             ║
# ║    Torrents    — info via transmission-show                                  ║
# ║    HTML        — rendered via w3m/lynx                                       ║
# ║    OpenDocument— extracted text via odt2txt                                  ║
# ║    SVG         — converted to image via rsvg-convert/inkscape                ║
# ║    Audio       — metadata via mediainfo/exiftool                             ║
# ║    Directories — tree listing via exa/lsd/tree                               ║
# ║                                                                              ║
# ║  Exit codes (ranger protocol):                                               ║
# ║    0 — success, display stdout as text preview                               ║
# ║    1 — no preview available                                                  ║
# ║    2 — plain text fallback                                                   ║
# ║    3 — fix width (not used)                                                  ║
# ║    4 — fix height (not used)                                                 ║
# ║    5 — image preview (display image at $IMAGE_CACHE_PATH)                    ║
# ║    6 — image preview with pager (display image with pager fallback)          ║
# ║    7 — do not cache this preview                                             ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

set -o noclobber -o noglob -o nounset -o pipefail
IFS=$'\n'

# Arguments passed by ranger
FILE_PATH="${1}"          # Full path to the file
PV_WIDTH="${2}"           # Preview pane width (columns)
PV_HEIGHT="${3}"          # Preview pane height (lines)
IMAGE_CACHE_PATH="${4}"   # Path where cached images should be stored
PV_IMAGE_ENABLED="${5}"   # 'True' if image previews are enabled

# File info
FILE_EXTENSION="${FILE_PATH##*.}"
FILE_EXTENSION_LOWER="$(printf "%s" "${FILE_EXTENSION}" | tr '[:upper:]' '[:lower:]')"
MIME_TYPE="$(file --dereference --brief --mime-type -- "${FILE_PATH}" 2>/dev/null)"

# ─── Utility Functions ──────────────────────────────────────────────────────

# Check if a command exists
has() { command -v "$1" >/dev/null 2>&1; }

# Try to generate an image preview — returns exit code 5 if successful
try_image() {
    if [[ "${PV_IMAGE_ENABLED}" == 'True' ]] && [[ -f "${IMAGE_CACHE_PATH}" ]]; then
        return 5
    fi
    return 1
}

# ─── Handle by MIME Type ─────────────────────────────────────────────────────

handle_mime() {
    local mimetype="${MIME_TYPE}"

    case "${mimetype}" in

        # ── Text & Code ──────────────────────────────────────────────────
        text/* | */xml | */json | */csv | */x-ndjson)
            # Special handling for markdown
            if [[ "${FILE_EXTENSION_LOWER}" == "md" ]] || [[ "${FILE_EXTENSION_LOWER}" == "markdown" ]]; then
                if has glow; then
                    glow -s dark -w "${PV_WIDTH}" -- "${FILE_PATH}" && return 0
                fi
            fi

            # Special handling for JSON
            if [[ "${mimetype}" == */json ]] || [[ "${FILE_EXTENSION_LOWER}" == "json" ]]; then
                if has jq; then
                    jq --color-output . "${FILE_PATH}" 2>/dev/null && return 0
                fi
            fi

            # Special handling for YAML/TOML
            if [[ "${FILE_EXTENSION_LOWER}" =~ ^(ya?ml|toml)$ ]]; then
                if has bat; then
                    bat --color=always --style=plain --paging=never \
                        --terminal-width="${PV_WIDTH}" -- "${FILE_PATH}" && return 0
                fi
            fi

            # General text/code: syntax highlighting via bat
            if has bat; then
                bat --color=always --style=plain,numbers --paging=never \
                    --terminal-width="${PV_WIDTH}" \
                    --line-range=":${PV_HEIGHT}" \
                    -- "${FILE_PATH}" && return 0
            elif has highlight; then
                highlight --out-format=ansi --force -- "${FILE_PATH}" && return 0
            elif has cat; then
                cat "${FILE_PATH}" && return 0
            fi
            ;;

        # ── Images ───────────────────────────────────────────────────────
        image/svg+xml | image/svg)
            # SVG: convert to PNG for preview
            if [[ "${PV_IMAGE_ENABLED}" == 'True' ]]; then
                if has rsvg-convert; then
                    rsvg-convert --keep-aspect-ratio --width "${PV_WIDTH}" \
                        "${FILE_PATH}" -o "${IMAGE_CACHE_PATH}.png" 2>/dev/null \
                        && mv "${IMAGE_CACHE_PATH}.png" "${IMAGE_CACHE_PATH}" \
                        && return 5
                elif has inkscape; then
                    inkscape --export-type=png --export-filename="${IMAGE_CACHE_PATH}" \
                        --export-width="${PV_WIDTH}" "${FILE_PATH}" 2>/dev/null \
                        && return 5
                elif has magick; then
                    magick "${FILE_PATH}" -resize "${PV_WIDTH}x" "${IMAGE_CACHE_PATH}" 2>/dev/null \
                        && return 5
                fi
            fi
            # Fallback: show SVG source (it's XML)
            if has bat; then
                bat --color=always --style=plain --language=xml -- "${FILE_PATH}" && return 0
            fi
            ;;

        image/*)
            # Raster images: use kitty's icat or generate thumbnail for cache
            if [[ "${PV_IMAGE_ENABLED}" == 'True' ]]; then
                # For kitty protocol, ranger handles display directly — just provide the path
                local orientation
                orientation="$(identify -format '%[EXIF:Orientation]\n' -- "${FILE_PATH}" 2>/dev/null)"
                if [[ -n "$orientation" ]] && [[ "$orientation" != 1 ]]; then
                    # Auto-rotate based on EXIF orientation
                    if has magick; then
                        magick "${FILE_PATH}" -auto-orient "${IMAGE_CACHE_PATH}" 2>/dev/null && return 5
                    elif has convert; then
                        convert -- "${FILE_PATH}" -auto-orient "${IMAGE_CACHE_PATH}" 2>/dev/null && return 5
                    fi
                fi
                return 5
            fi
            # Fallback: show image metadata
            if has exiftool; then
                exiftool "${FILE_PATH}" && return 0
            elif has mediainfo; then
                mediainfo "${FILE_PATH}" && return 0
            elif has identify; then
                identify -- "${FILE_PATH}" && return 0
            fi
            ;;

        # ── Video ────────────────────────────────────────────────────────
        video/*)
            if [[ "${PV_IMAGE_ENABLED}" == 'True' ]]; then
                if has ffmpegthumbnailer; then
                    ffmpegthumbnailer -i "${FILE_PATH}" -o "${IMAGE_CACHE_PATH}" \
                        -s 0 -q 5 2>/dev/null && return 5
                fi
            fi
            # Fallback: show video metadata
            if has mediainfo; then
                mediainfo "${FILE_PATH}" && return 0
            elif has exiftool; then
                exiftool "${FILE_PATH}" && return 0
            fi
            ;;

        # ── Audio ────────────────────────────────────────────────────────
        audio/*)
            if has mediainfo; then
                mediainfo "${FILE_PATH}" && return 0
            elif has exiftool; then
                exiftool "${FILE_PATH}" && return 0
            fi
            ;;

        # ── PDF ──────────────────────────────────────────────────────────
        application/pdf)
            if [[ "${PV_IMAGE_ENABLED}" == 'True' ]]; then
                if has pdftoppm; then
                    pdftoppm -f 1 -l 1 -scale-to-x "${PV_WIDTH}" -scale-to-y -1 \
                        -singlefile -jpeg -tiffcompression jpeg \
                        -- "${FILE_PATH}" "${IMAGE_CACHE_PATH%.*}" 2>/dev/null \
                        && mv "${IMAGE_CACHE_PATH%.*}.jpg" "${IMAGE_CACHE_PATH}" 2>/dev/null \
                        && return 5
                fi
                if has magick; then
                    magick "${FILE_PATH}[0]" -resize "${PV_WIDTH}x" "${IMAGE_CACHE_PATH}" 2>/dev/null && return 5
                fi
            fi
            # Fallback: extract text
            if has pdftotext; then
                pdftotext -l 10 -nopgbrk -q -- "${FILE_PATH}" - | head -n "${PV_HEIGHT}" && return 0
            fi
            if has mutool; then
                mutool draw -F txt -i -- "${FILE_PATH}" 1-10 2>/dev/null | head -n "${PV_HEIGHT}" && return 0
            fi
            ;;

        # ── Archives ─────────────────────────────────────────────────────
        application/zip | application/x-zip-compressed)
            if has atool; then
                atool --list -- "${FILE_PATH}" && return 0
            elif has unzip; then
                unzip -l -- "${FILE_PATH}" && return 0
            elif has bsdtar; then
                bsdtar --list --file "${FILE_PATH}" && return 0
            fi
            ;;

        application/x-tar | application/gzip | application/x-bzip2 | \
        application/x-xz | application/x-lzma | application/zstd | \
        application/x-compress | application/x-lz4)
            if has atool; then
                atool --list -- "${FILE_PATH}" && return 0
            elif has bsdtar; then
                bsdtar --list --file "${FILE_PATH}" && return 0
            fi
            ;;

        application/x-rar | application/vnd.rar)
            if has atool; then
                atool --list -- "${FILE_PATH}" && return 0
            elif has unrar; then
                unrar l -- "${FILE_PATH}" && return 0
            fi
            ;;

        application/x-7z-compressed)
            if has atool; then
                atool --list -- "${FILE_PATH}" && return 0
            elif has 7z; then
                7z l -- "${FILE_PATH}" && return 0
            fi
            ;;

        # ── OpenDocument ─────────────────────────────────────────────────
        application/vnd.oasis.opendocument.*)
            if has odt2txt; then
                odt2txt "${FILE_PATH}" && return 0
            fi
            if has pandoc; then
                pandoc -s -t plain -- "${FILE_PATH}" && return 0
            fi
            ;;

        # ── Microsoft Office ─────────────────────────────────────────────
        application/vnd.openxmlformats-officedocument.* | \
        application/msword | application/vnd.ms-excel | application/vnd.ms-powerpoint)
            if has pandoc; then
                pandoc -s -t plain -- "${FILE_PATH}" | head -n "${PV_HEIGHT}" && return 0
            fi
            if has catdoc; then
                catdoc -- "${FILE_PATH}" && return 0
            fi
            ;;

        # ── Executables / Shared Libraries ───────────────────────────────
        application/x-executable | application/x-sharedlib | application/x-pie-executable)
            if has readelf; then
                readelf -h -- "${FILE_PATH}" && return 0
            fi
            ;;

        # ── BitTorrent ───────────────────────────────────────────────────
        application/x-bittorrent)
            if has transmission-show; then
                transmission-show -- "${FILE_PATH}" && return 0
            fi
            ;;

        # ── SQLite Databases ─────────────────────────────────────────────
        application/vnd.sqlite3 | application/x-sqlite3)
            if has sqlite3; then
                sqlite3 "${FILE_PATH}" ".tables" 2>/dev/null && return 0
            fi
            ;;

        # ── PGP / GPG ───────────────────────────────────────────────────
        application/pgp-encrypted)
            echo "PGP encrypted file" && return 0
            ;;

    esac

    return 1
}

# ─── Handle by File Extension ────────────────────────────────────────────────

handle_extension() {
    case "${FILE_EXTENSION_LOWER}" in

        # ── Archives (by extension, as a fallback) ───────────────────────
        a | ace | alz | arc | arj | bz | bz2 | cab | cpio | deb | gz | jar | \
        lha | lz | lzh | lzma | lzo | rpm | rz | t7z | tar | tbz | tbz2 | \
        tgz | tlz | txz | tZ | tzo | war | xpi | xz | Z | zip | zst)
            if has atool; then
                atool --list -- "${FILE_PATH}" && return 0
            elif has bsdtar; then
                bsdtar --list --file "${FILE_PATH}" && return 0
            fi
            return 1
            ;;

        # ── PDF (by extension) ───────────────────────────────────────────
        pdf)
            handle_mime
            return $?
            ;;

        # ── BitTorrent ───────────────────────────────────────────────────
        torrent)
            if has transmission-show; then
                transmission-show -- "${FILE_PATH}" && return 0
            fi
            ;;

        # ── HTML ─────────────────────────────────────────────────────────
        htm | html | xhtml)
            if has w3m; then
                w3m -dump "${FILE_PATH}" | head -n "${PV_HEIGHT}" && return 0
            elif has lynx; then
                lynx -dump -- "${FILE_PATH}" | head -n "${PV_HEIGHT}" && return 0
            elif has elinks; then
                elinks -dump 1 "${FILE_PATH}" | head -n "${PV_HEIGHT}" && return 0
            fi
            ;;

        # ── JSON ─────────────────────────────────────────────────────────
        json | jsonl | ndjson)
            if has jq; then
                jq --color-output . "${FILE_PATH}" 2>/dev/null && return 0
            fi
            if has bat; then
                bat --color=always --style=plain --language=json -- "${FILE_PATH}" && return 0
            fi
            ;;

        # ── Markdown ─────────────────────────────────────────────────────
        md | markdown | mkd)
            if has glow; then
                glow -s dark -w "${PV_WIDTH}" -- "${FILE_PATH}" && return 0
            fi
            if has bat; then
                bat --color=always --style=plain --language=markdown -- "${FILE_PATH}" && return 0
            fi
            ;;

        # ── YAML/TOML ───────────────────────────────────────────────────
        yml | yaml | toml)
            if has bat; then
                bat --color=always --style=plain --paging=never \
                    --terminal-width="${PV_WIDTH}" -- "${FILE_PATH}" && return 0
            fi
            ;;

        # ── Fonts ────────────────────────────────────────────────────────
        otf | ttf | woff | woff2)
            if [[ "${PV_IMAGE_ENABLED}" == 'True' ]]; then
                if has magick && has fc-query; then
                    local font_family
                    font_family="$(fc-query -f '%{family}\n' "${FILE_PATH}" 2>/dev/null | head -1)"
                    magick -size "800x400" xc:white \
                        -font "${FILE_PATH}" -pointsize 36 \
                        -fill black -gravity NorthWest \
                        -annotate +20+20 "Font: ${font_family:-Unknown}\n\nABCDEFGHIJKLMNOPQRSTUVWXYZ\nabcdefghijklmnopqrstuvwxyz\n0123456789 !@#$%^&*()\n\nThe quick brown fox jumps\nover the lazy dog." \
                        "${IMAGE_CACHE_PATH}" 2>/dev/null && return 5
                fi
            fi
            if has fc-query; then
                echo "──── Font Information ────"
                fc-query "${FILE_PATH}" 2>/dev/null | head -n 20
                return 0
            fi
            ;;

        # ── Jupyter Notebooks ────────────────────────────────────────────
        ipynb)
            if has jq; then
                jq -r '.cells[] | select(.cell_type=="markdown" or .cell_type=="code") | .cell_type + ": " + (.source | join(""))' \
                    "${FILE_PATH}" 2>/dev/null | head -n "${PV_HEIGHT}" && return 0
            fi
            ;;

        # ── CSV/TSV ──────────────────────────────────────────────────────
        csv | tsv)
            if has bat; then
                bat --color=always --style=plain --language=csv -- "${FILE_PATH}" \
                    | head -n "${PV_HEIGHT}" && return 0
            fi
            column -t -s',' "${FILE_PATH}" 2>/dev/null | head -n "${PV_HEIGHT}" && return 0
            ;;

        # ── Log files ────────────────────────────────────────────────────
        log)
            if has bat; then
                bat --color=always --style=plain --language=log \
                    --line-range=":${PV_HEIGHT}" -- "${FILE_PATH}" && return 0
            fi
            tail -n "${PV_HEIGHT}" "${FILE_PATH}" && return 0
            ;;

    esac

    return 1
}

# ─── Handle Directories ─────────────────────────────────────────────────────

handle_directory() {
    if [[ -d "${FILE_PATH}" ]]; then
        if has exa; then
            exa --tree --level=2 --color=always --icons --group-directories-first \
                "${FILE_PATH}" | head -n "${PV_HEIGHT}" && return 0
        elif has lsd; then
            lsd --tree --depth=2 --color=always --icon=always \
                "${FILE_PATH}" | head -n "${PV_HEIGHT}" && return 0
        elif has tree; then
            tree -C -L 2 --dirsfirst "${FILE_PATH}" | head -n "${PV_HEIGHT}" && return 0
        else
            ls -la --color=always "${FILE_PATH}" | head -n "${PV_HEIGHT}" && return 0
        fi
    fi
    return 1
}

# ─── Fallback ────────────────────────────────────────────────────────────────

handle_fallback() {
    echo "──── File Information ────"
    echo "Name:  $(basename -- "${FILE_PATH}")"
    echo "Type:  ${MIME_TYPE}"
    echo "Size:  $(du -sh -- "${FILE_PATH}" 2>/dev/null | cut -f1)"
    echo ""
    if has file; then
        file --dereference --brief -- "${FILE_PATH}"
    fi
    return 0
}

# ─── Main ────────────────────────────────────────────────────────────────────

# If it's a directory, handle it specially
if [[ -d "${FILE_PATH}" ]]; then
    handle_directory
    exit $?
fi

# Try extension-based detection first (faster), then MIME-based, then fallback
handle_extension
exit_code=$?
[[ $exit_code -ne 1 ]] && exit $exit_code

handle_mime
exit_code=$?
[[ $exit_code -ne 1 ]] && exit $exit_code

handle_fallback
exit $?
