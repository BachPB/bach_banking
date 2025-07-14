local ESX = exports["es_extended"]:getSharedObject()

lib.callback.register("withdrawMoney", function(source, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false, "Du har ikke nogen telefon" end

    local bankAccount = xPlayer.getAccount("bank")
    if bankAccount.money < amount then return false, "Du har ikke nok penge på din konto" end

    xPlayer.removeAccountMoney("bank", amount)
    Wait(500)
    xPlayer.addMoney(amount)

    return true, "Du har hævet " .. amount .. " fra din konto"
end)

