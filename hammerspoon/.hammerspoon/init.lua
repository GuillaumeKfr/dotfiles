-- 3-finger trackpad swipe to switch AeroSpace workspaces.
-- Uses Swipe.spoon: https://github.com/mogenson/Swipe.spoon (vendored in ./Spoons)
-- Disable the native 3-finger horizontal swipe in System Settings >
-- Trackpad > More Gestures > "Swipe between full-screen applications" to
-- avoid conflicts.

local Swipe = hs.loadSpoon("Swipe")

local config = {
	fingers = 3,
	-- trigger once swipe distance exceeds 8% of the trackpad
	threshold = 0.08,
	showAlert = false,
	alertDuration = 0.4,
}

local AEROSPACE = "/opt/homebrew/bin/aerospace"

-- Focus the workspace currently visible on the monitor under the mouse, then
-- move prev/next with wrap-around. The first step keeps multi-monitor setups
-- in sync so the swipe acts on the display you're pointing at.
local function aerospaceWorkspace(dir)
	-- --no-stdin is required on the next/prev command: AeroSpace v0.20.0 forbids
	-- implicit stdin, and hs.execute never runs with a TTY. It is only valid with
	-- the next/prev argument, so it must not appear on the named-workspace command.
	local cmd = string.format(
		"%s list-workspaces --monitor mouse --visible | xargs %s workspace && %s workspace --no-stdin --wrap-around %s",
		AEROSPACE,
		AEROSPACE,
		AEROSPACE,
		dir
	)
	hs.execute(cmd)

	if config.showAlert then
		hs.alert.show("AeroSpace: " .. dir, config.alertDuration)
	end
end

local current_id, threshold
Swipe:start(config.fingers, function(direction, distance, id)
	if id == current_id then
		if distance > threshold then
			threshold = math.huge -- only trigger once per swipe
			if direction == "left" then
				aerospaceWorkspace("next")
			elseif direction == "right" then
				aerospaceWorkspace("prev")
			end
		end
	else
		current_id = id
		threshold = config.threshold
	end
end)
