ESX = exports["es_extended"]:getSharedObject()

local function FetchTransactions()
    local data = lib.callback.await("getTransactions", false)

    if not data then
        return
    end

    return data
end

RegisterNUICallback("getTransactions", function(data, cb)
    local data = FetchTransactions()
    cb(data)
end)

