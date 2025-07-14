local ESX = exports["es_extended"]:getSharedObject()

local function GetRecentTransactions(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return nil
    end

    local phoneNumber = exports["lb-phone"]:GetEquippedPhoneNumber(source)

    if not phoneNumber then
        return nil
    end

    local transactions = {}

    local response = MySQL.query.await([[
        SELECT * FROM `phone_wallet_transactions` 
        WHERE `phone_number` = ? 
        ORDER BY `timestamp` DESC 
    ]], {
        phoneNumber,
    })

    if response then
        for i = 1, #response do
            local row = response[i]
            local dateStr = "I dag"
            if row.timestamp then
                local timestampInSeconds = row.timestamp / 1000
                local transactionDate = os.date("*t", timestampInSeconds)
                local today = os.date("*t")

                if transactionDate.year == today.year and transactionDate.month == today.month then
                    if transactionDate.day == today.day then
                        dateStr = "I dag"
                    elseif transactionDate.day == today.day - 1 then
                        dateStr = "I går"
                    else
                        dateStr = os.date("%d/%m", timestampInSeconds)
                    end
                else
                    dateStr = os.date("%d/%m/%Y", timestampInSeconds)
                end
            end

            table.insert(transactions, {
                name = row.company,
                amount = row.amount,
                date = dateStr,
                type = "wallet",
            })
        end
    end

    return transactions
end

lib.callback.register("getTransactions", function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return nil
    end

    return GetRecentTransactions(source)
end)
