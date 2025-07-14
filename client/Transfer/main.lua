RegisterNuiCallback("getContacts", function(data, cb)
    local contacts = lib.callback.await("getContacts", false)
    cb(contacts)
end)

RegisterNuiCallback("getBalance", function(data, cb)
    local balance = ESX.GetPlayerData().accounts

    for _, account in ipairs(balance) do
        if account.name == "bank" then
            balance = account.money
        end
    end

    cb(balance)
end)

RegisterNuiCallback("transfer", function(data, cb)
    local amount = data.amount
    local recipient = data.recipient
    local message = data.message
    local success, message = lib.callback.await("transfer", false, amount, recipient, message)

    -- print(success, message)

    cb({
        success = success,
        message = message or nil,
    })
end)
