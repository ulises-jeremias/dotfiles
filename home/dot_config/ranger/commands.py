"""
╔══════════════════════════════════════════════════════════════════════════════╗
║               HorneroConfig — Ranger Custom Commands                        ║
║                                                                              ║
║  Power commands that extend ranger beyond a basic file manager.              ║
║  Each command has a detailed docstring — type :help <command> to learn.      ║
║                                                                              ║
║  Quick Reference:                                                            ║
║    :cheatsheet              — Show all custom keybindings and commands        ║
║    :fzf_select              — Fuzzy file search with live preview (Ctrl-f)   ║
║    :fzf_rga                 — Search inside file contents (Ctrl-g)           ║
║    :compress                — Archive selected files (C)                     ║
║    :extract                 — Extract archives (X)                           ║
║    :mkcd                    — Create directory and enter it                  ║
║    :trash_put               — Safe delete to trash (DD)                      ║
║    :empty_trash             — Permanently empty the trash                    ║
║    :open_in_thunar          — Open current dir in Thunar GUI                 ║
║    :yank_path               — Copy file path to clipboard                   ║
║    :disk_usage              — Show disk usage for current directory          ║
║    :flat                    — Flatten directory view                         ║
║    :git_status              — Show git status for current file/dir           ║
║    :dragon                  — Drag & drop files to GUI apps                  ║
║    :bulkrename              — Rename files using your $EDITOR                ║
╚══════════════════════════════════════════════════════════════════════════════╝
"""

import os
import subprocess
from ranger.api.commands import Command


class cheatsheet(Command):
    """
    :cheatsheet

    Display a comprehensive cheatsheet of all custom keybindings and commands.
    This is your go-to reference when learning ranger.

    Usage:
        :cheatsheet
    """

    CHEATSHEET = """
╔══════════════════════════════════════════════════════════════════════════════════╗
║                         RANGER CHEATSHEET — HorneroConfig                     ║
╠══════════════════════════════════════════════════════════════════════════════════╣
║                                                                                ║
║  ─── NAVIGATION ─────────────────────────────────────────────────────────────  ║
║    h / ←         Go to parent directory                                        ║
║    l / → / Enter Enter directory or open file                                  ║
║    j / ↓         Move down                                                     ║
║    k / ↑         Move up                                                       ║
║    gg            Go to top of file list                                         ║
║    G             Go to bottom of file list                                      ║
║    J / Ctrl-D    Page half-down (fast scroll)                                  ║
║    K / Ctrl-U    Page half-up (fast scroll)                                    ║
║    H             Go back in history (like browser back)                        ║
║    L             Go forward in history                                          ║
║    ~             Toggle miller/multipane view                                  ║
║                                                                                ║
║  ─── QUICK DIRECTORIES (g + key) ────────────────────────────────────────────  ║
║    gh  Home (~)              gp  ~/Projects                                    ║
║    gd  ~/Downloads           gD  ~/Documents                                   ║
║    gP  ~/Pictures            gm  ~/Music                                       ║
║    gv  ~/Videos              gc  ~/.config                                     ║
║    gl  ~/.local/share        gr  Rices directory                               ║
║    gw  Wallpapers            gb  ~/.local/bin (scripts)                        ║
║    gT  /tmp                  g/  Root (/)                                      ║
║                                                                                ║
║  ─── FILE OPERATIONS ────────────────────────────────────────────────────────  ║
║    Space         Mark/unmark file                                              ║
║    v             Mark/unmark all                                               ║
║    V             Visual selection mode (like vim)                              ║
║    yy            Copy (yank) selected files                                    ║
║    dd            Cut selected files                                            ║
║    pp            Paste copied/cut files                                        ║
║    po            Paste and overwrite                                           ║
║    pl            Paste as symlink                                              ║
║    DD            Safe delete → TRASH (recommended!)                            ║
║    dD            Permanent delete (asks confirmation)                          ║
║    cw            Rename file / bulk rename (if files marked)                   ║
║    a             Rename (append to name)                                       ║
║    A             Rename (full path editable)                                   ║
║    I             Rename (cursor at beginning)                                  ║
║                                                                                ║
║  ─── CLIPBOARD (yank to Wayland clipboard) ──────────────────────────────────  ║
║    yp            Copy full file path                                           ║
║    yd            Copy directory path                                           ║
║    yn            Copy filename                                                 ║
║    y.            Copy filename without extension                               ║
║                                                                                ║
║  ─── POWER COMMANDS ────────────────────────────────────────────────────────   ║
║    Ctrl-f        Fuzzy file search (fzf) with preview                         ║
║    Ctrl-g        Search INSIDE files (ripgrep + fzf)                          ║
║    C             Compress selected files (choose format)                       ║
║    X             Extract archive (auto-detects format)                         ║
║    Alt-t         Open current dir in Thunar                                    ║
║    :mkcd NAME    Create directory and enter it                                 ║
║    :flat N       Flatten view N levels deep                                    ║
║    :dragon       Drag & drop files to other apps                               ║
║    :disk_usage   Show disk usage breakdown                                     ║
║    :git_status   Show git diff/status                                          ║
║                                                                                ║
║  ─── SEARCHING & FILTERING ──────────────────────────────────────────────────  ║
║    /             Search (regex)                                                ║
║    n / N         Next / previous search result                                 ║
║    .d            Filter: show only directories                                 ║
║    .f            Filter: show only files                                       ║
║    .n            Filter: by name pattern                                       ║
║    .c            Clear all filters                                             ║
║                                                                                ║
║  ─── SORTING (o + key) ─────────────────────────────────────────────────────   ║
║    os/oS         Sort by size (normal/reverse)                                 ║
║    on/oN         Sort by name (normal/reverse)                                 ║
║    om/oM         Sort by modification time (normal/reverse)                    ║
║    ot/oT         Sort by type (normal/reverse)                                 ║
║    oe/oE         Sort by extension (normal/reverse)                            ║
║    or            Toggle reverse sort                                           ║
║                                                                                ║
║  ─── TABS ───────────────────────────────────────────────────────────────────  ║
║    Ctrl-n        New tab                                                       ║
║    Ctrl-w        Close tab                                                     ║
║    Tab / S-Tab   Switch tabs                                                   ║
║    Alt-1..9      Jump to tab by number                                         ║
║                                                                                ║
║  ─── TOGGLES (z + key) ──────────────────────────────────────────────────────  ║
║    zh            Toggle hidden files                                           ║
║    zp            Toggle file previews                                          ║
║    zi            Toggle image previews                                         ║
║    zm            Toggle mouse support                                          ║
║                                                                                ║
║  ─── BOOKMARKS ──────────────────────────────────────────────────────────────  ║
║    m<key>        Set bookmark                                                  ║
║    `<key>        Go to bookmark                                                ║
║    um<key>       Delete bookmark                                               ║
║                                                                                ║
║  ─── HELP ───────────────────────────────────────────────────────────────────  ║
║    ?             Built-in help                                                 ║
║    :cheatsheet   This cheatsheet                                               ║
║    :help CMD     Help for a specific command                                   ║
║    W             View ranger log                                               ║
║                                                                                ║
╚══════════════════════════════════════════════════════════════════════════════════╝
"""

    def execute(self):
        self.fm.notify(self.CHEATSHEET, bad=False)
        # Also display in pager for better readability
        pager = self.fm.ui.open_pager()
        pager.set_source(self.CHEATSHEET.split('\n'))
        pager.move(to=0)


class fzf_select(Command):
    """
    :fzf_select

    Fuzzy search for files and directories using fzf with a live preview.
    Navigate to the selected file or directory.

    Keybinding: Ctrl-f

    Features:
        - Searches recursively from current directory
        - Live preview of files (syntax highlighted)
        - Respects .gitignore if in a git repo
        - Hidden files included

    Requirements:
        - fzf (fuzzy finder)
        - bat (optional, for preview highlighting)
    """

    def execute(self):
        import subprocess

        # Build fzf command with preview
        preview_cmd = "bat --color=always --style=plain --line-range=:50 {} 2>/dev/null || head -50 {}"

        fzf_cmd = [
            "fzf",
            "--preview", preview_cmd,
            "--preview-window", "right:50%:wrap",
            "--height", "80%",
            "--layout", "reverse",
            "--border", "rounded",
            "--prompt", " Find: ",
            "--header", "Ctrl-f: Fuzzy File Search | ESC to cancel",
            "--ansi",
        ]

        # Use fd if available (faster, respects .gitignore), else find
        if subprocess.run(["which", "fd"], capture_output=True).returncode == 0:
            find_cmd = "fd --hidden --follow --exclude .git --color=never"
        else:
            find_cmd = "find . -type f -o -type d 2>/dev/null | sed 's|^\\./||'"

        try:
            proc = subprocess.Popen(
                f"{find_cmd} | {' '.join(fzf_cmd)}",
                shell=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                cwd=self.fm.thisdir.path,
            )
            stdout, _ = proc.communicate()

            if proc.returncode == 0 and stdout:
                selected = stdout.decode("utf-8").strip()
                if selected:
                    fzf_file = os.path.join(self.fm.thisdir.path, selected)
                    if os.path.isdir(fzf_file):
                        self.fm.cd(fzf_file)
                    else:
                        self.fm.select_file(fzf_file)
        except Exception as e:
            self.fm.notify(f"fzf error: {e}", bad=True)


class fzf_rga(Command):
    """
    :fzf_rga

    Search inside file CONTENTS using ripgrep + fzf.
    Finds text inside files (not just filenames) and navigates to the match.

    Keybinding: Ctrl-g

    Features:
        - Searches inside all text-based files
        - Live preview with context around the match
        - Select a result to jump to that file

    Requirements:
        - ripgrep (rg)
        - fzf
    """

    def execute(self):
        import subprocess

        rg_cmd = 'rg --color=always --line-number --no-heading --smart-case ""'
        fzf_cmd = (
            "fzf --ansi --layout=reverse --border=rounded "
            "--prompt=' Content Search: ' "
            "--header='Ctrl-g: Search Inside Files | ESC to cancel' "
            "--delimiter=: "
            "--preview='bat --color=always --style=plain --highlight-line={2} {1} 2>/dev/null || head -50 {1}' "
            "--preview-window='right:50%:wrap:+{2}-10'"
        )

        try:
            proc = subprocess.Popen(
                f"{rg_cmd} | {fzf_cmd}",
                shell=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                cwd=self.fm.thisdir.path,
            )
            stdout, _ = proc.communicate()

            if proc.returncode == 0 and stdout:
                result = stdout.decode("utf-8").strip()
                if result:
                    # ripgrep output format: filename:line:content
                    parts = result.split(":")
                    if len(parts) >= 1:
                        filepath = os.path.join(self.fm.thisdir.path, parts[0])
                        if os.path.exists(filepath):
                            self.fm.select_file(filepath)
        except Exception as e:
            self.fm.notify(f"ripgrep search error: {e}", bad=True)


class compress(Command):
    """
    :compress <filename.ext>

    Compress selected files into an archive. Format is auto-detected from extension.

    Keybinding: C

    Usage:
        :compress archive.zip      — ZIP archive
        :compress archive.tar.gz   — Gzipped tar
        :compress archive.tar.xz   — XZ compressed tar
        :compress archive.7z       — 7-Zip archive

    If no filename is given, prompts for one with tab completion for extensions.
    """

    def execute(self):
        cwd = self.fm.thisdir
        marked_files = cwd.get_selection()

        if not marked_files:
            self.fm.notify("No files selected for compression", bad=True)
            return

        parts = self.line.split(maxsplit=1)
        if len(parts) < 2:
            # Prompt user
            self.fm.notify("Usage: :compress <filename.ext>  (e.g., archive.tar.gz)", bad=True)
            return

        archive_name = parts[1]
        files = " ".join(f"'{f.relative_path}'" for f in marked_files)

        # Detect format from extension
        if archive_name.endswith(".tar.gz") or archive_name.endswith(".tgz"):
            cmd = f"tar czf '{archive_name}' {files}"
        elif archive_name.endswith(".tar.xz") or archive_name.endswith(".txz"):
            cmd = f"tar cJf '{archive_name}' {files}"
        elif archive_name.endswith(".tar.bz2") or archive_name.endswith(".tbz2"):
            cmd = f"tar cjf '{archive_name}' {files}"
        elif archive_name.endswith(".tar.zst"):
            cmd = f"tar --zstd -cf '{archive_name}' {files}"
        elif archive_name.endswith(".tar"):
            cmd = f"tar cf '{archive_name}' {files}"
        elif archive_name.endswith(".zip"):
            cmd = f"zip -r '{archive_name}' {files}"
        elif archive_name.endswith(".7z"):
            cmd = f"7z a '{archive_name}' {files}"
        elif archive_name.endswith(".rar"):
            cmd = f"rar a '{archive_name}' {files}"
        else:
            # Default to tar.gz
            archive_name += ".tar.gz"
            cmd = f"tar czf '{archive_name}' {files}"

        self.fm.execute_console(f"shell {cmd}")
        self.fm.notify(f"Compressing to {archive_name}...")

    def tab(self, tabnum):
        """Tab completion for archive extension."""
        extensions = [".tar.gz", ".tar.xz", ".tar.bz2", ".tar.zst", ".zip", ".7z"]
        parts = self.line.split(maxsplit=1)
        if len(parts) > 1:
            name = parts[1]
            return [f"compress {name}{ext}" for ext in extensions if not any(name.endswith(e) for e in extensions)]
        return [f"compress archive{ext}" for ext in extensions]


class extract(Command):
    """
    :extract [destination]

    Extract the current archive to a directory. Auto-detects format.

    Keybinding: X

    Usage:
        :extract           — Extract to current directory
        :extract mydir     — Extract to 'mydir/'

    Supported formats:
        .tar.gz, .tgz, .tar.xz, .tar.bz2, .zip, .rar, .7z, .gz, .xz, .bz2, .zst
    """

    def execute(self):
        cwd = self.fm.thisdir
        file = self.fm.thisfile

        if not file:
            self.fm.notify("No file selected", bad=True)
            return

        filepath = file.path
        parts = self.line.split(maxsplit=1)
        dest = parts[1] if len(parts) > 1 else ""

        # Create destination directory if specified
        if dest:
            dest_path = os.path.join(cwd.path, dest)
            os.makedirs(dest_path, exist_ok=True)
        else:
            dest_path = cwd.path

        # Try atool first (handles everything)
        atool_available = subprocess.run(
            ["which", "atool"], capture_output=True
        ).returncode == 0

        if atool_available:
            cmd = f"cd '{dest_path}' && atool -x '{filepath}'"
        else:
            # Manual extraction based on extension
            name = os.path.basename(filepath).lower()
            if name.endswith((".tar.gz", ".tgz")):
                cmd = f"tar xzf '{filepath}' -C '{dest_path}'"
            elif name.endswith((".tar.xz", ".txz")):
                cmd = f"tar xJf '{filepath}' -C '{dest_path}'"
            elif name.endswith((".tar.bz2", ".tbz2")):
                cmd = f"tar xjf '{filepath}' -C '{dest_path}'"
            elif name.endswith(".tar.zst"):
                cmd = f"tar --zstd -xf '{filepath}' -C '{dest_path}'"
            elif name.endswith(".tar"):
                cmd = f"tar xf '{filepath}' -C '{dest_path}'"
            elif name.endswith(".zip"):
                cmd = f"unzip -o '{filepath}' -d '{dest_path}'"
            elif name.endswith(".rar"):
                cmd = f"unrar x '{filepath}' '{dest_path}/'"
            elif name.endswith(".7z"):
                cmd = f"7z x '{filepath}' -o'{dest_path}'"
            elif name.endswith(".gz"):
                cmd = f"gunzip -k '{filepath}'"
            elif name.endswith(".xz"):
                cmd = f"unxz -k '{filepath}'"
            elif name.endswith(".bz2"):
                cmd = f"bunzip2 -k '{filepath}'"
            else:
                self.fm.notify(f"Unknown archive format: {name}", bad=True)
                return

        self.fm.execute_console(f"shell {cmd}")
        self.fm.notify(f"Extracting {os.path.basename(filepath)}...")


class mkcd(Command):
    """
    :mkcd <dirname>

    Create a new directory and immediately enter it.
    Supports creating nested directories (like mkdir -p).

    Usage:
        :mkcd projects/new-app
    """

    def execute(self):
        parts = self.line.split(maxsplit=1)
        if len(parts) < 2:
            self.fm.notify("Usage: :mkcd <dirname>", bad=True)
            return

        dirname = parts[1]
        dirpath = os.path.join(self.fm.thisdir.path, dirname)

        try:
            os.makedirs(dirpath, exist_ok=True)
            self.fm.cd(dirpath)
            self.fm.notify(f"Created and entered: {dirname}")
        except OSError as e:
            self.fm.notify(f"Error creating directory: {e}", bad=True)


class trash_put(Command):
    """
    :trash_put

    Move selected files to the system trash using trash-cli.
    Much safer than permanent deletion — files can be restored.

    Keybinding: DD

    Related commands:
        :shell trash-list     — List trashed files
        :shell trash-restore  — Restore trashed files
        :empty_trash          — Permanently empty the trash
    """

    def execute(self):
        import shlex

        selected = self.fm.thistab.get_selection()
        if not selected:
            self.fm.notify("No files selected", bad=True)
            return

        # Check if trash-put is available
        if subprocess.run(["which", "trash-put"], capture_output=True).returncode != 0:
            self.fm.notify("trash-cli not installed. Install: yay -S trash-cli", bad=True)
            return

        file_list = " ".join(shlex.quote(f.path) for f in selected)
        self.fm.execute_console(f"shell -s trash-put -- {file_list}")
        self.fm.notify(f"Trashed {len(selected)} file(s)")


class empty_trash(Command):
    """
    :empty_trash

    Permanently empty the system trash. This action is IRREVERSIBLE.
    """

    def execute(self):
        self.fm.execute_console("shell -w trash-empty")


class open_in_thunar(Command):
    """
    :open_in_thunar

    Open the current directory in Thunar (GUI file manager).
    Useful when you need GUI features like drag-and-drop.

    Usage:
        :open_in_thunar
    """

    def execute(self):
        self.fm.execute_console(f"shell -f thunar '{self.fm.thisdir.path}' &")


class flat(Command):
    """
    :flat [level]

    Flatten the directory view to show files from subdirectories.
    Like Thunar's "show all files recursively" feature.

    Usage:
        :flat      — Toggle off (show normal view)
        :flat 1    — Show files 1 level deep
        :flat 2    — Show files 2 levels deep
        :flat -1   — Show ALL files recursively (use with caution!)
    """

    def execute(self):
        parts = self.line.split(maxsplit=1)
        level = int(parts[1]) if len(parts) > 1 else 0
        self.fm.thisdir.flat = level
        self.fm.thisdir.load_content()


class disk_usage(Command):
    """
    :disk_usage

    Show disk usage breakdown for the current directory.
    Like a quick ncdu summary.

    Usage:
        :disk_usage
    """

    def execute(self):
        self.fm.execute_console(
            "shell -p du --max-depth=1 -h --apparent-size | sort -rh | head -30"
        )


class git_status(Command):
    """
    :git_status

    Show git status / diff for the current file or directory.

    Usage:
        :git_status
    """

    def execute(self):
        path = self.fm.thisfile.path if self.fm.thisfile else self.fm.thisdir.path
        if os.path.isfile(path):
            self.fm.execute_console(f"shell -p git diff --color=always '{path}'")
        else:
            self.fm.execute_console("shell -p git status --short")


class dragon(Command):
    """
    :dragon

    Drag and drop selected files FROM ranger TO GUI applications.
    Uses dragon-drop (Wayland-compatible).

    Example: Select files in ranger, run :dragon, then drop them into
    a browser upload dialog, email composer, etc.

    Requirements:
        - dragon-drop (AUR: dragon-drop-git)
    """

    def execute(self):
        selected = self.fm.thistab.get_selection()
        if not selected:
            self.fm.notify("No files selected for drag & drop", bad=True)
            return

        import shlex

        files = " ".join(shlex.quote(f.path) for f in selected)
        self.fm.execute_console(f"shell -f dragon-drop --and-exit {files}")


class yank_path(Command):
    """
    :yank_path [mode]

    Copy file path/name to the Wayland clipboard.

    Usage:
        :yank_path         — Copy full path
        :yank_path dir     — Copy directory path
        :yank_path name    — Copy filename only
    """

    def execute(self):
        parts = self.line.split(maxsplit=1)
        mode = parts[1] if len(parts) > 1 else "path"

        if mode == "dir":
            text = self.fm.thisdir.path
        elif mode == "name":
            text = self.fm.thisfile.relative_path if self.fm.thisfile else ""
        else:
            text = self.fm.thisfile.path if self.fm.thisfile else self.fm.thisdir.path

        try:
            subprocess.run(
                ["wl-copy"],
                input=text.encode(),
                check=True,
                capture_output=True,
            )
            self.fm.notify(f"Copied: {text}")
        except (subprocess.CalledProcessError, FileNotFoundError):
            try:
                subprocess.run(
                    ["xclip", "-selection", "clipboard"],
                    input=text.encode(),
                    check=True,
                    capture_output=True,
                )
                self.fm.notify(f"Copied: {text}")
            except (subprocess.CalledProcessError, FileNotFoundError):
                self.fm.notify("Neither wl-copy nor xclip found", bad=True)


class bulkrename(Command):
    """
    :bulkrename

    Rename multiple files using your $EDITOR.
    More powerful than Thunar's bulk rename — full regex support via your editor.

    Usage:
        1. Mark files with Space
        2. Run :bulkrename
        3. Edit filenames in your editor
        4. Save and close — renames are applied

    Keybinding: cw (when files are marked)
    """

    def execute(self):
        import tempfile

        selected = self.fm.thistab.get_selection()
        if not selected:
            self.fm.notify("Mark files with Space first, then run :bulkrename", bad=True)
            return

        filenames = [f.relative_path for f in selected]

        # Create temp file with current filenames
        with tempfile.NamedTemporaryFile(mode='w', suffix='.txt', delete=False, prefix='ranger_bulk_') as tmp:
            tmp.write('\n'.join(filenames) + '\n')
            tmp_path = tmp.name

        # Open in editor
        editor = os.environ.get('EDITOR', 'vim')
        self.fm.execute_console(f"shell -w {editor} {tmp_path}")

        # Read new filenames
        try:
            with open(tmp_path) as f:
                new_names = [line.strip() for line in f.readlines() if line.strip()]

            if len(new_names) != len(filenames):
                self.fm.notify(
                    f"Error: expected {len(filenames)} names, got {len(new_names)}",
                    bad=True
                )
                return

            # Perform renames
            renamed = 0
            for old, new in zip(filenames, new_names):
                if old != new:
                    old_path = os.path.join(self.fm.thisdir.path, old)
                    new_path = os.path.join(self.fm.thisdir.path, new)
                    try:
                        os.rename(old_path, new_path)
                        renamed += 1
                    except OSError as e:
                        self.fm.notify(f"Error renaming {old}: {e}", bad=True)

            if renamed:
                self.fm.notify(f"Renamed {renamed} file(s)")
                self.fm.thisdir.load_content()
        finally:
            os.unlink(tmp_path)
