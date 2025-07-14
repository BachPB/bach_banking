ESX = exports["es_extended"]:getSharedObject()

local function FetchDashboardData()
    local data = lib.callback.await("getDashboardData", false)

    if not data then
        return
    end

    return data
end

RegisterNUICallback("getDashboardData", function(data, cb)
    local data = FetchDashboardData()
    cb(data)
end)

RegisterNUICallback("getPlayerName", function(data, cb)
    local data = ESX.GetPlayerData().firstName .. " " .. ESX.GetPlayerData().lastName
    cb(data)
end)
