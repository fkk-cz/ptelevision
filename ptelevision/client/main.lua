DEFAULT_URL = "https://cfx-nui-ptelevision/html/index.html"
duiUrl = DEFAULT_URL
duiObj = nil
tvObj = nil
volume = 0.5
CURRENT_SCREEN = nil

function getDuiURL()
    return duiUrl
end

function SetVolume(coords, num)
    volume = num
    SetTelevisionLocal(coords, "volume", num)
end

function GetVolume(dist, range)
    if not volume then
        return 0
    end
    local rem = (dist / range)
    rem = rem > volume and volume or rem
    local _vol = math.floor((volume - rem) * 100)
    return _vol
end

function setDuiURL(url)
    duiUrl = url
    SetDuiUrl(duiObj, duiUrl)
end

local sfName = "generic_texture_renderer"

local width = 1280
local height = 720

local sfHandle = nil
local txdHasBeenSet = false

function loadScaleform(scaleform)
    local scaleformHandle = RequestScaleformMovie(scaleform)

    while not HasScaleformMovieLoaded(scaleformHandle) do
        scaleformHandle = RequestScaleformMovie(scaleform)
        Citizen.Wait(0)
    end
    return scaleformHandle
end

function ShowScreen(data)
    CURRENT_SCREEN = data
    sfHandle = loadScaleform(sfName)
    runtimeTxd = "ptelevision_b_dict"

    local txd = CreateRuntimeTxd("ptelevision_b_dict")
    duiObj = CreateDui(duiUrl, width, height)
    local dui = GetDuiHandle(duiObj)
    local tx = CreateRuntimeTextureFromDuiHandle(txd, "ptelevision_b_txd", dui)

    Citizen.Wait(10)

    PushScaleformMovieFunction(sfHandle, "SET_TEXTURE")

    PushScaleformMovieMethodParameterString("ptelevision_b_dict")
    PushScaleformMovieMethodParameterString("ptelevision_b_txd")

    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(width)
    PushScaleformMovieFunctionParameterInt(height)

    PopScaleformMovieFunctionVoid()

    local renderId = nil
    local renderTarget = Config.Models[data.model].Target
    if renderTarget then
        renderId = CreateNamedRenderTargetForModel(renderTarget, data.model)
    end

    Citizen.CreateThread(
        function()
            TriggerServerEvent("ptelevision:requestSync", data.coords)
            local tvObj = data.entity
            local screenModel = Config.Models[data.model]
            while duiObj do
                if renderTarget ~= 0 and renderId ~= nil then
                    SetTextRenderId(renderId)
                    SetScriptGfxDrawOrder(4)
                    SetScriptGfxDrawBehindPausemenu(true)
                    DrawRect(0.5, 0.5, 1.0, 1.0, 0, 0, 0, 255)
                    DrawSprite("ptelevision_b_dict", "ptelevision_b_txd", 0.5, 0.5, 1.0, 1.0, 0.0, 255, 255, 255, 255)
                    SetTextRenderId(GetDefaultScriptRendertargetRenderId())
                    SetScriptGfxDrawBehindPausemenu(false)
                else
                    if (tvObj and sfHandle ~= nil and HasScaleformMovieLoaded(sfHandle)) then
                        local pos = GetEntityCoords(tvObj)
                        local scale = screenModel.Scale
                        local offset = GetOffsetFromEntityInWorldCoords(tvObj, screenModel.Offset.x, screenModel.Offset.y, screenModel.Offset.z)
                        local hz = GetEntityHeading(tvObj)
                        DrawScaleformMovie_3dNonAdditive(
                            sfHandle,
                            offset.x,
                            offset.y,
                            offset.z,
                            0.0,
                            -hz,
                            0.0,
                            2.0,
                            2.0,
                            2.0,
                            scale * 1,
                            scale * (9 / 16),
                            1,
                            2
                        )
                    end
                end
                Citizen.Wait(0)
            end
        end
    )
    Citizen.CreateThread(
        function()
            local screen = CURRENT_SCREEN
            local modelData = Config.Models[screen.model]
            local coords = modelData.SoundOffset and GetOffsetFromEntityInWorldCoords(screen.entity, 0, -20.0, 0) or screen.coords
            local range = modelData.SoundRange and modelData.SoundRange or modelData.Range
            local _, lstatus = GetTelevisionLocal(coords)
            if (lstatus and lstatus.volume) then
                SetVolume(coords, lstatus.volume)
            else
                SetVolume(coords, modelData.DefaultVolume)
            end
            while duiObj do
                local pcoords = GetEntityCoords(PlayerPedId())
                local dist = #(coords - pcoords)
                SendDuiMessage(
                    duiObj,
                    json.encode(
                        {
                            setVolume = true,
                            data = GetVolume(dist, range, volume)
                        }
                    )
                )
                Citizen.Wait(100)
            end
        end
    )
end

function HideScreen()
    CURRENT_SCREEN = nil
    if (duiObj) then
        DestroyDui(duiObj)
        SetScaleformMovieAsNoLongerNeeded(sfHandle)
        duiObj = nil
        sfHandle = nil
    end
end

function GetClosestScreen()
    local objPool = GetGamePool("CObject")
    local closest = {dist = -1}
    local plyPed = PlayerPedId()
    local pcoords = GetEntityCoords(PlayerPedId())
    for i = 1, #objPool do
        local entity = objPool[i]
        local model = GetEntityModel(entity)
        local data = Config.Models[model]
        if (data) then
            local coords = GetEntityCoords(entity)
            local dist = #(pcoords - coords)
            if (dist < closest.dist or closest.dist < 0) and dist < data.Range then
                if data.Interior and GetInteriorFromEntity(entity) == GetInteriorFromEntity(plyPed) then
                    if data.SameRoom then
                        if GetRoomKeyFromEntity(entity) == GetRoomKeyFromEntity(plyPed) then
                            closest = {dist = dist, coords = coords, model = model, entity = entity}
                        end
                    else
                        closest = {dist = dist, coords = coords, model = model, entity = entity}
                    end
                elseif not data.Interior then
                    closest = {dist = dist, coords = coords, model = model, entity = entity}
                end
            end
        end
    end
    return (closest.entity and closest or nil)
end

Citizen.CreateThread(
    function()
        Citizen.Wait(2000)
        TriggerServerEvent("ptelevision:requestUpdate")
        while true do
            local wait = 2500
            local data = GetClosestScreen()
            if (data and not duiObj) then
                ShowScreen(data)
            elseif ((not data or #(v3(CURRENT_SCREEN.coords) - v3(data.coords)) > 0.01) and duiObj) then
                HideScreen()
            end
            Citizen.Wait(wait)
        end
    end
)

Citizen.CreateThread(
    function()
        while true do
            local wait = 2500
            local locations = Config.Locations
            for i = 1, #locations do
                local data = locations[i]
                local dist = #(GetEntityCoords(PlayerPedId()) - v3(data.Position))
                if not locations[i].obj and dist < 20.0 then
                    LoadModel(data.Model)
                    locations[i].obj = CreateObject(data.Model, data.Position.x, data.Position.y, data.Position.z)
                    SetEntityHeading(locations[i].obj, data.Position.w)
                    FreezeEntityPosition(locations[i].obj, true)
                elseif locations[i].obj and dist > 20.0 then
                    DeleteEntity(locations[i].obj)
                    locations[i].obj = nil
                end
            end
            Citizen.Wait(wait)
        end
    end
)

RegisterNetEvent(
    "ptelevision:requestUpdate",
    function(data)
        Televisions = data.Televisions
        Channels = data.Channels
    end
)

RegisterNetEvent(
    "ptelevision:requestSync",
    function(coords, data)
        local tvObj = data.entity

        local _, status = GetTelevision(coords)
        local screenModel = Config.Models[data.model]
        if status and status["ptv_status"] then
            local update_time = status.update_time
            local status = status["ptv_status"]
            Citizen.Wait(1000)
            if status.type == "play" then
                if (status.channel and Channels[status.channel]) then
                    PlayVideo({url = Channels[status.channel].url, channel = status.channel})
                elseif (status.url) then
                    local time = math.floor(data.current_time - update_time)
                    PlayVideo({url = status.url, time = time})
                end
            elseif (status.type == "browser") then
                PlayBrowser({url = status.url})
            end
        end
    end
)

RegisterNetEvent(
    "ptelevision:browserMouseEvent",
    function(plySource, data, control, lastDuiX, lastDuiY)
        if
            CURRENT_SCREEN and CURRENT_SCREEN.model == data.model and data.coords == CURRENT_SCREEN.coords and duiObj and
                plySource ~= GetPlayerServerId(PlayerId())
         then
            if control == 172 then
                SendDuiMouseWheel(duiObj, 10, 0)
            end
            if control == 173 then
                SendDuiMouseWheel(duiObj, -10, 0)
            end

            if control == 24 then
                SendDuiMouseMove(duiObj, lastDuiX, lastDuiY)

                SendDuiMouseDown(duiObj, "left")
                Wait(0)
                SendDuiMouseUp(duiObj, "left")
                SendDuiMouseUp(duiObj, "right")
            end
        end
    end
)

RegisterNetEvent(
    "ptelevision:canInteract",
    function(allowed)
        if CURRENT_SCREEN then
            CURRENT_SCREEN.canInteract = allowed
        end
    end
)

RegisterNUICallback(
    "pageLoaded",
    function()
        waitForLoad = false
    end
)

AddEventHandler(
    "onResourceStop",
    function(name)
        if name == GetCurrentResourceName() then
            HideScreen()
        end
    end
)
