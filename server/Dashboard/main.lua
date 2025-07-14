local ESX = exports["es_extended"]:getSharedObject()

local function GetPlayerAccounts(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return nil
    end

    local accounts = {
        {
            name = "Hovedkonto",
            balance = xPlayer.getAccount("bank").money,
            type = "bank",
            description = "Det du har ved os.",
        },
        {
            name = "Kontant",
            balance = xPlayer.getAccount("money").money,
            type = "cash",
            description = "Kontant du har på dig.",
        },
    }

    return accounts
end

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
        LIMIT 3
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

local function GetRecentInvoices(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return nil
    end

    local billings = {}
    local esxJobs = ESX.GetJobs()
    local response = MySQL.query.await([[
        SELECT * FROM `billing` 
        WHERE `identifier` = ? 
        ORDER BY `time` DESC 
        LIMIT 3
    ]], {
        xPlayer.identifier,
    })

    if response then
        for i = 1, #response do
            local row = response[i]

            local label = ""
            local jobName = row.target:gsub("society_", "")
            if esxJobs[jobName] then
                label = esxJobs[jobName].label
            end

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

lib.callback.register("getDashboardData", function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return nil
    end

    return {
        accounts = GetPlayerAccounts(source),
        recentTransactions = GetRecentTransactions(source),
        recentInvoices = GetRecentInvoices(source),
    }
end)
