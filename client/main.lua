--[[
──────────────────────────────────────────────────────────────────────────────────
─────────██████─██████████████─██████──████████─██████████████─████████████████───
─────────██░░██─██░░░░░░░░░░██─██░░██──██░░░░██─██░░░░░░░░░░██─██░░░░░░░░░░░░██───
─────────██░░██─██░░██████░░██─██░░██──██░░████─██░░██████████─██░░████████░░██───
─────────██░░██─██░░██──██░░██─██░░██──██░░██───██░░██─────────██░░██────██░░██───
─────────██░░██─██░░██──██░░██─██░░██████░░██───██░░██████████─██░░████████░░██───
─────────██░░██─██░░██──██░░██─██░░░░░░░░░░██───██░░░░░░░░░░██─██░░░░░░░░░░░░██───
─██████──██░░██─██░░██──██░░██─██░░██████░░██───██░░██████████─██░░██████░░████───
─██░░██──██░░██─██░░██──██░░██─██░░██──██░░██───██░░██─────────██░░██──██░░██─────
─██░░██████░░██─██░░██████░░██─██░░██──██░░████─██░░██████████─██░░██──██░░██████─
─██░░░░░░░░░░██─██░░░░░░░░░░██─██░░██──██░░░░██─██░░░░░░░░░░██─██░░██──██░░░░░░██─
─██████████████─██████████████─██████──████████─██████████████─██████──██████████─
──────────────────────────────────────────────────────────────────────────────────
]]--

local OriginalStatus, Status, isPaused = {}, {}, false

function GetStatusData(minimal)
	local status = {}

	for i=1, #Status, 1 do
		if minimal then
			table.insert(status, {
				name    = Status[i].name,
				val     = Status[i].val,
				percent = (Status[i].val / Config.StatusMax) * 100
			})
		else
			table.insert(status, {
				name    = Status[i].name,
				val     = Status[i].val,
				color   = Status[i].color,
				visible = Status[i].visible(Status[i]),
				percent = (Status[i].val / Config.StatusMax) * 100
			})
		end
	end

	return status
end

AddEventHandler('joker_sts:registerStatus', function(name, default, color, visible, tickCallback)
	local status = CreateStatus(name, default, color, visible, tickCallback)
	
	for i=1, #OriginalStatus, 1 do
		if status.name == OriginalStatus[i].name then
			status.set(OriginalStatus[i].val)
		end
	end

	table.insert(Status, status)
end)

AddEventHandler('joker_sts:unregisterStatus', function(name)
	for k,v in ipairs(Status) do
		if v.name == name then
			table.remove(Status, k)
			break
		end
	end
end)

RegisterNetEvent('esx:onPlayerLogout')
AddEventHandler('esx:onPlayerLogout', function()
	ESX.PlayerLoaded = false
	Status = {}
	if Config.Display then
		SendNUIMessage({
			update = true,
			status = Status
		})
	end
end)

RegisterNetEvent('joker_sts:load')
AddEventHandler('joker_sts:load', function(status)
	OriginalStatus = status
	ESX.PlayerLoaded = true
	TriggerEvent('joker_sts:loaded')

	if Config.Display then TriggerEvent('joker_sts:setDisplay', 0.5) end

	CreateThread(function()
		local data = {}
		while ESX.PlayerLoaded do
			for i=1, #Status do
				Status[i].onTick()
				table.insert(data, {
					name = Status[i].name,
					val = Status[i].val,
					percent = (Status[i].val / Config.StatusMax) * 100
				})
			end

			if Config.Display then
				local fullData = data
				for i=1, #data, 1 do
					fullData[i].color = Status[i].color
					fullData[i].visible = Status[i].visible(Status[i])
				end
				SendNUIMessage({
					update = true,
					status = fullData
				})
			end
------------------------------xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--------------------x
			TriggerEvent('joker_sts:onTick', data)
			TriggerEvent('joker-hud:onTick', data)
			table.wipe(data)
			Wait(Config.TickTime)
		end
	end)
end)

RegisterNetEvent('joker_sts:set')
AddEventHandler('joker_sts:set', function(name, val)
	for i=1, #Status, 1 do
		if Status[i].name == name then
			Status[i].set(val)
			break
		end
	end
	if Config.Display then
		SendNUIMessage({
			update = true,
			status = GetStatusData()
		})
	end
end)

RegisterNetEvent('joker_sts:add')
AddEventHandler('joker_sts:add', function(name, val)
	for i=1, #Status, 1 do
		if Status[i].name == name then
			Status[i].add(val)
			break
		end
	end
	if Config.Display then
		SendNUIMessage({
			update = true,
			status = GetStatusData()
		})
	end
end)

RegisterNetEvent('joker_sts:remove')
AddEventHandler('joker_sts:remove', function(name, val)
	for i=1, #Status, 1 do
		if Status[i].name == name then
			Status[i].remove(val)
			break
		end
	end
		if Config.Display then
		SendNUIMessage({
			update = true,
			status = GetStatusData()
		})
	end
end)

AddEventHandler('joker_sts:getStatus', function(name, cb)
	for i=1, #Status, 1 do
		if Status[i].name == name then
			cb(Status[i])
			return
		end
	end
end)

AddEventHandler('joker_sts:getAllStatus', function(cb)
	cb(Status)
end)

AddEventHandler('joker_sts:setDisplay', function(val)
	SendNUIMessage({
		setDisplay = true,
		display    = val
	})
end)

-- Pause menu disable hud display
if Config.Display then
	AddEventHandler('esx:pauseMenuActive', function(state)
		if state then
			isPaused = true
			TriggerEvent('joker_sts:setDisplay', 0.0)
			return
		end
		isPaused = false
		TriggerEvent('joker_sts:setDisplay', 0.5)
	end)

	-- Loading screen off event
	AddEventHandler('esx:loadingScreenOff', function()
		if not isPaused then
			TriggerEvent('joker_sts:setDisplay', 0.3)
		end
	end)
end

-- Update server
CreateThread(function()
	while true do
		Wait(Config.UpdateInterval)
		if ESX.PlayerLoaded then TriggerServerEvent('joker_sts:update', GetStatusData(true)) end
	end
end)
