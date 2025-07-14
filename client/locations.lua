local locations = lib.load("shared.locations")

local atmModels = {
    "prop_atm_01",
    "prop_atm_02",
    "prop_atm_03",
    "prop_fleeca_atm"
}

local function createBankPoints()
    for i, bank in ipairs(locations) do
        exports.ox_target:addBoxZone({
            coords = bank.pos,
            size = vector3(bank.width, bank.depth, bank.maxZ - bank.minZ),
            rotation = bank.heading,
            debug = false,
            options = {
                {
                    name = "bank_" .. i,
                    icon = "fas fa-university",
                    label = "Brug Bank",
                    distance = 2.0,
                    onSelect = function()
                        local playerPed = PlayerPedId()

                        TaskTurnPedToFaceCoord(playerPed, bank.pos.x, bank.pos.y, bank.pos.z)

                        local timeout = 1000
                        local startTime = GetGameTimer()

                        repeat
                            Wait(0)
                            local pedRot = GetEntityHeading(playerPed)
                            local targetRot = GetHeadingFromVector_2d(bank.pos.x - GetEntityCoords(playerPed).x,
                                bank.pos.y - GetEntityCoords(playerPed).y)
                            local angleDiff = math.abs((pedRot - targetRot + 180) % 360 - 180)

                            if GetGameTimer() - startTime > timeout then
                                break
                            end
                        until angleDiff < 10

                        repeat
                            Wait(0)
                        until IsPedWalking(playerPed) == false

                        lib.requestAnimDict("mp_common")
                        TaskPlayAnim(playerPed, "mp_common", "givetake1_a", 8.0, -8.0, -1, 0, 0, false, false, false)
                        Wait(1500)

                        openBank()
                    end,
                    canInteract = function()
                        return not IsPedInAnyVehicle(PlayerPedId(), false)
                    end,
                },
            },
        })

        if bank.npcInfo then
            lib.requestModel(bank.npcInfo.model)

            local ped = CreatePed(4, bank.npcInfo.model, bank.pos.x, bank.pos.y, bank.pos.z - 1.0, bank.npcInfo.heading,
                false, true)

            SetEntityInvincible(ped, true)
            FreezeEntityPosition(ped, true)
            SetBlockingOfNonTemporaryEvents(ped, true)

            if bank.npcInfo.scenario then
                TaskStartScenarioInPlace(ped, bank.npcInfo.scenario, 0, true)
            end
        end

        if bank.blip then
            local blip = AddBlipForCoord(bank.pos.x, bank.pos.y, bank.pos.z)
            SetBlipSprite(blip, bank.blip.sprite)
            SetBlipDisplay(blip, bank.blip.display)
            SetBlipScale(blip, bank.blip.scale)
            SetBlipColour(blip, bank.blip.color)
            SetBlipAsShortRange(blip, true)

            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(bank.name)
            EndTextCommandSetBlipName(blip)
        end
    end
end

CreateThread(function()
    exports['ox_target']:addModel(atmModels, {
        {
            name = "bank_atm",
            event = "qb-banking:target-openBankScreen",
            icon = "fas fa-university",
			label = "Brug ATM",
            distance = 1.5,
            onSelect = function(entity)
                local playerPed = PlayerPedId()

                local entPos = entity.coords

                TaskTurnPedToFaceCoord(playerPed, entPos.x, entPos.y, entPos.z)

                local timeout = 1000
                local startTime = GetGameTimer()

                repeat
                    Wait(0)
                    local pedRot = GetEntityHeading(playerPed)
                    local targetRot = GetHeadingFromVector_2d(entPos.x - GetEntityCoords(playerPed).x,
                    entPos.y - GetEntityCoords(playerPed).y)
                    local angleDiff = math.abs((pedRot - targetRot + 180) % 360 - 180)

                    if GetGameTimer() - startTime > timeout then
                        break
                    end
                until angleDiff < 10

                repeat
                    Wait(0)
                until IsPedWalking(playerPed) == false

                lib.requestAnimDict("mp_common")
                TaskPlayAnim(playerPed, "mp_common", "givetake1_a", 8.0, -8.0, -1, 0, 0, false, false, false)
                Wait(1500)

                openBank()
            end,
            canInteract = function()
                return not IsPedInAnyVehicle(PlayerPedId(), false)
            end,
        },
    })
end)

CreateThread(function()
    createBankPoints()
end)