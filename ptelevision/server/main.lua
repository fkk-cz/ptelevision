ESX = nil
local Locations = {}

TriggerEvent(
    "esx:getSharedObject",
    function(obj)
        ESX = obj
    end
)

function SetTelevision(coords, key, value, update)
    local index, data = GetTelevision(coords)
    if (index ~= nil) then
        if (Televisions[index] == nil) then
            Televisions[index] = {}
        end
        Televisions[index][key] = value
    else
        index = os.time()
        while Televisions[index] do
            index = index + 1
            Citizen.Wait(0)
        end
        if (Televisions[index] == nil) then
            Televisions[index] = {}
        end
        Televisions[index][key] = value
    end
    Televisions[index].coords = coords
    Televisions[index].update_time = os.time()
    if (update) then
        TriggerClientEvent("ptelevision:event", -1, Televisions, index, key, value)
    end
    return index
end

function SetChannel(source, data)
    if data then
        for k, v in pairs(Channels) do
            if (Channels[k].source == source) then
                return
            end
        end
        local index = 1
        while Channels[index] do
            index = index + 1
            Citizen.Wait(0)
        end
        Channels[index] = data
        Channels[index].source = source
        TriggerClientEvent("ptelevision:broadcast", -1, Channels, index)
        return
    else
        for k, v in pairs(Channels) do
            if (Channels[k].source == source) then
                Channels[k] = nil
                TriggerClientEvent("ptelevision:broadcast", -1, Channels, k)
                return
            end
        end
    end
end

RegisterNetEvent(
    "ptelevision:requestSync",
    function(coords)
        local _source = source
        local index, data = GetTelevision(coords)
        TriggerClientEvent("ptelevision:requestSync", _source, coords, {current_time = os.time()})
    end
)

RegisterNetEvent(
    "ptelevision:event",
    function(data, key, value)
        local _source = source

        if data and data.model == GetHashKey("v_ilev_cin_screen") then
            local xPlayer = ESX.GetPlayerFromId(_source)
            if xPlayer.job.name == "cinema" and xPlayer.job.grade >= 2 then
                SetTelevision(data.coords, key, value, true)
                return
            end
        end

        Config.Events.ScreenInteract(
            _source,
            data,
            key,
            value,
            function()
                SetTelevision(data.coords, key, value, true)
            end
        )
    end
)

RegisterNetEvent(
    "ptelevision:broadcast",
    function(data)
        local _source = source
        Config.Events.Broadcast(
            _source,
            data,
            function()
                SetChannel(_source, data)
            end
        )
    end
)

RegisterNetEvent(
    "ptelevision:requestUpdate",
    function()
        local _source = source
        TriggerClientEvent(
            "ptelevision:requestUpdate",
            _source,
            {
                Televisions = Televisions,
                Channels = Channels
            }
        )
    end
)

RegisterNetEvent(
    "ptelevision:browserMouseEvent",
    function(data, control, duiX, duiY)
        local _source = source
        TriggerClientEvent("ptelevision:browserMouseEvent", -1, _source, data, control, duiX, duiY)
    end
)

RegisterNetEvent(
    "ptelevision:canInteract",
    function(data)
        local _source = source
        TriggerClientEvent(
            "ptelevision:canInteract",
            _source,
            Player(_source).state.insideHouse or IsPlayerAceAllowed(_source, "controltv") or data.model == GetHashKey("v_ilev_cin_screen")
        )
    end
)

AddEventHandler(
    "playerDropped",
    function(reason)
        local _source = source
        SetChannel(_source, nil)
    end
)
