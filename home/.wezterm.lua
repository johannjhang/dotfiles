local function read_file(filename)
  local file = io.open(filename, "r")
  if not file then
    return nil
  end
  local content = file:read("*a")
  file:close()
  return content
end

local function trim(s)
  return s and s:match("^%s*(.-)%s*$") or nil
end

-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

local home_dir = os.getenv("HOME")
if not home_dir then
  home_dir = os.getenv("USERPROFILE")
end

-- For example, changing the color scheme:
config.color_scheme = trim(read_file(home_dir .. "/.config/wezterm/color_scheme"))

config.font = wezterm.font(trim(read_file(home_dir .. "/.config/wezterm/font")))
config.font_size = tonumber(trim(read_file(home_dir .. "/.config/wezterm/font_size")))

-- The current search mode does not pause the stream, so it's not ready for replacing tmux. Disbling the tmux mimic for now.
-- config.leader = { key="s", mods="CTRL" }
config.keys = {
  { key = "a",  mods = "LEADER|CTRL",  action = wezterm.action.SendString("\x13") },
  { key = "-",  mods = "LEADER",       action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
  { key = "|",  mods = "LEADER",       action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = "\\", mods = "LEADER",       action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = "s",  mods = "LEADER",       action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
  { key = "v",  mods = "LEADER",       action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = "o",  mods = "LEADER",       action = wezterm.action.TogglePaneZoomState },
  { key = "z",  mods = "LEADER",       action = wezterm.action.TogglePaneZoomState },
  { key = "c",  mods = "LEADER",       action = wezterm.action.SpawnTab("CurrentPaneDomain") },
  { key = "h",  mods = "LEADER",       action = wezterm.action.ActivatePaneDirection("Left") },
  { key = "j",  mods = "LEADER",       action = wezterm.action.ActivatePaneDirection("Down") },
  { key = "k",  mods = "LEADER",       action = wezterm.action.ActivatePaneDirection("Up") },
  { key = "l",  mods = "LEADER",       action = wezterm.action.ActivatePaneDirection("Right") },
  { key = "H",  mods = "LEADER|SHIFT", action = wezterm.action.AdjustPaneSize({ "Left", 5 }) },
  { key = "J",  mods = "LEADER|SHIFT", action = wezterm.action.AdjustPaneSize({ "Down", 5 }) },
  { key = "K",  mods = "LEADER|SHIFT", action = wezterm.action.AdjustPaneSize({ "Up", 5 }) },
  { key = "L",  mods = "LEADER|SHIFT", action = wezterm.action.AdjustPaneSize({ "Right", 5 }) },
  { key = "1",  mods = "LEADER",       action = wezterm.action.ActivateTab(0) },
  { key = "2",  mods = "LEADER",       action = wezterm.action.ActivateTab(1) },
  { key = "3",  mods = "LEADER",       action = wezterm.action.ActivateTab(2) },
  { key = "4",  mods = "LEADER",       action = wezterm.action.ActivateTab(3) },
  { key = "5",  mods = "LEADER",       action = wezterm.action.ActivateTab(4) },
  { key = "6",  mods = "LEADER",       action = wezterm.action.ActivateTab(5) },
  { key = "7",  mods = "LEADER",       action = wezterm.action.ActivateTab(6) },
  { key = "8",  mods = "LEADER",       action = wezterm.action.ActivateTab(7) },
  { key = "9",  mods = "LEADER",       action = wezterm.action.ActivateTab(8) },
  { key = "&",  mods = "LEADER|SHIFT", action = wezterm.action.CloseCurrentTab({ confirm = true }) },
  { key = "x",  mods = "LEADER",       action = wezterm.action.CloseCurrentPane({ confirm = true }) },
  { key = "p",  mods = "LEADER",       action = wezterm.action.ActivateTabRelative(-1) },
  { key = "n",  mods = "LEADER",       action = wezterm.action.ActivateTabRelative(1) },
  { key = "s",  mods = "LEADER|CTRL",  action = wezterm.action.ActivateLastTab },
  { key = "[",  mods = "LEADER",       action = wezterm.action.ActivateCopyMode },
  -- { key = " ",  mods = "CTRL",         action = wezterm.action.QuickSelect },
  { key = "?",  mods = "LEADER",       action = wezterm.action.ActivateCommandPalette },

  -- { key = "/",   mods = "CTRL",       action = wezterm.action.Search({ CaseInSensitiveString = "" }) },
  { key = "_",   mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
  { key = "[",   mods = "CTRL",       action = wezterm.action.SendKey({ key = "Escape", mods = "NONE" }) },
  { key = "Tab", mods = "CTRL",       action = wezterm.action.ActivateLastTab },

  { key = 'Enter', mods = 'ALT', action = wezterm.action.DisableDefaultAssignment },  -- disable alt-enter keybinding
}

local copy_mode_keys = wezterm.gui.default_key_tables().copy_mode
table.insert(
  copy_mode_keys,
  { key = "[", mods = "CTRL", action = wezterm.action.CopyMode("Close") })
table.insert(
  copy_mode_keys,
  { key = "b", mods = "CTRL", action = wezterm.action.CopyMode("PageUp") })
table.insert(
  copy_mode_keys,
  { key = "f", mods = "CTRL", action = wezterm.action.CopyMode("PageDown") })
table.insert(
  copy_mode_keys,
  { key = "n", mods = "CTRL",  action = wezterm.action.CopyMode("PriorMatch") })
table.insert(
  copy_mode_keys,
  { key = "p", mods = "CTRL", action = wezterm.action.CopyMode("NextMatch") })
table.insert(
  copy_mode_keys,
  { key = "Tab", mods = "NONE",  action = wezterm.action.CopyMode("PriorMatch") })
table.insert(
  copy_mode_keys,
  { key = "Tab", mods = "SHIFT", action = wezterm.action.CopyMode("NextMatch") })

local search_mode_keys = wezterm.gui.default_key_tables().search_mode
table.insert(
  search_mode_keys,
  { key = "Enter",   mods = "NONE",  action = wezterm.action.CopyMode("AcceptPattern") })
table.insert(
  search_mode_keys,
  { key = "[",   mods = "CTRL",  action = wezterm.action.CopyMode("Close") })
table.insert(
  search_mode_keys,
  { key = "c",   mods = "CTRL",  action = wezterm.action.CopyMode("Close") })
table.insert(
  search_mode_keys,
  { key = "w",   mods = "CTRL",  action = wezterm.action.CopyMode("ClearPattern") })
table.insert(
  search_mode_keys,
  { key = "b", mods = "CTRL", action = wezterm.action.ScrollByPage(-1) })
table.insert(
  search_mode_keys,
  { key = "f", mods = "CTRL", action = wezterm.action.ScrollByPage(1) })
table.insert(
  search_mode_keys,
  { key = "u",   mods = "CTRL",  action = wezterm.action.ScrollByPage(-0.5) })
table.insert(
  search_mode_keys,
  { key = "d",   mods = "CTRL",  action = wezterm.action.ScrollByPage(0.5) })
table.insert(
  search_mode_keys,
  { key = "n", mods = "CTRL",  action = wezterm.action.CopyMode("PriorMatch") })
table.insert(
  search_mode_keys,
  { key = "p", mods = "CTRL", action = wezterm.action.CopyMode("NextMatch") })
table.insert(
  search_mode_keys,
  { key = "Tab", mods = "NONE",  action = wezterm.action.CopyMode("PriorMatch") })
table.insert(
  search_mode_keys,
  { key = "Tab", mods = "SHIFT", action = wezterm.action.CopyMode("NextMatch") })

config.key_tables = {
  copy_mode = copy_mode_keys,
  search_mode = search_mode_keys,
}

config.mouse_bindings = {
  {
    event = { Up = { streak = 1, button = "Left" } },
    mods = "NONE",
    action = wezterm.action.CompleteSelection("PrimarySelection"),
  },
  {
    event = { Up = { streak = 1, button = "Left" } },
    mods = "ALT",
    action = wezterm.action.OpenLinkAtMouseCursor,
  },
  {
    event = { Up = { streak = 1, button = "Left" } },
    mods = "SUPER",
    action = wezterm.action.OpenLinkAtMouseCursor,
  },
}

-- config.quick_select_remove_styling = true

config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true

if wezterm.target_triple == "x86_64-pc-windows-msvc" then
  config.default_prog = { "C:/msys64/msys2_shell.cmd", "-defterm", "-here", "-no-start", "-ucrt64", "-use-full-path", "-shell", "fish" }
end

-- and finally, return the configuration to wezterm
return config
