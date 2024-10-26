local QBCore = exports['qb-core']:GetCoreObject()
local isReloading = false

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustPressed(0, 45) and not isReloading then
            local ped = PlayerPedId()
            local weapon = GetSelectedPedWeapon(ped)

            if weapon ~= `WEAPON_UNARMED` then
                local ammoType = QBCore.Shared.Weapons[weapon]['ammotype']
                if ammoType then
                    isReloading = true
                    QBCore.Functions.Progressbar("reload_weapon", "リロード中...", 1500, false, true, {
                        disableMovement = false,
                        disableCarMovement = false,
                        disableMouse = false,
                        disableCombat = false,
                    }, {}, {}, {}, function()
                        local currentAmmo = GetAmmoInPedWeapon(ped, weapon)

                        -- サーバーでのリロード処理をトリガー
                        TriggerServerEvent('qb-reload:server:HandleReload', currentAmmo, ammoType)

                        -- サーバーに弾薬を保存するリクエストを送信
                        TriggerServerEvent('qb-weapons:server:UpdateWeaponAmmo', {
                            name = QBCore.Shared.Weapons[weapon].name
                        }, currentAmmo)
                        
                        isReloading = false
                    end, function()
                        isReloading = false
                    end)
                end
            end
        end
    end
end)

-- リロード完了時の処理
RegisterNetEvent('qb-reload:client:FinishReload', function(ammoType, amount)
    local ped = PlayerPedId()
    local weapon = GetSelectedPedWeapon(ped)

    local currentAmmo = GetAmmoInPedWeapon(ped, weapon)
    local newAmmo = currentAmmo + amount

    if newAmmo > 250 then
        newAmmo = 250
    end

    SetPedAmmo(ped, weapon, newAmmo)

    -- サーバーに更新された弾薬量を送信
    TriggerServerEvent('qb-weapons:server:UpdateWeaponAmmo', {
        name = QBCore.Shared.Weapons[weapon].name
    }, newAmmo)
end)
