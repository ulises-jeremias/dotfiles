-- Lua port of the retired hyprland.conf.d/keybindings.conf.
-- Generated 1:1 from the legacy binds (139 lines) against the
-- Hyprland v0.56.2 hl.dsp API; categories mirror the legacy
-- `# ===` headers so `horneroctl hardware keyboard keys` reads
-- the same structure in both formats.
-- luacheck: globals hl

-- ============================================================================
-- Keybindings Configuration
-- ============================================================================
--
-- Mod key: SUPER (Windows key)
-- Use hyprctl to execute commands
-- ============================================================================
-- ============================================================================
-- Essential Applications
-- ============================================================================
-- Terminal
hl.bind("SUPER + Return", hl.dsp.exec_cmd("exo-open --launch TerminalEmulator"))
hl.bind("SUPER + T", hl.dsp.exec_cmd("exo-open --launch TerminalEmulator"))
-- Application launcher
hl.bind("CTRL + Space", hl.dsp.exec_cmd("horneroctl apps launch"))
-- Clipboard manager
hl.bind("SUPER + V", hl.dsp.exec_cmd("horneroctl capture clipboard"))
-- File manager (GUI)
hl.bind("SUPER + F", hl.dsp.exec_cmd("exo-open --launch FileManager"))
-- File manager (terminal — yazi)
hl.bind("SUPER + E", hl.dsp.exec_cmd("horneroctl apps terminal-file --new-window --last-dir"))
-- Web browser
hl.bind("SUPER + W", hl.dsp.exec_cmd("exo-open --launch WebBrowser"))
-- Dashboard (Quickshell)
hl.bind("SUPER + D", hl.dsp.exec_cmd("horneroctl shell ipc -- call drawers toggle dashboard"))
-- Shell layout picker (Quickshell)
hl.bind("SUPER + SHIFT + B", hl.dsp.exec_cmd("horneroctl shell ipc -- call drawers toggle layoutPicker"))
-- Power menu (session drawer)
hl.bind("SUPER + X", hl.dsp.exec_cmd("horneroctl shell ipc -- call drawers toggle session"))
-- Lock screen
hl.bind("SUPER + L", hl.dsp.exec_cmd("horneroctl shell ipc -- call lock lock"))
-- Keyboard shortcuts help overlay
hl.bind("SUPER + question", hl.dsp.exec_cmd("horneroctl hardware keyboard keys"))
hl.bind("SUPER + slash", hl.dsp.exec_cmd("horneroctl hardware keyboard keys"))
-- Interactive gaps management (like i3-gaps)
hl.bind("SUPER + SHIFT + G", hl.dsp.exec_cmd("~/.config/hypr/scripts/gaps-interactive.sh"))
-- Toggle keyboard layout through the current Hornero action.
-- bind = ALT SHIFT, Space, exec, horneroctl hardware keyboard layout --yes
-- ============================================================================
-- Window Management
-- ============================================================================
-- Close active window
hl.bind("SUPER + SHIFT + Q", hl.dsp.window.kill())
hl.bind("ALT + Q", hl.dsp.window.kill())
hl.bind("ALT + F4", hl.dsp.window.kill())
-- Toggle floating
hl.bind("SUPER + Space", hl.dsp.window.float())
-- Toggle fullscreen
hl.bind("SUPER + M", hl.dsp.window.fullscreen())
-- Toggle maximize
hl.bind("SUPER + SHIFT + M", hl.dsp.window.fullscreen({ mode = "maximized" }))
-- Promote focused window into its own column (scrolling)
hl.bind("SUPER + U", hl.dsp.layout("promote"))
-- Toggle focus fit behavior (center <-> fit) for scrolling layout
hl.bind("SUPER + apostrophe", hl.dsp.layout("togglefit"))
-- Layout profile switching (persisted via horneroctl hypr layout set)
hl.bind("SUPER + CTRL + W", hl.dsp.exec_cmd("horneroctl hypr layout toggle --yes"))
hl.bind("SUPER + CTRL + SHIFT + W", hl.dsp.exec_cmd("horneroctl hypr layout set scrolling --yes"))
hl.bind("SUPER + CTRL + ALT + W", hl.dsp.exec_cmd("horneroctl hypr layout set dwindle --yes"))
-- Pin window (keep on all workspaces)
hl.bind("SUPER + SHIFT + P", hl.dsp.window.pin())
-- Focus mode toggle (floating <-> tiled)
hl.bind("SUPER + SHIFT + Space", hl.dsp.focus({ last = true }))
-- Window switcher (snappy-switcher)
hl.bind("ALT + Tab", hl.dsp.exec_cmd("horneroctl apps switcher next --yes"))
hl.bind("ALT + SHIFT + Tab", hl.dsp.exec_cmd("horneroctl apps switcher prev --yes"))
-- Smart floating (float + center + resize with optimal size)
hl.bind("SUPER + SHIFT + F", hl.dsp.exec_cmd("~/.config/hypr/scripts/smart-float.sh"))
-- Move window to center
hl.bind("SUPER + CTRL + C", hl.dsp.window.center())
-- Focus parent (using changegroupactive as alternative)
hl.bind("SUPER + P", hl.dsp.group.next())
-- Focus child
hl.bind("SUPER + C", hl.dsp.group.prev())
-- ============================================================================
-- Focus Movement (Vim-like)
-- ============================================================================
hl.bind("SUPER + left", hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + right", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + up", hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + down", hl.dsp.focus({ direction = "down" }))
hl.bind("SUPER + H", hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + L", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + K", hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + J", hl.dsp.focus({ direction = "down" }))
-- ============================================================================
-- Scrolling Layout Navigation (Niri-like)
-- ============================================================================
-- Move viewport by columns
hl.bind("SUPER + ALT + H", hl.dsp.layout("move -col"))
hl.bind("SUPER + ALT + L", hl.dsp.layout("move +col"))
-- Swap active column with neighbor
hl.bind("SUPER + ALT + comma", hl.dsp.layout("swapcol l"))
hl.bind("SUPER + ALT + period", hl.dsp.layout("swapcol r"))
-- Column width controls
hl.bind("SUPER + ALT + minus", hl.dsp.layout("colresize -conf"))
hl.bind("SUPER + ALT + equal", hl.dsp.layout("colresize +conf"))
hl.bind("SUPER + ALT + SHIFT + minus", hl.dsp.layout("colresize -0.05"), { repeating = true })
hl.bind("SUPER + ALT + SHIFT + equal", hl.dsp.layout("colresize +0.05"), { repeating = true })
-- Fit strategies
hl.bind("SUPER + ALT + F", hl.dsp.layout("fit active"))
hl.bind("SUPER + ALT + SHIFT + F", hl.dsp.layout("fit visible"))
-- ============================================================================
-- Window Movement
-- ============================================================================
hl.bind("SUPER + SHIFT + left", hl.dsp.window.move({ direction = "left" }))
hl.bind("SUPER + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind("SUPER + SHIFT + up", hl.dsp.window.move({ direction = "up" }))
hl.bind("SUPER + SHIFT + down", hl.dsp.window.move({ direction = "down" }))
hl.bind("SUPER + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind("SUPER + SHIFT + L", hl.dsp.window.move({ direction = "right" }))
hl.bind("SUPER + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind("SUPER + SHIFT + J", hl.dsp.window.move({ direction = "down" }))
-- ============================================================================
-- Window Resizing
-- ============================================================================
-- Resize mode with submap
hl.bind("SUPER + R", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
	hl.bind("right", hl.dsp.window.resize({ x = 40, y = 0, relative = true }), { repeating = true })
	hl.bind("left", hl.dsp.window.resize({ x = -40, y = 0, relative = true }), { repeating = true })
	hl.bind("up", hl.dsp.window.resize({ x = 0, y = -40, relative = true }), { repeating = true })
	hl.bind("down", hl.dsp.window.resize({ x = 0, y = 40, relative = true }), { repeating = true })
	hl.bind("L", hl.dsp.window.resize({ x = 40, y = 0, relative = true }), { repeating = true })
	hl.bind("H", hl.dsp.window.resize({ x = -40, y = 0, relative = true }), { repeating = true })
	hl.bind("K", hl.dsp.window.resize({ x = 0, y = -40, relative = true }), { repeating = true })
	hl.bind("J", hl.dsp.window.resize({ x = 0, y = 40, relative = true }), { repeating = true })
	hl.bind("escape", hl.dsp.submap("reset"))
	hl.bind("Return", hl.dsp.submap("reset"))
end)

-- Direct resize with CTRL
hl.bind("SUPER + CTRL + left", hl.dsp.window.resize({ x = -40, y = 0, relative = true }), { repeating = true })
hl.bind("SUPER + CTRL + right", hl.dsp.window.resize({ x = 40, y = 0, relative = true }), { repeating = true })
hl.bind("SUPER + CTRL + up", hl.dsp.window.resize({ x = 0, y = -40, relative = true }), { repeating = true })
hl.bind("SUPER + CTRL + down", hl.dsp.window.resize({ x = 0, y = 40, relative = true }), { repeating = true })
hl.bind("SUPER + CTRL + H", hl.dsp.window.resize({ x = -40, y = 0, relative = true }), { repeating = true })
hl.bind("SUPER + CTRL + L", hl.dsp.window.resize({ x = 40, y = 0, relative = true }), { repeating = true })
hl.bind("SUPER + CTRL + K", hl.dsp.window.resize({ x = 0, y = -40, relative = true }), { repeating = true })
hl.bind("SUPER + CTRL + J", hl.dsp.window.resize({ x = 0, y = 40, relative = true }), { repeating = true })
-- ============================================================================
-- Workspace Management
-- ============================================================================
-- Switch to workspace
hl.bind("SUPER + 1", hl.dsp.focus({ workspace = "1" }))
hl.bind("SUPER + 2", hl.dsp.focus({ workspace = "2" }))
hl.bind("SUPER + 3", hl.dsp.focus({ workspace = "3" }))
hl.bind("SUPER + 4", hl.dsp.focus({ workspace = "4" }))
hl.bind("SUPER + 5", hl.dsp.focus({ workspace = "5" }))
hl.bind("SUPER + 6", hl.dsp.focus({ workspace = "6" }))
hl.bind("SUPER + 7", hl.dsp.focus({ workspace = "7" }))
hl.bind("SUPER + 8", hl.dsp.focus({ workspace = "8" }))
hl.bind("SUPER + 9", hl.dsp.focus({ workspace = "9" }))
hl.bind("SUPER + 0", hl.dsp.focus({ workspace = "10" }))
-- Move window to workspace
hl.bind("SUPER + SHIFT + 1", hl.dsp.window.move({ workspace = "1" }))
hl.bind("SUPER + SHIFT + 2", hl.dsp.window.move({ workspace = "2" }))
hl.bind("SUPER + SHIFT + 3", hl.dsp.window.move({ workspace = "3" }))
hl.bind("SUPER + SHIFT + 4", hl.dsp.window.move({ workspace = "4" }))
hl.bind("SUPER + SHIFT + 5", hl.dsp.window.move({ workspace = "5" }))
hl.bind("SUPER + SHIFT + 6", hl.dsp.window.move({ workspace = "6" }))
hl.bind("SUPER + SHIFT + 7", hl.dsp.window.move({ workspace = "7" }))
hl.bind("SUPER + SHIFT + 8", hl.dsp.window.move({ workspace = "8" }))
hl.bind("SUPER + SHIFT + 9", hl.dsp.window.move({ workspace = "9" }))
hl.bind("SUPER + SHIFT + 0", hl.dsp.window.move({ workspace = "10" }))
-- Move window to workspace silently (don't switch)
hl.bind("SUPER + CTRL + SHIFT + 1", hl.dsp.window.move({ workspace = "1", follow = false }))
hl.bind("SUPER + CTRL + SHIFT + 2", hl.dsp.window.move({ workspace = "2", follow = false }))
hl.bind("SUPER + CTRL + SHIFT + 3", hl.dsp.window.move({ workspace = "3", follow = false }))
hl.bind("SUPER + CTRL + SHIFT + 4", hl.dsp.window.move({ workspace = "4", follow = false }))
hl.bind("SUPER + CTRL + SHIFT + 5", hl.dsp.window.move({ workspace = "5", follow = false }))
hl.bind("SUPER + CTRL + SHIFT + 6", hl.dsp.window.move({ workspace = "6", follow = false }))
hl.bind("SUPER + CTRL + SHIFT + 7", hl.dsp.window.move({ workspace = "7", follow = false }))
hl.bind("SUPER + CTRL + SHIFT + 8", hl.dsp.window.move({ workspace = "8", follow = false }))
hl.bind("SUPER + CTRL + SHIFT + 9", hl.dsp.window.move({ workspace = "9", follow = false }))
hl.bind("SUPER + CTRL + SHIFT + 0", hl.dsp.window.move({ workspace = "10", follow = false }))
-- Scrollable workspace navigation
hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
-- Navigate workspaces
hl.bind("SUPER + Tab", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + SHIFT + Tab", hl.dsp.focus({ workspace = "e-1" }))
-- Special workspace (scratchpad)
hl.bind("SUPER + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind("SUPER + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))
-- Open Hornero's system overview. This uses the Shell Dashboard and does not
-- depend on an optional Hyprland plugin being built and loaded into the session.
hl.bind("SUPER + O", hl.dsp.exec_cmd("horneroctl apps toggle dashboard --yes"))
-- ============================================================================
-- Mouse Bindings
-- ============================================================================
-- Move/resize windows with mouse
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { drag = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { drag = true })
-- ============================================================================
-- Media Keys
-- ============================================================================
-- Volume control
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pamixer -i 5"), { repeating = true, locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pamixer -d 5"), { repeating = true, locked = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("pamixer -t"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("pamixer --default-source -t"), { locked = true })
-- Media control
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
hl.bind("XF86AudioStop", hl.dsp.exec_cmd("playerctl stop"), { locked = true })
-- Brightness control
hl.bind(
	"XF86MonBrightnessUp",
	hl.dsp.exec_cmd("horneroctl hardware brightness up --step 0.1 --yes"),
	{ repeating = true, locked = true }
)
hl.bind(
	"XF86MonBrightnessDown",
	hl.dsp.exec_cmd("horneroctl hardware brightness down --step 0.1 --yes"),
	{ repeating = true, locked = true }
)
hl.bind(
	"SHIFT + XF86MonBrightnessUp",
	hl.dsp.exec_cmd("horneroctl hardware brightness up --step 0.01 --yes"),
	{ repeating = true, locked = true }
)
hl.bind(
	"SHIFT + XF86MonBrightnessDown",
	hl.dsp.exec_cmd("horneroctl hardware brightness down --step 0.01 --yes"),
	{ repeating = true, locked = true }
)
-- ============================================================================
-- Screenshots
-- ============================================================================
-- Full screenshot
hl.bind("Print", hl.dsp.exec_cmd("horneroctl capture screenshot --yes"))
-- Area screenshot
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("horneroctl capture screenshot --region --yes"))
-- ============================================================================
-- System Control
-- ============================================================================
-- Reload Hyprland
hl.bind("SUPER + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload"))
-- Exit Hyprland
hl.bind("SUPER + SHIFT + E", hl.dsp.exit())
-- Toggle Bar (Quickshell)
hl.bind("SUPER + CTRL + B", hl.dsp.exec_cmd("horneroctl shell ipc -- call drawers toggle bar"))
-- ============================================================================
-- Group Management
-- ============================================================================
-- Toggle group
hl.bind("SUPER + G", hl.dsp.group.toggle())
-- Change focus in group
hl.bind("SUPER + period", hl.dsp.group.next())
hl.bind("SUPER + comma", hl.dsp.group.prev())
-- Lock group
hl.bind("SUPER + SHIFT + O", hl.dsp.group.lock_active())
