RegisterNUICallback("getInvoices", function(data, cb)
    local invoices = lib.callback.await("getInvoices", false)
    cb(invoices)
end)

RegisterNUICallback("payInvoice", function(data, cb)
    local success, message = lib.callback.await("payInvoice", false, data.id)

    -- print(success, message)

    cb({
        success = success,
        message = message,
    })
end)

