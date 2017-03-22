local DPResOptions_DefaultSettings = {
	enabled = false,
	debug = false
}

local function DPRes_Initialize()
	if not DPResOptions  then
		DPResOptions = {}
	end

	for i in DPResOptions_DefaultSettings do
		if (not DPResOptions[i]) then
			DPResOptions[i] = DPResOptions_DefaultSettings[i]
		end
	end
end

function DPRes_EventFrame_OnLoad()

	DEFAULT_CHAT_FRAME:AddMessage(string.format("DPRes version %s by %s", GetAddOnMetadata("DPRes", "Version"), GetAddOnMetadata("DPRes", "Author")))
    this:RegisterEvent("VARIABLES_LOADED")
    --this:RegisterEvent("CHAT_MSG_ADDON")
    this:RegisterEvent("CHAT_MSG_RAID")
	this:RegisterEvent("CHAT_MSG_RAID_LEADER")
    this:RegisterEvent("CHAT_MSG_GUILD")
    this:RegisterEvent("CHAT_MSG_OFFICER")
    this:RegisterEvent("CHAT_MSG_WHISPER")

	SlashCmdList["DPRes"] = DPRes_SlashCommand
	SLASH_DPRes1 = "/dpres"
	
	--MSG_PREFIX_ADD	= "RSAdd"
	--MSG_PREFIX_REMOVE	= "RSRemove"
	DPResDB = {}
	
	--patterns
	DPRes_pattern_add = "^!dpres add ([^%s]+) ([^%s]+)"

end

function DPRes_EventFrame_OnEvent()

	if event == "VARIABLES_LOADED" then
		this:UnregisterEvent("VARIABLES_LOADED")
		DPRes_Initialize()

	elseif event == "CHAT_MSG_RAID"  or event == "CHAT_MSG_RAID_LEADER" or event == "CHAT_MSG_GUILD" or event == "CHAT_MSG_OFFICER" or event == "CHAT_MSG_WHISPER" then
		
		if string.find(arg1, "^!dpres$") then
			DPRes_Debug("!dpres received by " .. arg2)
			DPRes_cmd_none(arg2)
		elseif string.find(arg1, "^!dpres list$") then
			DPRes_Debug("!dpres list received by " .. arg2)
			DPRes_cmd_list_g()
		end
	end
	
	if event == "CHAT_MSG_WHISPER" then
		if string.find(arg1, "^!dpres add") then
			DPRes_Debug("!dpres add received by " .. arg2)
			--!dpres add spec altname
			local _, _, spec, altname = string.find(arg1, DPRes_pattern_add)
			if spec and altname then
				DPRes_Debug("!dpres add " .. spec .. " " .. altname)
				DPRes_addtodb(arg2,spec,altname)
			end
		end
	end
end

function DPRes_Debug(msg)
	if DPResOptions.debug and msg then
		DEFAULT_CHAT_FRAME:AddMessage("DPRes Debug: " .. msg, 255, 0, 0)
	end
end

function DPRes_addtodb(name, spec, altname)
	if name and spec and altname then
		local t = date("%H:%M")
		
		if not DPRes_hasName(name) then
		
			DPRes_Debug("addtodb " .. name .. " " .. spec .. " " .. altname .. " " .. t)
			
			if getn(DPResDB) == 0 then
				DPResDB[1] = {}
				DPResDB[1].name = name
				DPResDB[1].spec = spec
				DPResDB[1].altname = altname
				DPResDB[1].timestamp = t
			else
				id = getn(DPResDB)+1 
				DPResDB[id] = {}
				DPResDB[id].name = name
				DPResDB[id].spec = spec
				DPResDB[id].altname = altname
				DPResDB[id].timestamp = t
			end
			
			SendChatMessage("DPRes: You have been added to the reserves at " .. t, "WHISPER", nil, name)
		
		else
			SendChatMessage("DPRes: You are already in the reserves database, "WHISPER", nil, name)
			DPRes_Debug("addtodb " .. name .. " already in the resdb")
		end
	end
end

--command functions
function DPRes_cmd_list_g()
	DPRes_Debug("list guild")
	local n = getn(DPResDB)
	DPRes_Debug(n)
	for i=1,n do
		DPRes_Debug(DPResDB[i].name .. " - " .. DPResDB[i].spec .. " - " .. DPResDB[i].altname .. " - " .. DPResDB[i].timestamp)
		SendChatMessage("DPRes: " .. DPResDB[i].name .. " - " .. DPResDB[i].spec .. " - " .. DPResDB[i].altname .. " - " .. DPResDB[i].timestamp, "GUILD")
	end
end

function DPRes_cmd_list_l()
	DPRes_Debug("list local")
	local n = getn(DPResDB)
	DPRes_Debug(n)
	for i=1,n do
		DPRes_Debug(DPResDB[i].name .. " - " .. DPResDB[i].spec .. " - " .. DPResDB[i].altname .. " - " .. DPResDB[i].timestamp)
		DEFAULT_CHAT_FRAME:AddMessage(DPResDB[i].name .. " - " .. DPResDB[i].spec .. " - " .. DPResDB[i].altname .. " - " .. DPResDB[i].timestamp)
	end
end


function DPRes_cmd_none(name)

end

--Slash Handler
function DPRes_SlashCommand( msg )
	if msg == "help" then
		DEFAULT_CHAT_FRAME:AddMessage("DPRes usage:")
		DEFAULT_CHAT_FRAME:AddMessage("/DPRes { help | list | clear }")
		DEFAULT_CHAT_FRAME:AddMessage(" - |cff9482c9help|r: prints out this help")
		DEFAULT_CHAT_FRAME:AddMessage(" - |cff9482c9list|r: lists the reserves")
		DEFAULT_CHAT_FRAME:AddMessage(" - |cff9482c9debug|r: toggles debug messages")
	elseif msg == "debug" then
		if DPResOptions["debug"] == true then
			DPResOptions["debug"] = false
			DEFAULT_CHAT_FRAME:AddMessage("DPRes - debug: |cffff0000disabled|r")
		elseif DPResOptions["debug"] == false then
			DPResOptions["debug"] = true
			DEFAULT_CHAT_FRAME:AddMessage("DPRes - debug: |cff00ff00enabled|r")
		end
	elseif msg == "list" then
		DPRes_cmd_list_l()
	elseif msg == "clear" then
		DPRes_Debug("DB clear")
		DPResDB = {}
	end
end

--help functions

--hasvalue
function DPRes_hasName(name)
	local n = getn(DPResDB)
	for i=1,n do
        if DPResDB[i].name == name then
            return true
        end
    end
    return false
end

--class color
function DPRes_GetClassColour(class)
	if (class) then
		local color = RAID_CLASS_COLORS[class]
		if (color) then
			return color
		end
	end
	return {r = 0.5, g = 0.5, b = 1}
end
