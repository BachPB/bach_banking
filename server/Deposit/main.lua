local ESX = exports["es_extended"]:getSharedObject()

lib.callback.register("deposit", function(source, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false, "Du har ikke nogen telefon" end

    local cash = xPlayer.getMoney()
    if cash < amount then return false, "Du har ikke nok kontanter" end

    xPlayer.removeMoney(amount)
    Wait(500)
    xPlayer.addAccountMoney("bank", amount)

    return true, "Du har indsat " .. amount .. " på din konto"
end)

