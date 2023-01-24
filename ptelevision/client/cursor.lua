local scale = 1.5
local screenWidth = math.floor(1920 / scale)
local screenHeight = math.floor(1080 / scale)
shouldDraw = false

function SetInteractScreen(bool)
    if CURRENT_SCREEN and CURRENT_SCREEN.canInteract == nil then
        TriggerServerEvent("ptelevision:canInteract", CURRENT_SCREEN)
    end

    while CURRENT_SCREEN.canInteract == nil do
        Wait(0)
    end

    if CURRENT_SCREEN.canInteract == false then
        TriggerEvent("noire_nui:defaultNotify", "TV_CANNOT_INTERACT", "TV", "You cannot control this screen.")
        return
    end

    if (not shouldDraw and bool) then
        shouldDraw = bool
        Citizen.CreateThread(
            function()
                -- Create screen
                local nX = 0
                local nY = 0

                local w, h = screenWidth, screenHeight

                local minX, maxX = ((w - (w / 2)) / 2), (w - (w / 4))
                local totalX = minX - maxX

                local minY, maxY = ((h - (h / 2)) / 2), (h - (h / 4))
                local totalY = minY - maxY

                RequestTextureDictionary("fib_pc")

                local lastDuiX, lastDuiY = 0, 0

                -- Update controls while active
                while shouldDraw do
                    nX = GetControlNormal(0, 239) * screenWidth
                    nY = GetControlNormal(0, 240) * screenHeight
                    DisableControlAction(0, 1, true) -- Disable looking horizontally
                    DisableControlAction(0, 2, true) -- Disable looking vertically

                    DisableControlAction(0, 16, true) -- Disable scroll weapon
                    DisableControlAction(0, 17, true) -- Disable scroll weapon

                    DisablePlayerFiring(PlayerPedId(), true) -- Disable weapon firing
                    DisableControlAction(0, 142, true) -- Disable aiming
                    DisableControlAction(0, 106, true) -- Disable in-game mouse controls
                    -- Update mouse position when changed
                    DrawSprite("ptelevision_b_dict", "ptelevision_b_txd", 0.5, 0.5, 0.5, 0.5, 0.0, 255, 255, 255, 255)
                    if nX ~= mX or nY ~= mY then
                        mX = nX
                        mY = nY
                        local duiX = -screenWidth * ((mX - minX) / totalX)
                        local duiY = -screenHeight * ((mY - minY) / totalY)
                        BlockWeaponWheelThisFrame()
                        if not (mX > 325) then
                            mX = 325
                        end
                        if not (mX < 965) then
                            mX = 965
                        end
                        if not (mY > 185) then
                            mY = 185
                        end
                        if not (mY < 545) then
                            mY = 545
                        end
                        SendDuiMouseMove(duiObj, math.floor(duiX), math.floor(duiY))

                        lastDuiX = math.floor(duiX)
                        lastDuiY = math.floor(duiY)
                        print(duiX, duiY)
                    end
                    DrawSprite("fib_pc", "arrow", mX / screenWidth, mY / screenHeight, 0.005, 0.01, 0.0, 255, 255, 255, 255)

                    -- Send scroll and click events to dui

                    if IsControlPressed(0, 177) then
                        SetInteractScreen(false)
                        OpenTVMenu()
                    end -- scroll up
                    if IsDisabledControlPressed(0, 172) then
                        TriggerServerEvent("ptelevision:browserMouseEvent", CURRENT_SCREEN, 172, lastDuiX, lastDuiY)
                        SendDuiMouseWheel(duiObj, 10, 0)
                    end -- scroll up
                    if IsDisabledControlPressed(0, 173) then
                        TriggerServerEvent("ptelevision:browserMouseEvent", CURRENT_SCREEN, 173, lastDuiX, lastDuiY)
                        SendDuiMouseWheel(duiObj, -10, 0)
                    end -- scroll down

                    if IsDisabledControlJustPressed(0, 24) then
                        print("LEFT DOWN", lastDuiX, lastDuiY, GetGameTimer())
                        TriggerServerEvent("ptelevision:browserMouseEvent", CURRENT_SCREEN, 24, lastDuiX, lastDuiY)
                        SendDuiMouseDown(duiObj, "left")
                    elseif IsDisabledControlJustReleased(0, 24) then
                        print("LEFT UP", lastDuiX, lastDuiY, GetGameTimer())
                        SendDuiMouseUp(duiObj, "left")
                        SendDuiMouseUp(duiObj, "right")
                    end
                    if IsDisabledControlJustPressed(0, 25) then
                        SendDuiMouseDown(duiObj, "right")
                    elseif IsDisabledControlJustReleased(0, 25) then
                        SendDuiMouseUp(duiObj, "right")
                    end

                    Wait(0)
                end
            end
        )
    else
        shouldDraw = bool
    end
end
