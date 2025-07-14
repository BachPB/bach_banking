local config = lib.load("shared.Deposit")

RegisterNUICallback("getDepositConfig", function(data, cb)
    cb({
        success = true,
        quickAmounts = config.quickAmounts,
        presets = config.presets,
    })
end)

RegisterNUICallback("getBalanceDeposit", function(data, cb)
    local cash = exports.ox_inventory:Search("count", "money")

    cb({
        success = true,
        balance = cash,
    })
end)

RegisterNUICallback("deposit", function(data, cb)
    local success, message = lib.callback.await("deposit", false, data.amount)

    cb({
        success = success,
        message = message,
    })
end)
