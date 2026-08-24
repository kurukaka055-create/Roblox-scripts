local P,W,R,L=game:GetService("Players"),game:GetService("Workspace"),game:GetService("RunService"),game:GetService("Players").LocalPlayer local RS=game:GetService("ReplicatedStorage")
pcall(function()if game.CoreGui:FindFirstChild("MisterXHub")then game.CoreGui.MisterXHub:Destroy()end if L.PlayerGui:FindFirstChild("MisterXHub")then L.PlayerGui.MisterXHub:Destroy()end end)

local ScreenGui=Instance.new("ScreenGui")ScreenGui.Name="MisterXHub" ScreenGui.ResetOnSpawn=false
pcall(function()ScreenGui.Parent=(gethui and gethui())or game.CoreGui or L:WaitForChild("PlayerGui")end)
if not ScreenGui.Parent then ScreenGui.Parent=L:WaitForChild("PlayerGui")end

pcall(function()
    local function fix(p)if p:IsA("ProximityPrompt")then p.HoldDuration=0 end end
    for _,v in ipairs(W:GetDescendants())do fix(v)end
    W.DescendantAdded:Connect(fix)
end)

local AutoBreak,AutoBreakIron,AutoCollect,AutoChopTrees,AutoCollectWood,AutoCollectIron,AutoCollectMeat,AutoCollectEgg,AutoChest,NoclipActive=false,false,false,false,false,false,false,false,false,false
local StoneAura,TreeAura,RapidKillAura=false,false,false
local AuraRange=25 local CustomSpeed=16 local OpChests={}

local function getRem(name)return RS:FindFirstChild("Events",true)and RS.Events:FindFirstChild(name)or RS:FindFirstChild(name,true)end
local attackMobRem=getRem("attackMobRemote")or getRem("attackMob")
local meleeHitRem=getRem("meleeHitRemote")or getRem("meleeHit")
local useToolRem=getRem("useToolRemote")

local function tp(cf,off)pcall(function()local r=L.Character and L.Character:FindFirstChild("HumanoidRootPart")if r then r.Velocity=Vector3.zero r.CFrame=cf+(off or Vector3.new(0,1.5,0))end end)end
local function tpToName(nameSub)for _,obj in ipairs(W:GetDescendants())do if obj.Name:lower():find(nameSub:lower())and not obj:IsDescendantOf(L.Character)then local p=obj:IsA("BasePart")and obj or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart",true)if p and p.Position.Y>-50 then tp(p.CFrame,Vector3.new(0,2,0))return end end end end

local function getTarget(mode)
    local root=L.Character and L.Character:FindFirstChild("HumanoidRootPart")if not root then return nil,nil,nil end
    local nO,nP,tP,mD=nil,nil,nil,math.huge
    local GF=W:FindFirstChild("Game")
    local pool=(mode:find("drop")and GF and GF:FindFirstChild("DroppedItems")and GF.DroppedItems:GetChildren())or(mode=="chest" and GF and GF:FindFirstChild("Chest")and GF.Chest:GetChildren())or(mode:find("solid")and GF and GF:FindFirstChild("Static")and GF.Static:GetChildren())or W:GetChildren()
    for _,obj in ipairs(pool)do
        if obj:IsA("Model")or(mode:find("drop")and obj:IsA("BasePart"))then
            local pN,oN=obj.Parent and obj.Parent.Name:lower()or"",obj.Name:lower()
            local isDrop=pN:find("drop")or oN:find("drop")local m=false
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

task.spawn(function()
    while true do
        local act=false local r=L.Character and L.Character:FindFirstChild("HumanoidRootPart")
        if r then
            local function doMine(m,tLim,off)
                local o,p,pr=getTarget(m)
                if o and p and p.Parent then
                    act=true tp(p.CFrame,off)local t=tick()
                    while(m=="stone_solid" and AutoBreak or m=="iron_solid" and AutoBreakIron or m=="tree_solid" and AutoChopTrees)and o.Parent and p.Parent and(tick()-t<tLim)do
                        if meleeHitRem then pcall(function()meleeHitRem:FireServer({},{o})end)end
                        local tool=L.Character:FindFirstChildOfClass("Tool")if tool then pcall(function()tool:Activate()end)end
                        if pr then pcall(function()fireproximityprompt(pr)end)end
                        task.wait(0.12)
                    end
                end
            end
            local function doLoot(m)
                local o,p,pr=getTarget(m)
                if o and p and p.Parent then
                    act=true tp(p.CFrame,Vector3.new(0,0.5,0))local t=tick()
                    while(m=="stone_drop" and AutoCollect or m=="wood_drop" and AutoCollectWood or m=="iron_drop" and AutoCollectIron or m=="meat_drop" and AutoCollectMeat or m=="egg_drop" and AutoCollectEgg)and o.Parent and p.Parent and(tick()-t<2)do
                        if pr then pcall(function()fireproximityprompt(pr)end)end
                        local cl=o:FindFirstChildWhichIsA("ClickDetector",true)if cl then pcall(function()fireclickdetector(cl)end)end
                        pcall(function()firetouchinterest(r,p,0);firetouchinterest(r,p,1)end)task.wait(0.08)
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
                    act=true tp(p.CFrame,Vector3.new(0,1.2,0))task.wait(0.08)
                    if pr then pcall(function()fireproximityprompt(pr)end)end
                    local cl=o:FindFirstChildWhichIsA("ClickDetector",true)if cl then pcall(function()fireclickdetector(cl)end)end
                    pcall(function()firetouchinterest(r,p,0);firetouchinterest(r,p,1)end)task.wait(1.2)
                    local st=tick()
                    while AutoChest and(tick()-st<2.0)do
                        for _,item in ipairs(W:GetDescendants())do
                            if(item:IsA("Tool")or item:IsA("Model")or item:IsA("BasePart"))and not item:IsDescendantOf(L.Character)then
                                local ip=item:IsA("BasePart")and item or item:FindFirstChildWhichIsA("BasePart",true)
                                if ip and(ip.Position-p.Position).Magnitude<25 then
                                    local icl=item:FindFirstChildWhichIsA("ClickDetector",true)or ip:FindFirstChildWhichIsA("ClickDetector",true)if icl then pcall(function()fireclickdetector(icl)end)end
                                    local ipr=item:FindFirstChildWhichIsA("ProximityPrompt",true)or ip:FindFirstChildWhichIsA("ProximityPrompt",true)if ipr then pcall(function()fireproximityprompt(ipr)end)end
                                    pcall(function()firetouchinterest(r,ip,0);firetouchinterest(r,ip,1)end)
                                    if item:IsA("Tool")then pcall(function()L.Character.Humanoid:EquipTool(item)end)end
                                end
                            end
                        end
                        task.wait(0.12)
                    end
                    OpChests[o]=true task.wait(0.08)
                else tpToName("camp")AutoChest=false end
            end
        end
        task.wait(act and 0.06 or 0.35)
    end
end)

task.spawn(function()
    while true do
        if StoneAura or TreeAura then
            local r=L.Character and L.Character:FindFirstChild("HumanoidRootPart")
            local GF=W:FindFirstChild("Game")
            local pool=(GF and GF:FindFirstChild("Static")and GF.Static:GetChildren())or W:GetChildren()
            if r then
                for _,obj in ipairs(pool)do
                    local oN=obj.Name:lower()local match=false
                    if StoneAura and oN=="stone" then match=true
                    elseif TreeAura and(oN=="tree" or oN=="coconut tree" or oN:find("tree"))then match=true end
                    if match then
                        local part=obj:IsA("BasePart")and obj or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart",true)
                        if part and part.Position.Y>-50 and(part.Position-r.Position).Magnitude<=AuraRange then
                            if meleeHitRem then pcall(function()meleeHitRem:FireServer({},{obj})end)end
                        end
                    end
                end
            end
        end
        task.wait(0.12)
    end
end)

task.spawn(function()
    while true do
        if RapidKillAura then
            local r=L.Character and L.Character:FindFirstChild("HumanoidRootPart")
            local GF=W:FindFirstChild("Game")
            local folder=GF and GF:FindFirstChild("Entities")or W:FindFirstChild("Entities")
            if r and folder then
                for _,mob in ipairs(folder:GetChildren())do
                    local hrp=mob:FindFirstChild("HumanoidRootPart")or mob:FindFirstChildWhichIsA("BasePart")
                    if hrp and(r.Position-hrp.Position).Magnitude<=AuraRange then
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
        task.wait(0.06)
    end
end)

R.Stepped:Connect(function()
    if L.Character and L.Character:FindFirstChild("Humanoid")then
        if CustomSpeed~=16 then L.Character.Humanoid.WalkSpeed=CustomSpeed end
        if NoclipActive then for _,p in ipairs(L.Character:GetDescendants())do if p:IsA("BasePart")then p.CanCollide=false end end end
    end
end)

local Tablet=Instance.new("Frame",ScreenGui)Tablet.Size=UDim2.new(0,540,0,350)Tablet.Position=UDim2.new(0.5,-270,0.25,0)Tablet.BackgroundColor3=Color3.fromRGB(220,230,245)Tablet.Active=true Tablet.Draggable=true Instance.new("UICorner",Tablet).CornerRadius=UDim.new(0,18)
local TabletStroke=Instance.new("UIStroke",Tablet)TabletStroke.Color=Color3.fromRGB(255,255,255)TabletStroke.Thickness=2.5
local Screen=Instance.new("Frame",Tablet)Screen.Size=UDim2.new(1,-12,1,-12)Screen.Position=UDim2.new(0,6,0,6)Screen.BackgroundColor3=Color3.fromRGB(15,20,60)Instance.new("UICorner",Screen).CornerRadius=UDim.new(0,14)
local ScreenGradient=Instance.new("UIGradient",Screen)ScreenGradient.Rotation=65 ScreenGradient.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(0,150,255)),ColorSequenceKeypoint.new(0.45,Color3.fromRGB(30,35,125)),ColorSequenceKeypoint.new(1,Color3.fromRGB(85,20,140))})
local Header=Instance.new("Frame",Screen)Header.Size=UDim2.new(1,0,0,42)Header.BackgroundTransparency=1
local Title=Instance.new("TextLabel",Header)Title.Size=UDim2.new(0.6,0,0.55,0)Title.Position=UDim2.new(0.04,0,0.12,0)Title.BackgroundTransparency=1 Title.Text="MISTER X HUB" Title.TextColor3=Color3.fromRGB(255,255,255)Title.Font=Enum.Font.GothamBold Title.TextSize=15 Title.TextXAlignment=0
local SubTitle=Instance.new("TextLabel",Header)SubTitle.Size=UDim2.new(0.6,0,0.4,0)SubTitle.Position=UDim2.new(0.04,0,0.65,0)SubTitle.BackgroundTransparency=1 SubTitle.Text="ISLAND ESCAPE ULTIMATE" SubTitle.TextColor3=Color3.fromRGB(175,225,255)SubTitle.Font=Enum.Font.GothamMedium SubTitle.TextSize=10 SubTitle.TextXAlignment=0
local CloseBtn=Instance.new("TextButton",Header)CloseBtn.Size=UDim2.new(0,28,0,28)CloseBtn.Position=UDim2.new(0.93,0,0.16,0)CloseBtn.BackgroundColor3=Color3.fromRGB(235,65,85)CloseBtn.Text="✕" CloseBtn.TextColor3=Color3.fromRGB(255,255,255)CloseBtn.Font=Enum.Font.GothamBold CloseBtn.TextSize=12 Instance.new("UICorner",CloseBtn).CornerRadius=UDim.new(0,7)
local MinBtn=Instance.new("TextButton",Header)MinBtn.Size=UDim2.new(0,28,0,28)MinBtn.Position=UDim2.new(0.86,0,0.16,0)MinBtn.BackgroundColor3=Color3.fromRGB(255,255,255)MinBtn.BackgroundTransparency=0.8 MinBtn.Text="—" MinBtn.TextColor3=Color3.fromRGB(255,255,255)MinBtn.Font=Enum.Font.GothamBold MinBtn.TextSize=12 Instance.new("UICorner",MinBtn).CornerRadius=UDim.new(0,7)

local Sidebar=Instance.new("Frame",Screen)Sidebar.Size=UDim2.new(0,145,1,-52)Sidebar.Position=UDim2.new(0,10,0,46)Sidebar.BackgroundColor3=Color3.fromRGB(10,12,35)Sidebar.BackgroundTransparency=0.45 Instance.new("UICorner",Sidebar).CornerRadius=UDim.new(0,10)
local SideStroke=Instance.new("UIStroke",Sidebar)SideStroke.Color=Color3.fromRGB(120,210,255)SideStroke.Transparency=0.7 local SideList=Instance.new("UIListLayout",Sidebar)SideList.Padding=UDim.new(0,6)
local ContentPanel=Instance.new("Frame",Screen)ContentPanel.Size=UDim2.new(1,-175,1,-52)ContentPanel.Position=UDim2.new(0,165,0,46)ContentPanel.BackgroundColor3=Color3.fromRGB(10,12,35)ContentPanel.BackgroundTransparency=0.45 Instance.new("UICorner",ContentPanel).CornerRadius=UDim.new(0,10)
local ContentStroke=Instance.new("UIStroke",ContentPanel)ContentStroke.Color=Color3.fromRGB(120,210,255)ContentStroke.Transparency=0.7

local Pages,TabButtons={},{}
local function showTab(tN)for n,p in pairs(Pages)do p.Visible=(n==tN)end for n,b in pairs(TabButtons)do local a=(n==tN)b.BackgroundTransparency=a and 0.2 or 0.85 b.TextColor3=a and Color3.fromRGB(255,255,255)or Color3.fromRGB(180,210,240)end end
local function addTab(tN,ic)
    local b=Instance.new("TextButton",Sidebar)b.Size=UDim2.new(1,-8,0,36)b.Position=UDim2.new(0,4,0,0)b.BackgroundColor3=Color3.fromRGB(0,160,255)b.BackgroundTransparency=0.85 b.Text="  "..ic.."  "..tN b.TextColor3=Color3.fromRGB(180,210,240)b.Font=Enum.Font.GothamBold b.TextSize=11.5 b.TextXAlignment=0 Instance.new("UICorner",b).CornerRadius=UDim.new(0,8)
    local p=Instance.new("ScrollingFrame",ContentPanel)p.Size=UDim2.new(1,-12,1,-12)p.Position=UDim2.new(0,6,0,6)p.BackgroundTransparency=1 p.ScrollBarThickness=3 p.Visible=false local l=Instance.new("UIListLayout",p)l.Padding=UDim.new(0,8)
    Pages[tN]=p TabButtons[tN]=b b.MouseButton1Click:Connect(function()showTab(tN)end)return p
end

local function addToggle(p,ic,txt,def,cb)
    local s=def local b=Instance.new("TextButton",p)b.Size=UDim2.new(1,0,0,40)b.BackgroundColor3=Color3.fromRGB(255,255,255)b.BackgroundTransparency=s and 0.75 or 0.88 b.Text="" Instance.new("UICorner",b).CornerRadius=UDim.new(0,8)
    local bs=Instance.new("UIStroke",b)bs.Color=s and Color3.fromRGB(0,255,180)or Color3.fromRGB(120,210,255)bs.Transparency=0.5
    local il=Instance.new("TextLabel",b)il.Size=UDim2.new(0,30,1,0)il.Position=UDim2.new(0,8,0,0)il.BackgroundTransparency=1 il.Text=ic il.TextColor3=s and Color3.fromRGB(0,255,180)or Color3.fromRGB(120,220,255)il.TextSize=16 il.Font=Enum.Font.GothamBold
    local tl=Instance.new("TextLabel",b)tl.Size=UDim2.new(1,-75,1,0)tl.Position=UDim2.new(0,40,0,0)tl.BackgroundTransparency=1 tl.Text=txt tl.TextColor3=s and Color3.fromRGB(0,255,180)or Color3.fromRGB(240,250,255)tl.TextSize=11.5 tl.Font=Enum.Font.GothamBold tl.TextXAlignment=0
    local stl=Instance.new("TextLabel",b)stl.Size=UDim2.new(0,32,1,0)stl.Position=UDim2.new(1,-40,0,0)stl.BackgroundTransparency=1 stl.Text=s and"ON" or"OFF" stl.TextColor3=s and Color3.fromRGB(0,255,180)or Color3.fromRGB(160,170,190)stl.TextSize=10.5 stl.Font=Enum.Font.GothamBold
    b.MouseButton1Click:Connect(function()
        s=not s b.BackgroundTransparency=s and 0.75 or 0.88 bs.Color=s and Color3.fromRGB(0,255,180)or Color3.fromRGB(120,210,255)il.TextColor3=s and Color3.fromRGB(0,255,180)or Color3.fromRGB(120,220,255)tl.TextColor3=s and Color3.fromRGB(0,255,180)or Color3.fromRGB(240,250,255)stl.Text=s and"ON" or"OFF" stl.TextColor3=s and Color3.fromRGB(0,255,180)or Color3.fromRGB(160,170,190)cb(s)
    end)return b
end

local function addButton(p,ic,txt,cb)
    local b=Instance.new("TextButton",p)b.Size=UDim2.new(1,0,0,40)b.BackgroundColor3=Color3.fromRGB(255,255,255)b.BackgroundTransparency=0.88 b.Text="" Instance.new("UICorner",b).CornerRadius=UDim.new(0,8)
    local bs=Instance.new("UIStroke",b)bs.Color=Color3.fromRGB(120,210,255)bs.Transparency=0.6
    local il=Instance.new("TextLabel",b)il.Size=UDim2.new(0,30,1,0)il.Position=UDim2.new(0,8,0,0)il.BackgroundTransparency=1 il.Text=ic il.TextColor3=Color3.fromRGB(120,220,255)il.TextSize=16 il.Font=Enum.Font.GothamBold
    local tl=Instance.new("TextLabel",b)tl.Size=UDim2.new(1,-45,1,0)tl.Position=UDim2.new(0,40,0,0)tl.BackgroundTransparency=1 tl.Text=txt tl.TextColor3=Color3.fromRGB(240,250,255)tl.TextSize=11.5 tl.Font=Enum.Font.GothamBold tl.TextXAlignment=0
    b.MouseButton1Click:Connect(function()cb(tl)end)return b
end

local FloatPill=Instance.new("TextButton",ScreenGui)FloatPill.Size=UDim2.new(0,54,0,54)FloatPill.Position=UDim2.new(0.02,0,0.4,0)FloatPill.BackgroundColor3=Color3.fromRGB(15,20,60)FloatPill.Text="X" FloatPill.TextColor3=Color3.fromRGB(0,200,255)FloatPill.TextSize=26 FloatPill.Font=Enum.Font.GothamBlack FloatPill.Visible=false FloatPill.Active=true FloatPill.Draggable=true Instance.new("UICorner",FloatPill).CornerRadius=UDim.new(0,14)
local PillStroke=Instance.new("UIStroke",FloatPill)PillStroke.Color=Color3.fromRGB(0,200,255)PillStroke.Thickness=2
MinBtn.MouseButton1Click:Connect(function()Tablet.Visible=false;FloatPill.Visible=true end)
FloatPill.MouseButton1Click:Connect(function()Tablet.Visible=true;FloatPill.Visible=false end)

CloseBtn.MouseButton1Click:Connect(function()
    AutoBreak,AutoBreakIron,AutoCollect,AutoChopTrees,AutoCollectWood,AutoCollectIron,AutoCollectMeat,AutoCollectEgg,AutoChest,NoclipActive,RapidKillAura=false,false,false,false,false,false,false,false,false,false,false
    StoneAura,TreeAura=false,false CustomSpeed=16
    if L.Character and L.Character:FindFirstChild("Humanoid")then L.Character.Humanoid.WalkSpeed=16 end
    ScreenGui:Destroy()
end)

local HomeTab=addTab("Home","🏠")local MainTab=addTab("Main","⚙️")local FarmingTab=addTab("Farming","⛏️")local PlayerTab=addTab("Player","🏃")local CombatTab=addTab("Combat","⚔️")local TeleportTab=addTab("Teleport","🌀")
addButton(HomeTab,"✨","WELCOME MISTER X",function()end)addButton(HomeTab,"⚡","UNIVERSAL & STABLE",function()end)
addToggle(MainTab,"🔨","STONE BREAK AURA (STATIC)",false,function(s)StoneAura=s end)addToggle(MainTab,"🪓","TREE CHOP AURA",false,function(s)TreeAura=s end)addButton(MainTab,"📏","AURA RANGE (25 STUDS)",function(lbl)if AuraRange==25 then AuraRange=45 elseif AuraRange==45 then AuraRange=70 elseif AuraRange==70 then AuraRange=100 else AuraRange=25 end lbl.Text="AURA RANGE ("..AuraRange.." STUDS)" end)
addToggle(FarmingTab,"🔨","AUTO BREAK PURE STONES",false,function(s)AutoBreak=s end)addToggle(FarmingTab,"⛏️","AUTO BREAK IRON STONES",false,function(s)AutoBreakIron=s end)addToggle(FarmingTab,"🧲","AUTO COLLECT DROPPED STONES",false,function(s)AutoCollect=s end)addToggle(FarmingTab,"🪓","AUTO CHOP TREES",false,function(s)AutoChopTrees=s end)addToggle(FarmingTab,"🪵","AUTO COLLECT DROPPED WOOD",false,function(s)AutoCollectWood=s end)addToggle(FarmingTab,"🔗","AUTO COLLECT DROPPED IRON",false,function(s)AutoCollectIron=s end)addToggle(FarmingTab,"🥩","AUTO COLLECT DROPPED MEAT",false,function(s)AutoCollectMeat=s end)addToggle(FarmingTab,"🥚","AUTO COLLECT DROPPED EGGS",false,function(s)AutoCollectEgg=s end)addToggle(FarmingTab,"📦","FAST AUTO CHEST LOOT",false,function(s)AutoChest=s end)
addButton(PlayerTab,"🚀","OPEN FLY GUI (V3)",function()pcall(function()loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()end)end)addButton(PlayerTab,"⚡","CYCLE SPEED (16 / 32 / 64)",function(lbl)if CustomSpeed==16 then CustomSpeed=32 elseif CustomSpeed==32 then CustomSpeed=64 else CustomSpeed=16 end lbl.Text="CYCLE SPEED ("..CustomSpeed..")" end)addToggle(PlayerTab,"🚶","NOCLIP (NO COLLISION)",false,function(s)NoclipActive=s end)
addToggle(CombatTab,"⚡","RAPID KILL AURA (BURST)",false,function(s)RapidKillAura=s end)
addButton(TeleportTab,"🔥","TP TO CAMPFIRE",function()tpToName("camp")end)addButton(TeleportTab,"🏰","TP TO TOWER CHEST",function()tpToName("tower")end)addButton(TeleportTab,"🪣","TP TO BUCKET",function()tpToName("bucket")end)addButton(TeleportTab,"🧭","TP TO COMPASS",function()tpToName("compass")end)addButton(TeleportTab,"📻","TP TO RADIO",function()tpToName("radio")end)addButton(TeleportTab,"🗺️","TP TO MAP",function()tpToName("map")end)
showTab("Main")
