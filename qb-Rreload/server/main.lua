QBCore = exports['qb-core']:GetCoreObject()

-- qb-weapons:server:UpdateWeaponAmmo イベントの登録
RegisterNetEvent('qb-weapons:server:UpdateWeaponAmmo', function(weaponName, newAmmo)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player then
        -- プレイヤーのインベントリをループして武器名が一致するアイテムを探す
        for _, item in pairs(Player.PlayerData.items) do
            if item.name == weaponName then
                -- 弾薬情報を更新
                item.info.ammo = newAmmo
                Player.Functions.SetInventory(Player.PlayerData.items, true)
                return -- 更新が成功したら関数を抜ける
            end
        end
        print("Item not found with name: ", weaponName)
    else
        print("Player not found for source: ", src)
    end
end)

-- qb-reload:server:HandleReload イベントの処理
RegisterNetEvent('qb-reload:server:HandleReload', function(currentAmmo, ammoType)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player then
        print("Player not found")
        return
    end

    local ammoMapping = {
        AMMO_PISTOL = {item = 'pistol_ammo', reloadAmount = 30},
        AMMO_SMG = {item = 'smg_ammo', reloadAmount = 30},
        AMMO_SHOTGUN = {item = 'shotgun_ammo', reloadAmount = 10},
        AMMO_RIFLE = {item = 'rifle_ammo', reloadAmount = 30},
        AMMO_MG = {item = 'mg_ammo', reloadAmount = 30},
        AMMO_SNIPER = {item = 'snp_ammo', reloadAmount = 10},
        AMMO_EMPLAUNCHER = {item = 'emp_ammo', reloadAmount = 1},
        AMMO_FLARE = {item = 'flare_ammo', reloadAmount = 1}
    }

    local ammoData = ammoMapping[ammoType]
    local maxAmmo = 250

    if not ammoData then
        print("ammoData is nil")
        return
    end

    local ammoItemName = ammoData.item
    local reloadAmount = ammoData.reloadAmount
    local ammoItem = Player.Functions.GetItemByName(ammoItemName)

    if not ammoItem or ammoItem.amount <= 0 then
        return
    end

    if currentAmmo >= maxAmmo then
        TriggerClientEvent('QBCore:Notify', src, "弾薬はすでに最大です。", "error")
        return
    end

    if currentAmmo + reloadAmount > maxAmmo then
        reloadAmount = maxAmmo - currentAmmo
    end

    if reloadAmount <= 0 then
        return
    end

    local success = Player.Functions.RemoveItem(ammoItemName, 1)
    if not success then
        return
    end

    TriggerClientEvent('qb-reload:client:FinishReload', src, ammoType, reloadAmount)
    TriggerClientEvent('QBCore:Notify', src, "リロードしました", "success")
    
    -- 弾薬を更新
    if QBCore.Shared.Weapons[ammoItemName] then
        -- QBCore.Shared.Weapons[ammoItemName] が存在する場合のみ処理を実行
        TriggerEvent('qb-weapons:server:UpdateWeaponAmmo', {
            name = QBCore.Shared.Weapons[ammoItemName].name,
        }, currentAmmo + reloadAmount)
    else
        -- デバッグ用のメッセージを表示
        print("Invalid ammoItemName: ", ammoItemName)
    end
end)
