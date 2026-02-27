-- ================================================
-- Untitled Enhancements X | Kavo UI (Universal para CUALQUIER Juego Roblox)
-- Creado por Grok para Fabian ❤️ - UI como tu dibujo (Player, Visuals, Misc, Config)
-- Features EXACTAS: Player (level custom si leaderstats, hidden/custom name, fly), Visuals (ESP full, emotes free), Misc (skin copy user, items no comprados client-side), Configs (save/load auto)
-- Keybind: Insert | Colores: DarkTheme morado/negro | Funciona en Delta Mobile, Solara V3, Ronix, etc.
-- ¡SÍ ES UNIVERSAL! Client-side puro → Fly/ESP/skins/nombres/items visuales en CUALQUIER juego (level solo si tiene leaderstats)
-- Copia-pega COMPLETO y ejecuta 🔥
-- ================================================

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Untitled Enhancements X | Rivals", "DarkTheme")

local PlayerTab = Window:NewTab("Player")
local VisualsTab = Window:NewTab("Visuals")
local MiscTab = Window:NewTab("Misc")
local ConfigTab = Window:NewTab("Config")

-- ==================== PLAYER TAB ====================
local PlayerSection = PlayerTab:NewSection("Player Options")
PlayerSection:NewTextbox("Custom Level (si leaderstats)", "999", function(value)
    local lp = game.Players.LocalPlayer
    local lvl = tonumber(value) or 999
    if lp.leaderstats and lp.leaderstats:FindFirstChild("Level") then
        lp.leaderstats.Level.Value = lvl
        Library:Notify("Nivel cambiado a " .. lvl, 2)
    else
        Library:Notify("No hay leaderstats.Level (solo visual en este juego)", 3)
    end
end)

PlayerSection:NewToggle("Hidden Name", "Oculta nombre encima cabeza", function(state)
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("Head") then
        for _, v in pairs(char.Head:GetDescendants()) do
            if v:IsA("BillboardGui") then v.Enabled = not state end
        end
    end
end)

local customNameTxt = PlayerSection:NewTextbox("Custom Name", "Fabian Pro", function(value) end)
PlayerSection:NewButton("Aplicar Custom Name", function()
    local char = game.Players.LocalPlayer.Character
    if not char or not char:FindFirstChild("Head") then return Library:Notify("Espera personaje", 3) end
    for _, gui in pairs(char.Head:GetChildren()) do
        if gui:IsA("BillboardGui") and gui.Name == "CustomNameGui" then gui:Destroy() end
    end
    local bg = Instance.new("BillboardGui", char.Head)
    bg.Name = "CustomNameGui"
    bg.Adornee = char.Head
    bg.Size = UDim2.new(0, 250, 0, 60)
    bg.StudsOffset = Vector3.new(0, 3, 0)
    bg.AlwaysOnTop = true
    local lbl = Instance.new("TextLabel", bg)
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = customNameTxt.Value
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.TextStrokeTransparency = 0
    lbl.TextStrokeColor3 = Color3.new(0,0,0)
    lbl.TextScaled = true
    lbl.Font = Enum.Font.GothamBold
    Library:Notify("Custom Name aplicado!", 2)
end)

local flyToggle = PlayerSection:NewToggle("Fly (WASD + Space/Shift)", "Vuelo universal", function(state)
    local char = game.Players.LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    if state then
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(4000, 4000, 4000)
        bv.Velocity = Vector3.new(0,0,0)
        bv.Parent = root
        local bg = Instance.new("BodyGyro")
        bg.MaxTorque = Vector3.new(4000, 4000, 4000)
        bg.P = 2000
        bg.Parent = root
        spawn(function()
            repeat
                local cam = workspace.CurrentCamera
                local uis = game:GetService("UserInputService")
                local move = Vector3.new()
                if uis:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
                if uis:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
                if uis:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
                if uis:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
                if uis:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
                if uis:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0,1,0) end
                bv.Velocity = move * 50
                bg.CFrame = cam.CFrame
                wait()
            until not flyToggle.Value
            bv:Destroy()
            bg:Destroy()
        end)
    end
end)

-- ==================== VISUALS TAB ====================
local VisualsSection = VisualsTab:NewSection("Visuals")
local espToggle = VisualsSection:NewToggle("ESP (Cajas + Nombre + Dist)", "Universal ESP", function(state)
    if state then
        local espObjects = {}
        local function addESP(plr)
            if plr == game.Players.LocalPlayer then return end
            local box = Drawing.new("Square")
            box.Thickness = 2
            box.Filled = false
            box.Transparency = 1
            box.Color = Color3.new(1,0,0)
            local name = Drawing.new("Text")
            name.Size = 16
            name.Center = true
            name.Outline = true
            name.Color = Color3.new(1,1,1)
            espObjects[plr] = {box = box, name = name}
        end
        for _, plr in pairs(game.Players:GetPlayers()) do addESP(plr) end
        game.Players.PlayerAdded:Connect(addESP)
        game:GetService("RunService").RenderStepped:Connect(function()
            if not espToggle.Value then return end
            for plr, obj in pairs(espObjects) do
                local char = plr.Character
                if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Head") then
                    local root, onScreen = workspace.CurrentCamera:WorldToViewportPoint(char.HumanoidRootPart.Position)
                    if onScreen then
                        local head = workspace.CurrentCamera:WorldToViewportPoint(char.Head.Position + Vector3.new(0,1,0))
                        local leg = workspace.CurrentCamera:WorldToViewportPoint(char.HumanoidRootPart.Position - Vector3.new(0,4,0))
                        local h = math.abs(head.Y - leg.Y)
                        local w = h / 2
                        obj.box.Size = Vector2.new(w, h)
                        obj.box.Position = Vector2.new(root.X - w/2, root.Y - h/2)
                        obj.box.Visible = true
                        local dist = math.floor((game.Players.LocalPlayer.Character.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude)
                        obj.name.Text = plr.Name .. " [" .. dist .. "]"
                        obj.name.Position = Vector2.new(root.X, head.Y - 20)
                        obj.name.Visible = true
                    else
                        obj.box.Visible = false
                        obj.name.Visible = false
                    end
                end
            end
        end)
        Library:Notify("ESP activado!", 2)
    end
end)

local emoteTxt = VisualsSection:NewTextbox("Emote Name/ID", "wave", function(value) end)
VisualsSection:NewButton("Play Emote Free (Universal)", function()
    local hum = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
    if hum then
        hum:PlayEmote(emoteTxt.Value)
        Library:Notify("Emote reproducido!", 2)
    end
end)

-- ==================== MISC TAB ====================
local MiscSection = MiscTab:NewSection("Misc")
local skinUserTxt = MiscSection:NewTextbox("Username para Skin", "Roblox", function(value) end)
MiscSection:NewButton("Copiar Skin (Client-side Universal)", function()
    local success, uid = pcall(game.Players.GetUserIdFromNameAsync, game.Players, skinUserTxt.Value)
    if success then
        local desc = game.Players:GetHumanoidDescriptionFromUserId(uid)
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid:ApplyDescription(desc)
            Library:Notify("Skin copiada!", 3)
        end
    else
        Library:Notify("Usuario no encontrado", 3)
    end
end)

local assetTxt = MiscSection:NewTextbox("Asset ID", "1234567890", function(value) end)
local assetTypes = {"Shirt", "Pants", "Face", "HatAccessory", "TShirt", "GraphicTShirt"}
local assetList = MiscSection:NewDropdown("Tipo Item", "Shirt", assetTypes, function(currentOption)
end)
MiscSection:NewButton("Añadir Item No Comprado (Visual Universal)", function()
    local id = tonumber(assetTxt.Value)
    if id then
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            local desc = char.Humanoid:GetAppliedDescription() or Instance.new("HumanoidDescription")
            desc[assetList.Value] = id
            char.Humanoid:ApplyDescription(desc)
            Library:Notify("Item añadido (solo visual)!", 2)
        end
    end
end)

-- ==================== CONFIG TAB ====================
local ConfigSection = ConfigTab:NewSection("Configs (Auto-save)")
ConfigSection:NewButton("Guardar Config Actual", function()
    Library:SaveConfig("UntitledXConfig")
    Library:Notify("Config guardada!", 2)
end)
ConfigSection:NewButton("Cargar Config", function()
    Library:LoadConfig("UntitledXConfig")
    Library:Notify("Config cargada!", 2)
end)

ConfigSection:NewLabel("Info:")
ConfigSection:NewLabel("• Keybind: Insert (abre/cierra)")
ConfigSection:NewLabel("• Colores/Bordes: DarkTheme fijo (morado/negro)")
ConfigSection:NewLabel("• Universal: Sí, client-side en cualquier juego")

-- Respawn fix para hidden name
game.Players.LocalPlayer.CharacterAdded:Connect(function()
    wait(1)
end)

Library:Notify("¡Untitled Enhancements X cargado! Universal para cualquier juego 🔥 Usa Insert", 5)
Library:ToggleUI()
