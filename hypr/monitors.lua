-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

local omarchy_gdk_scale = 2
local omarchy_monitor_scale = "auto"

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))

-- Fallback for any unlisted monitor.
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })

-- GPD MicroPC 2 built-in panel (rotated 270°).
hl.monitor({ output = "DSI-1", mode = "preferred", position = "auto", scale = "auto", transform = 3 })

-- Samsung C43J89x UltraWide.
hl.monitor({ output = "DP-2", mode = "3840x1200@120", position = "auto", scale = "auto" })

-- Viture (primary when connected).
hl.monitor({ output = "DP-1", mode = "preferred", position = "auto", scale = 1.25 })
