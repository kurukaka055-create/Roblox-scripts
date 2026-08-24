local P,W,R,L=game:GetService("Players"),game:GetService("Workspace"),game:GetService("RunService"),game:GetService("Players").LocalPlayer local RS=game:GetService("ReplicatedStorage")
pcall(function()if game.CoreGui:FindFirstChild("MisterXHub")then game.CoreGui.MisterXHub:Destroy()end if L.PlayerGui:FindFirstChild("MisterXHub")then L.PlayerGui.MisterXHub:Destroy()end end)

local ScreenGui=Instance.new("ScreenGui")
ScreenGui.Name="MisterXHub"
ScreenGui.ResetOnSpawn=false

pcall(function()
    if syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent=game:GetService("CoreGui")
    elseif gethui then
        ScreenGui.Parent=gethui()
    else
        ScreenGui.Parent=L:WaitForChild("PlayerGui")
    end
end)
if not ScreenGui.Parent then ScreenGui.Parent=L:WaitForChild("PlayerGui") end

local AutoBreak,AutoBreakIron,AutoCollect,AutoChopTrees,AutoCollectWood,AutoCollectIron,AutoCollectMeat,AutoCollectEgg,AutoChest,VoidMobs,NoclipActive=false,false,false,false,false,false,false,false,false,false,false 
local StoneAura,TreeAura,RapidKillAura=false,false,false 
local AuraRange=25 local CustomSpeed=16 local OpChests={}
local MobNames={"bear","snake","spider","shadow","treant","monster","archer","大触手","小触手","站桩章鱼怪","站桩野人弓箭手","章鱼怪","章鱼怪大副","章鱼怪海盗"}

local RemEvents=RS:FindFirstChild("Events",true)or RS
local attackMobRem=RemEvents:FindFirstChild("attackMobRemote")or RemEvents:FindFirstChild("attackMob")
local meleeHitRem=RemEvents:FindFirstChild("meleeHitRemote")or RemEvents:FindFirstChild("meleeHit")
local useToolRem=RemEvents:FindFirstChild("useToolRemote")
local GameFolder=W:FindFirstChild("Game")or W
local EntitiesFolder=GameFolder:FindFirstChild("Entities")or W:FindFirstChild("Entities")
local StaticFolder=GameFolder:FindFirstChild("Static")

local function tp(cf,offset)
    pcall(function()
        local root=L.Character and L.Character:FindFirstChild("HumanoidRootPart")
        if root then root.Velocity=Vector3.zero root.CFrame=cf+(offset or Vector3.new(0,1.5,0))end 
    end)
end 

local function tpToName(nameSub)
    for _,obj in ipairs(W:GetDescendants())do 
        if obj.Name:lower():find(nameSub:lower())and not obj:IsDescendantOf(L.Character)then 
            local p=obj:IsA("BasePart")and obj or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart",true)
            if p and p.Position.Y>-50 then tp(p.CFrame,Vector3.new(0,2,0))return end 
        end 
    end 
end 

local function getTarget(mode)
    local root=L.Character and L.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil,nil,nil end 
    local nO,nP,tP,mD=nil,nil,nil,math.huge 
    local searchPool=(mode:find("drop")and GameFolder:FindFirstChild("DroppedItems")and GameFolder.DroppedItems:GetChildren())or(mode=="chest" and GameFolder:FindFirstChild("Chest")and GameFolder.Chest:GetChildren())or(mode:find("solid")and StaticFolder and StaticFolder:GetChildren())or W:GetDescendants()

    for _,obj in ipairs(searchPool)do 
        if obj:IsA("Model")or(mode:find("drop")and obj:IsA("BasePart"))then 
            local pN=obj.Parent and obj.Parent.Name:lower()or"" 
            local oN=obj.Name:lower()
            local isDrop=pN:find("drop")or oN:find("drop")
            local m=false 
            if mode=="stone_solid" and not isDrop and oN=="stone" and not obj:IsDescendantOf(L.Character)then m=true 
            elseif mode=="iron_solid" and not isDrop and(oN:find("iron")or oN:find("iron ore")or oN:find("iron stone"))and not obj:IsDescendantOf(L.Character)then m=true 
            elseif mode=="tree_solid" and not isDrop and(oN=="tree" or oN=="coconut tree")and not obj:IsDescendantOf(L.Character)then m=true 
            elseif mode=="stone_drop" and isDrop and oN:find("stone")and not obj:IsDescendantOf(L.Character)then m=true 
            elseif mode=="wood_drop" and isDrop and(oN:find("wood")or oN:find("log")or oN:find("branch")or oN:find("stick"))and not obj:IsDescendantOf(L.Character)then m=true 
            elseif mode=="iron_drop" and isDrop and oN:find("iron")and not obj:IsDescendantOf(L.Character)then m=true 
            elseif mode=="meat_drop" and isDrop and(oN:find("meat")or oN:find("food")or oN:find("steak"))and not obj:IsDescendantOf(L.Character)then m=true 
            elseif mode=="egg_drop" and isDrop and oN:find("egg")and not obj:IsDescendantOf(L.Character)then m=true 
            elseif mode=="chest" and not isDrop and(oN:find("chest")or oN:find("crate")or oN:find("box"))and not(oN:find("tower")or pN:find("tower"))and not OpChests[obj]and not obj:IsDescendantOf(L.Character)then m=true end 
            
            if m then 
                local part=obj:IsA("BasePart")and obj or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart",true)
                if part and part.Position.Y>-50 then 
                    local dist=(part.Position-root.Position).Magnitude 
                    if dist<mD and(mode:find("solid")and dist>1.5 or mode:find("drop")or mode=="chest")then 
                        mD=dist nO=obj nP=part tP=obj:FindFirstChildWhichIsA("ProximityPrompt",true)or part:FindFirstChildWhichIsA("ProximityPrompt",true)
                    end 
                end 
            end 
        end 
    end 
    return nO,nP,tP 
end

-- Auto Farming Loop
task.spawn(function()
    while true do 
        local act=false 
        local r=L.Character and L.Character:FindFirstChild("HumanoidRootPart")
        if r then 
            local function doMine(m,tLim,off)
                local o,p,pr=getTarget(m)
                if o and p and p.Parent then 
                    act=true tp(p.CFrame,off)
                    local t=tick()
                    while(m=="stone_solid" and AutoBreak or m=="iron_solid" and AutoBreakIron or m=="tree_solid" and AutoChopTrees)and o.Parent and p.Parent and(tick()-t<tLim)do 
                        if meleeHitRem then pcall(function()meleeHitRem:FireServer({}, {o})end)end 
                        local tool=L.Character:FindFirstChildOfClass("Tool")
                        if tool then pcall(function()tool:Activate()end)end 
                        if pr then pcall(function()fireproximityprompt(pr)end)end 
                        task.wait(0.12)
                    end 
                end 
            end 
            local function doLoot(m)
                local o,p,pr=getTarget(m)
                if o and p and p.Parent then 
                    act=true tp(p.CFrame,Vector3.new(0,0.5,0))
                    local t=tick()
                    while(m=="stone_drop" and AutoCollect or m=="wood_drop" and AutoCollectWood or m=="iron_drop" and AutoCollectIron or m=="meat_drop" and AutoCollectMeat or m=="egg_drop" and AutoCollectEgg)and o.Parent and p.Parent and(tick()-t<2)do 
                        if pr then pcall(function()fireproximityprompt(pr)end)end 
                        local cl=o:FindFirstChildWhichIsA("ClickDetector",true)
                        if cl then pcall(function()fireclickdetector(cl)end)end 
                        pcall(function()firetouchinterest(r,p,0);firetouchinterest(r,p,1)end)
                        task.wait(0.08)
                    end 
                end 
            end 
            if AutoBreak then doMine("stone_solid",12)
            elseif AutoBreakIron then doMine("iron_solid",12)
            elseif AutoChopTrees then doMine("tree_solid",15,Vector3.new(0,1.5,0))
            elseif AutoCollect then doLoot("stone_drop")
            elseif AutoCollectWood then doLoot("wood_drop")
            elseif AutoCollectIron then doLoot("iron_drop")
            elseif AutoCollectMeat then doLoot("meat_drop")
            elseif AutoCollectEgg then doLoot("egg_drop")
            elseif AutoChest then 
                local o,p,pr=getTarget("chest")
                if o and p and p.Parent then 
                    act=true tp(p.CFrame,Vector3.new(0,1.2,0))
                    task.wait(0.08)
                    if pr then pcall(function()fireproximityprompt(pr)end)end 
                    local cl=o:FindFirstChildWhichIsA("ClickDetector",true)
                    if cl then pcall(function()fireclickdetector(cl)end)end 
                    pcall(function()firetouchinterest(r,p,0);firetouchinterest(r,p,1)end)
                    task.wait(1.2)
                    local st=tick()
                    while AutoChest and(tick()-st<2.0)do 
                        for _,item in ipairs(W:GetDescendants())do 
                            if(item:IsA("Tool")or item:IsA("Model")or item:IsA("BasePart"))and not item:IsDescendantOf(L.Character)then 
                                local ip=item:IsA("BasePart")and item or item:FindFirstChildWhichIsA("BasePart",true)
                                if ip and(ip.Position-p.Position).Magnitude<25 then 
                                    local icl=item:FindFirstChildWhichIsA("ClickDetector",true)or ip:FindFirstChildWhichIsA("ClickDetector",true)
                                    if icl then pcall(function()fireclickdetector(icl)end)end 
                                    local ipr=item:FindFirstChildWhichIsA("ProximityPrompt",true)or ip:FindFirstChildWhichIsA("ProximityPrompt",true)
                                    if ipr then pcall(function()fireproximityprompt(ipr)end)end 
                                    pcall(function()firetouchinterest(r,ip,0);firetouchinterest(r,ip,1)end)
                                    if item:IsA("Tool")then pcall(function()L.Character.Humanoid:EquipTool(item)end)end 
                                end 
                            end 
                        end 
                        task.wait(0.12)
                    end 
                    OpChests[o]=true 
                    task.wait(0.08)
                else 
                    tpToName("camp")AutoChest=false 
                end 
            end 
        end 
        task.wait(act and 0.06 or 0.3)
    end 
end)

-- Resource Aura Loop (Lag-Free Optimized)
task.spawn(function()
    while true do 
        if StoneAura or TreeAura then 
            local r=L.Character and L.Character:FindFirstChild("HumanoidRootPart")
            if r then 
                local pool=(StaticFolder and StaticFolder:GetChildren())or W:GetChildren()
                for _,obj in ipairs(pool)do 
                    local oN=obj.Name:lower()
                    local match=false 
                    if StoneAura and oN=="stone" then match=true 
                    elseif TreeAura and(oN=="tree" or oN=="coconut tree" or oN:find("tree"))then match=true end 
                    
                    if match then 
                        local part=obj:IsA("BasePart")and obj or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart",true)
                        if part and part.Position.Y>-50 and(part.Position-r.Position).Magnitude<=AuraRange then 
                            if meleeHitRem then pcall(function()meleeHitRem:FireServer({}, {obj})end)end 
                        end 
                    end 
                end 
            end 
        end 
        task.wait(0.12)
    end 
end)

-- Rapid Kill Aura Loop
task.spawn(function()
    while true do 
        if RapidKillAura then 
            local r=L.Character and L.Character:FindFirstChild("HumanoidRootPart")
            if r then 
                local folder=EntitiesFolder or (GameFolder and GameFolder:FindFirstChild("Entities"))
                if folder then 
                    for _,mob in ipairs(folder:GetChildren())do 
                        local hrp=mob:FindFirstChild("HumanoidRootPart")or mob:FindFirstChildWhichIsA("BasePart")
                        if hrp and (r.Position-hrp.Position).Magnitude<=AuraRange then 
                            for i=1,3 do 
                                pcall(function()
                                    if useToolRem then useToolRem:FireServer()end 
                                    if attackMobRem then attackMobRem:FireServer(mob)end 
                                    if meleeHitRem then meleeHitRem:FireServer(mob,hrp.Position)end 
                                end)
                            end 
                        end 
                    end 
                end 
            end 
        end 
        task.wait(0.06)
    end 
end)

-- Void Mobs Loop
task.spawn(function()
    while true do 
        if VoidMobs then 
            local pool=EntitiesFolder and EntitiesFolder:GetChildren()or W:GetChildren()
            for _,obj in ipairs(pool)do 
                if obj:IsA("Model")and obj~=L.Character then 
                    local name=obj.Name:lower()
                    local isBad=false 
                    for _,bad in ipairs(MobNames)do 
                        if name:find(bad:lower())then isBad=true break end 
                    end 
                    if isBad and not name:find("mrbeast")then 
                        local part=obj:IsA("BasePart")and obj or obj:FindFirstChildWhichIsA("BasePart",true)
                        if part and part.Position.Y>-200 then 
                            pcall(function()
                                part.CFrame=CFrame.new(part.Position.X,-500,part.Position.Z)
                                part.Velocity=Vector3.zero 
                            end)
                        end 
                    end 
                end 
            end 
        end 
        task.wait(0.35)
    end 
end)

-- Character Stepped (Speed + Noclip)
R.Stepped:Connect(function()
    if L.Character and L.Character:FindFirstChild("Humanoid")then 
        if CustomSpeed~=16 then L.Character.Humanoid.WalkSpeed=CustomSpeed end 
        if NoclipActive then 
            for _,part in ipairs(L.Character:GetDescendants())do 
                if part:IsA("BasePart")then part.CanCollide=false end 
            end 
        end 
    end 
end)

-- =====================================================================
--                   EXPANDED TABLET UI (540 x 350)
-- =====================================================================

local Tablet=Instance.new("Frame",ScreenGui)
Tablet.Size=UDim2.new(0,540,0,350)
Tablet.Position=UDim2.new(0.5,-270,0.25,0)
Tablet.BackgroundColor3=Color3.fromRGB(220,230,245)
Tablet.Active=true 
Tablet.Draggable=true 
Instance.new("UICorner",Tablet).CornerRadius=UDim.new(0,18)

local TabletStroke=Instance.new("UIStroke",Tablet)
TabletStroke.Color=Color3.fromRGB(255,255,255)
TabletStroke.Thickness=2.5 

local Screen=Instance.new("Frame",Tablet)
Screen.Size=UDim2.new(1,-12,1,-12)
Screen.Position=UDim2.new(0,6,0,6)
Screen.BackgroundColor3=Color3.fromRGB(15,20,60)
Instance.new("UICorner",Screen).CornerRadius=UDim.new(0,14)

local ScreenGradient=Instance.new("UIGradient",Screen)
ScreenGradient.Rotation=65 
ScreenGradient.Color=ColorSequence.new({
    ColorSequenceKeypoint.new(0,Color3.fromRGB(0,150,255)),
    ColorSequenceKeypoint.new(0.45,Color3.fromRGB(30,35,125)),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(85,20,140))
})

local Header=Instance.new("Frame",Screen)
Header.Size=UDim2.new(1,0,0,42)
Header.BackgroundTransparency=1 

local Title=Instance.new("TextLabel",Header)
Title.Size=UDim2.new(0.6,0,0.55,0)
Title.Position=UDim2.new(0.04,0,0.12,0)
Title.BackgroundTransparency=1 
Title.Text="MISTER X HUB" 
Title.TextColor3=Color3.fromRGB(255,255,255)
Title.Font=Enum.Font.GothamBold 
Title.TextSize=15 
Title.TextXAlignment=0 

local SubTitle=Instance.new("TextLabel",Header)
SubTitle.Size=UDim2.new(0.6,0,0.4,0)
SubTitle.Position=UDim2.new(0.04,0,0.65,0)
SubTitle.BackgroundTransparency=1 
SubTitle.Text="ISLAND ESCAPE ULTIMATE" 
SubTitle.TextColor3=Color3.fromRGB(175,225,255)
SubTitle.Font=Enum.Font.GothamMedium 
SubTitle.TextSize=10 
SubTitle.TextXAlignment=0 

local CloseBtn=Instance.new("TextButton",Header)
CloseBtn.Size=UDim2.new(0,28,0,28)
CloseBtn.Position=UDim2.new(0.93,0,0.16,0)
CloseBtn.BackgroundColor3=Color3.fromRGB(235,65,85)
CloseBtn.Text="✕" 
CloseBtn.TextColor3=Color3.fromRGB(255,255,255)
CloseBtn.Font=Enum.Font.GothamBold 
CloseBtn.TextSize=12 
Instance.new("UICorner",CloseBtn).CornerRadius=UDim.new(0,7)

local MinBtn=Instance.new("TextButton",Header)
MinBtn.Size=UDim2.new(0,28,0,28)
MinBtn.Position=UDim2.new(0.86,0,0.16,0)
MinBtn.BackgroundColor3=Color3.fromRGB(255,255,255)
MinBtn.BackgroundTransparency=0.8 
MinBtn.Text="—" 
MinBtn.TextColor3=Color3.fromRGB(255,255,255)
MinBtn.Font=Enum.Font.GothamBold 
MinBtn.TextSize=12 
Instance.new("UICorner",MinBtn).CornerRadius=UDim.new(0,7)

local Sidebar=Instance.new("Frame",Screen)
Sidebar.Size=UDim2.new(0,145,1,-52)
Sidebar.Position=UDim2.new(0,10,0,46)
Sidebar.BackgroundColor3=Color3.fromRGB(10,12,35)
Sidebar.BackgroundTransparency=0.45 
Instance.new("UICorner",Sidebar).CornerRadius=UDim.new(0,10)

local SideStroke=Instance.new("UIStroke",Sidebar)
SideStroke.Color=Color3.fromRGB(120,210,255)
SideStroke.Transparency=0.7 

local SideList=Instance.new("UIListLayout",Sidebar)
SideList.Padding=UDim.new(0,6)

local ContentPanel=Instance.new("Frame",Screen)
ContentPanel.Size=UDim2.new(1,-175,1,-52)
ContentPanel.Position=UDim2.new(0,165,0,46)
ContentPanel.BackgroundColor3=Color3.fromRGB(10,12,35)
ContentPanel.BackgroundTransparency=0.45 
Instance.new("UICorner",ContentPanel).CornerRadius=UDim.new(0,10)

local ContentStroke=Instance.new("UIStroke",ContentPanel)
ContentStroke.Color=Color3.fromRGB(120,210,255)
ContentStroke.Transparency=0.7

local Pages,TabButtons={},{}
local function showTab(tabName)
    for name,page in pairs(Pages)do page.Visible=(name==tabName)end 
    for name,btn in pairs(TabButtons)do 
        local active=(name==tabName)
        btn.BackgroundTransparency=active and 0.2 or 0.85 
        btn.TextColor3=active and Color3.fromRGB(255,255,255)or Color3.fromRGB(180,210,240)
    end 
end

local function addTab(tabName,icon)
    local btn=Instance.new("TextButton",Sidebar)
    btn.Size=UDim2.new(1,-8,0,36)
    btn.Position=UDim2.new(0,4,0,0)
    btn.BackgroundColor3=Color3.fromRGB(0,160,255)
    btn.BackgroundTransparency=0.85 
    btn.Text="  "..icon.."  "..tabName 
    btn.TextColor3=Color3.fromRGB(180,210,240)
    btn.Font=Enum.Font.GothamBold 
    btn.TextSize=11.5 
    btn.TextXAlignment=0 
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,8)
    
    local page=Instance.new("ScrollingFrame",ContentPanel)
    page.Size=UDim2.new(1,-12,1,-12)
    page.Position=UDim2.new(0,6,0,6)
    page.BackgroundTransparency=1 
    page.ScrollBarThickness=3 
    page.Visible=false 
    local pageLayout=Instance.new("UIListLayout",page)
    pageLayout.Padding=UDim.new(0,8)
    
    Pages[tabName]=page 
    TabButtons[tabName]=btn 
    btn.MouseButton1Click:Connect(function()showTab(tabName)end)
    return page 
end

local function addToggle(page,icon,text,defaultState,callback)
    local state=defaultState 
    local b=Instance.new("TextButton",page)
    b.Size=UDim2.new(1,0,0,40)
    b.BackgroundColor3=Color3.fromRGB(255,255,255)
    b.BackgroundTransparency=state and 0.75 or 0.88 
    b.Text="" 
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,8)
    local bStroke=Instance.new("UIStroke",b)
    bStroke.Color=state and Color3.fromRGB(0,255,180)or Color3.fromRGB(120,210,255)
    bStroke.Transparency=0.5 
    
    local iconL=Instance.new("TextLabel",b)
    iconL.Size=UDim2.new(0,30,1,0)
    iconL.Position=UDim2.new(0,8,0,0)
    iconL.BackgroundTransparency=1 
    iconL.Text=icon 
    iconL.TextColor3=state and Color3.fromRGB(0,255,180)or Color3.fromRGB(120,220,255)
    iconL.TextSize=16 
    iconL.Font=Enum.Font.GothamBold 
    
    local txtL=Instance.new("TextLabel",b)
    txtL.Size=UDim2.new(1,-75,1,0)
    txtL.Position=UDim2.new(0,40,0,0)
    txtL.BackgroundTransparency=1 
    txtL.Text=text 
    txtL.TextColor3=state and Color3.fromRGB(0,255,180)or Color3.fromRGB(240,250,255)
    txtL.TextSize=11.5 
    txtL.Font=Enum.Font.GothamBold 
    txtL.TextXAlignment=0 
    
    local statusL=Instance.new("TextLabel",b)
    statusL.Size=UDim2.new(0,32,1,0)
    statusL.Position=UDim2.new(1,-40,0,0)
    statusL.BackgroundTransparency=1 
    statusL.Text=state and"ON" or"OFF" 
    statusL.TextColor3=state and Color3.fromRGB(0,255,180)or Color3.fromRGB(160,170,190)
    statusL.TextSize=10.5 
    statusL.Font=Enum.Font.GothamBold 
    
    b.MouseButton1Click:Connect(function()
        state=not state 
        b.BackgroundTransparency=state and 0.75 or 0.88 
        bStroke.Color=state and Color3.fromRGB(0,255,180)or Color3.fromRGB(120,210,255)
        iconL.TextColor3=state and Color3.fromRGB(0,255,180)or Color3.fromRGB(120,220,255)
        txtL.TextColor3=state and Color3.fromRGB(0,255,180)or Color3.fromRGB(240,250,255)
        statusL.Text=state and"ON" or"OFF" 
        statusL.TextColor3=state and Color3.fromRGB(0,255,180)or Color3.fromRGB(160,170,190)
        callback(state)
    end)
    return b 
end

local function addButton(page,icon,text,callback)
    local b=Instance.new("TextButton",page)
    b.Size=UDim2.new(1,0,0,40)
    b.BackgroundColor3=Color3.fromRGB(255,255,255)
    b.BackgroundTransparency=0.88 
    b.Text="" 
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,8)
    local bStroke=Instance.new("UIStroke",b)
    bStroke.Color=Color3.fromRGB(120,210,255)
    bStroke.Transparency=0.6 
    
    local iconL=Instance.new("TextLabel",b)
    iconL.Size=UDim2.new(0,30,1,0)
    iconL.Position=UDim2.new(0,8,0,0)
    iconL.BackgroundTransparency=1 
    iconL.Text=icon 
    iconL.TextColor3=Color3.fromRGB(120,220,255)
    iconL.TextSize=16 
    iconL.Font=Enum.Font.GothamBold 
    
    local txtL=Instance.new("TextLabel",b)
    txtL.Size=UDim2.new(1,-45,1,0)
    txtL.Position=UDim2.new(0,40,0,0)
    txtL.BackgroundTransparency=1 
    txtL.Text=text 
    txtL.TextColor3=Color3.fromRGB(240,250,255)
    txtL.TextSize=11.5 
    txtL.Font=Enum.Font.GothamBold 
    txtL.TextXAlignment=0 
    
    b.MouseButton1Click:Connect(function()callback(txtL)end)
    return b 
end

local FloatPill=Instance.new("TextButton",ScreenGui)
FloatPill.Size=UDim2.new(0,54,0,54)
FloatPill.Position=UDim2.new(0.02,0,0.4,0)
FloatPill.BackgroundColor3=Color3.fromRGB(15,20,60)
FloatPill.Text="X" 
FloatPill.TextColor3=Color3.fromRGB(0,200,255)
FloatPill.TextSize=26 
FloatPill.Font=Enum.Font.GothamBlack 
FloatPill.Visible=false 
FloatPill.Active=true 
FloatPill.Draggable=true 
Instance.new("UICorner",FloatPill).CornerRadius=UDim.new(0,14)

local PillStroke=Instance.new("UIStroke",FloatPill)
PillStroke.Color=Color3.fromRGB(0,200,255)
PillStroke.Thickness=2 

MinBtn.MouseButton1Click:Connect(function()Tablet.Visible=false;FloatPill.Visible=true end)
FloatPill.MouseButton1Click:Connect(function()Tablet.Visible=true;FloatPill.Visible=false end)

CloseBtn.MouseButton1Click:Connect(function()
    AutoBreak,AutoBreakIron,AutoCollect,AutoChopTrees,AutoCollectWood,AutoCollectIron,AutoCollectMeat,AutoCollectEgg,AutoChest,VoidMobs,NoclipActive,RapidKillAura=false,false,false,false,false,false,false,false,false,false,false,false 
    StoneAura,TreeAura=false,false 
    CustomSpeed=16 
    if L.Character and L.Character:FindFirstChild("Humanoid")then L.Character.Humanoid.WalkSpeed=16 end 
    ScreenGui:Destroy()
end)

-- Tabs Creation
local HomeTab=addTab("Home","🏠")
local MainTab=addTab("Main","⚙️")
local FarmingTab=addTab("Farming","⛏️")
local PlayerTab=addTab("Player","🏃")
local CombatTab=addTab("Combat","⚔️")
local TeleportTab=addTab("Teleport","🌀")

addButton(HomeTab,"✨","WELCOME MISTER X",function()end)
addButton(HomeTab,"⚡","UNIVERSAL & STABLE",function()end)

addToggle(MainTab,"🔨","STONE BREAK AURA (STATIC)",false,function(s)StoneAura=s end)
addToggle(MainTab,"🪓","TREE CHOP AURA",false,function(s)TreeAura=s end)
addButton(MainTab,"📏","AURA RANGE (25 STUDS)",function(lbl)
    if AuraRange==25 then AuraRange=45 elseif AuraRange==45 then AuraRange=70 elseif AuraRange==70 then AuraRange=100 else AuraRange=25 end 
    lbl.Text="AURA RANGE ("..AuraRange.." STUDS)" 
end)

addToggle(FarmingTab,"🔨","AUTO BREAK PURE STONES",false,function(s)AutoBreak=s end)
addToggle(FarmingTab,"⛏️","AUTO BREAK IRON STONES",false,function(s)AutoBreakIron=s end)
addToggle(FarmingTab,"🧲","AUTO COLLECT DROPPED STONES",false,function(s)AutoCollect=s end)
addToggle(FarmingTab,"🪓","AUTO CHOP TREES",false,function(s)AutoChopTrees=s end)
addToggle(FarmingTab,"🪵","AUTO COLLECT DROPPED WOOD",false,function(s)AutoCollectWood=s end)
addToggle(FarmingTab,"🔗","AUTO COLLECT DROPPED IRON",false,function(s)AutoCollectIron=s end)
addToggle(FarmingTab,"🥩","AUTO COLLECT DROPPED MEAT",false,function(s)AutoCollectMeat=s end)
addToggle(FarmingTab,"🥚","AUTO COLLECT DROPPED EGGS",false,function(s)AutoCollectEgg=s end)
addToggle(FarmingTab,"📦","FAST AUTO CHEST LOOT",false,function(s)AutoChest=s end)

addButton(PlayerTab,"🚀","OPEN FLY GUI (V3)",function()pcall(function()loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()end)end)
addButton(PlayerTab,"⚡","CYCLE SPEED (16 / 32 / 64)",function(lbl)
    if CustomSpeed==16 then CustomSpeed=32 elseif CustomSpeed==32 then CustomSpeed=64 else CustomSpeed=16 end 
    lbl.Text="CYCLE SPEED ("..CustomSpeed..")" 
end)
addToggle(PlayerTab,"🚶","NOCLIP (NO COLLISION)",false,function(s)NoclipActive=s end)

addToggle(CombatTab,"⚡","RAPID KILL AURA (BURST)",false,function(s)RapidKillAura=s end)
addToggle(CombatTab,"👻","VOID HOSTILE ENTITIES",false,function(s)VoidMobs=s end)

addButton(TeleportTab,"🔥","TP TO CAMPFIRE",function()tpToName("camp")end)
addButton(TeleportTab,"🏰","TP TO TOWER CHEST",function()tpToName("tower")end)
addButton(TeleportTab,"🪣","TP TO BUCKET",function()tpToName("bucket")end)
addButton(TeleportTab,"🧭","TP TO COMPASS",function()tpToName("compass")end)
addButton(TeleportTab,"📻","TP TO RADIO",function()tpToName("radio")end)
addButton(TeleportTab,"🗺️","TP TO MAP",function()tpToName("map")end)

showTab("Main")
