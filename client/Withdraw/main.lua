local config = lib.load("shared.Withdraw")

RegisterNUICallback("getWithdrawConfig", function(data, cb)
    cb({
        success = true,
        quickAmounts = config.quickAmounts,
        presets = config.presets,
    })
end)

RegisterNUICallback("getBalanceWithdraw", function(data, cb)
    local balance = ESX.GetPlayerData().accounts

    for _, account in ipairs(balance) do
        if account.name == "bank" then
            balance = account.money
        end
    end

    cb({
        success = true,
        balance = balance,
    })
end)

RegisterNUICallback("withdrawMoney", function(data, cb)
    local amount = data.amount
    local success, message = lib.callback.await("withdrawMoney", false, amount)

    cb({
        success = success,
        message = message,
    })
end)
