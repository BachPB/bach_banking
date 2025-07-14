local ESX = exports["es_extended"]:getSharedObject()

local function GetRecentInvoices(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return nil end

    local billings = {}
    local esxJobs = ESX.GetJobs()
    local response = MySQL.query.await([[
        SELECT * FROM `billing` 
        WHERE `identifier` = ? 
        ORDER BY `time` DESC 
    ]], {
        xPlayer.identifier,
    })

    if response then
        for i = 1, #response do
            local row = response[i]

            local label = ""
            local jobName = row.target:gsub("society_", "")
            if esxJobs[jobName] then label = esxJobs[jobName].label end

            local dateStr = "I dag"
            if row.time then
                local transactionDate = os.date("*t", row.time)
                local today = os.date("*t")

                if transactionDate.year == today.year and transactionDate.month == today.month then
                    if transactionDate.day == today.day then
                        dateStr = "I dag"
                    elseif transactionDate.day == today.day - 1 then
                        dateStr = "I går"
                    else
                        dateStr = os.date("%d/%m", row.time)
                    end
                else
                    dateStr = os.date("%d/%m/%Y", row.time)
                end
            end

            table.insert(billings, {
                name = label,
                amount = -row.amount,
                date = dateStr,
                type = "invoice",
                id = row.id,
                sender = row.sender,
                targetType = row.target_type,
                target = row.target,
            })
        end
    end

    return billings
end

lib.callback.register("getInvoices", function(source)
    return GetRecentInvoices(source)
end)

lib.callback.register("payInvoice", function(source, id)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false, "Kunne ikke finde spilleren" end

    local time = os.time()

    local result = MySQL.query.await("SELECT * FROM billing WHERE id = @id", {
        ["@id"] = id,
    })

    if not result[1] then return false, "Kunne ikke finde fakturaen" end

    local sender = result[1].sender
    local targetType = result[1].target_type
    local target = result[1].target
    local amount = result[1].amount
    local label = result[1].label

    local xTarget = ESX.GetPlayerFromIdentifier(sender)

    if targetType ~= "player" then
        local promise = promise.new()

        TriggerEvent("esx_addonaccount:getSharedAccount", target, function(account)
            if not account then
                promise:resolve({
                    false,
                    "Kunne ikke finde kontoen",
                })
                return
            end

            if xPlayer.getAccount("bank").money >= amount then
                local deleted = MySQL.query.await("DELETE from billing WHERE id = @id", {
                    ["@id"] = id,
                })

                if deleted then
                    xPlayer.removeAccountMoney("bank", amount)
                    account.addMoney(amount)

                    local billingType = target == "society_police" and "Bøden" or "Fakturaen"

                    if xTarget then
                        exports["lb-phone"]:SendNotification(xTarget.source, {
                            app = "billing_app",
                            title = "Faktura Betalt",
                            content = billingType .. " er blevet betalt. For " .. lib.math.groupdigits(amount, ".") ..
                              ",- DKK",
                        })
                    end

                    TriggerEvent("esx_billing:paidBill", id, target, amount, xPlayer, sender)

                    promise:resolve({
                        true,
                        billingType .. " er blevet betalt. For " .. lib.math.groupdigits(amount, ".") .. ",- DKK",
                    })
                else
                    promise:resolve({
                        false,
                        "Der skete en fejl ved betaling af fakturaen",
                    })
                end
            else
                promise:resolve({
                    false,
                    "Du har ikke nok penge til at betale fakturaen",
                })
            end
        end)

        local result = Citizen.Await(promise)
        return table.unpack(result)
    else
        return false, "Ugyldig faktura type"
    end
end)

