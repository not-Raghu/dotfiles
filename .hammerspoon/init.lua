hs.hotkey.bind({ "ctrl" }, "1", function()
	hs.application.launchOrFocus("Brave Browser")
end, nil, nil, true)

hs.hotkey.bind({ "ctrl" }, "2", function()
	hs.application.launchOrFocus("ghostty")
end, nil, nil, true)

hs.hotkey.bind({ "ctrl" }, "3", function()
	hs.application.launchOrFocus("Visual Studio Code")
end, nil, nil, true)

--hs.hotkey.bind({ "ctrl" }, "4", function()
--	hs.application.launchOrFocus("Slack") -- or any other app
--end)
