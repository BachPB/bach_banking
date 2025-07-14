function openBank()
    SendNUIMessage({
        action = "ShowUi",
        data = true,
    })
    SetNuiFocus(true, true)
end

RegisterNuiCallback("CloseUi", function(data, cb)
    SetNuiFocus(false, false)
    cb("ok")
end)

