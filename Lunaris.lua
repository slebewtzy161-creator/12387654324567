-- ============================================================
--   LUNARIS  |  Made by Kuuhaku & AI
--   v4.2 -- Auto Search + Result Sorting
-- ============================================================

local TITLE        = "LUNARIS"
local WORDLIST_URL = "https://raw.githubusercontent.com/slebewtzy161-creator/12387654324567/refs/heads/main/samkatwordlist.txt"
local KEYS_URL     = "https://raw.githubusercontent.com/slebewtzy161-creator/12387654324567/refs/heads/main/keys.txt"

-- ============================================================
--   KEY SYSTEM
-- ============================================================
local Players   = game:GetService("Players")
local UIS       = game:GetService("UserInputService")
local TweenSvc  = game:GetService("TweenService")
local player    = Players.LocalPlayer
local pGui      = player:WaitForChild("PlayerGui")

local function fetchKeys()
    local ok, result = pcall(function()
        return game:HttpGet(KEYS_URL, true)
    end)
    if not ok then return {} end
    local keys = {}
    for line in result:gmatch("[^\r\n]+") do
        local k = line:match("^%s*(.-)%s*$")
        if k ~= "" then keys[k] = true end
    end
    return keys
end

local function validateKey(input)
    local keys = fetchKeys()
    return keys[input] == true
end

-- ============================================================
--   KEY UI
-- ============================================================
local KeyGui = Instance.new("ScreenGui", pGui)
KeyGui.Name           = "LunarisKeyGui"
KeyGui.ResetOnSpawn   = false
KeyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Card = Instance.new("Frame", KeyGui)
Card.Size             = UDim2.new(0, 300, 0, 180)
Card.Position         = UDim2.new(0.5, -150, 0.5, -90)
Card.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
Card.BorderSizePixel  = 0
Card.ZIndex           = 11
Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)

-- Title
local CardTitle = Instance.new("TextLabel", Card)
CardTitle.Size                   = UDim2.new(1, 0, 0, 40)
CardTitle.Position               = UDim2.new(0, 0, 0, 0)
CardTitle.BackgroundTransparency = 1
CardTitle.TextColor3             = Color3.fromRGB(180, 180, 255)
CardTitle.Text                   = "LUNARIS"
CardTitle.TextSize               = 18
CardTitle.Font                   = Enum.Font.GothamBold
CardTitle.ZIndex                 = 11

local CardSub = Instance.new("TextLabel", Card)
CardSub.Size                   = UDim2.new(1, 0, 0, 16)
CardSub.Position               = UDim2.new(0, 0, 0, 36)
CardSub.BackgroundTransparency = 1
CardSub.TextColor3             = Color3.fromRGB(100, 100, 130)
CardSub.Text                   = "Enter your access key to continue"
CardSub.TextSize               = 10
CardSub.Font                   = Enum.Font.Gotham
CardSub.ZIndex                 = 11

-- Input box
local KeyInput = Instance.new("TextBox", Card)
KeyInput.Size             = UDim2.new(1, -30, 0, 32)
KeyInput.Position         = UDim2.new(0, 15, 0, 62)
KeyInput.BackgroundColor3 = Color3.fromRGB(28, 28, 42)
KeyInput.TextColor3       = Color3.fromRGB(255, 255, 255)
KeyInput.PlaceholderText  = "Key..."
KeyInput.Text             = ""
KeyInput.TextSize         = 12
KeyInput.Font             = Enum.Font.Gotham
KeyInput.ClearTextOnFocus = false
KeyInput.BorderSizePixel  = 0
KeyInput.ZIndex           = 11
Instance.new("UICorner", KeyInput).CornerRadius = UDim.new(0, 5)

-- Status label
local StatusLabel = Instance.new("TextLabel", Card)
StatusLabel.Size                   = UDim2.new(1, -30, 0, 14)
StatusLabel.Position               = UDim2.new(0, 15, 0, 100)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3             = Color3.fromRGB(100, 100, 130)
StatusLabel.Text                   = ""
StatusLabel.TextSize               = 9
StatusLabel.Font                   = Enum.Font.Gotham
StatusLabel.TextXAlignment         = Enum.TextXAlignment.Left
StatusLabel.ZIndex                 = 11

-- Submit button
local SubmitBtn = Instance.new("TextButton", Card)
SubmitBtn.Size             = UDim2.new(1, -30, 0, 32)
SubmitBtn.Position         = UDim2.new(0, 15, 0, 122)
SubmitBtn.BackgroundColor3 = Color3.fromRGB(50, 80, 200)
SubmitBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
SubmitBtn.Text             = "Activate"
SubmitBtn.TextSize         = 12
SubmitBtn.Font             = Enum.Font.GothamBold
SubmitBtn.BorderSizePixel  = 0
SubmitBtn.ZIndex           = 11
Instance.new("UICorner", SubmitBtn).CornerRadius = UDim.new(0, 5)

-- ============================================================
--   KEY VALIDATION LOGIC
-- ============================================================
local keyValidated = false

local function tryActivate()
    local input = KeyInput.Text:match("^%s*(.-)%s*$")
    if input == "" then
        StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        StatusLabel.Text       = "Please enter a key."
        return
    end

    StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 100)
    StatusLabel.Text       = "Validating..."
    SubmitBtn.Text         = "Checking..."
    SubmitBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)

    task.spawn(function()
        local valid = validateKey(input)
        if valid then
            StatusLabel.TextColor3 = Color3.fromRGB(80, 220, 100)
            StatusLabel.Text       = "Access granted. Loading..."
            SubmitBtn.Text         = "Activated"
            SubmitBtn.BackgroundColor3 = Color3.fromRGB(30, 140, 60)
            keyValidated = true
            task.wait(0.8)
            KeyGui:Destroy()
        else
            StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
            StatusLabel.Text       = "Invalid key. Check your key and try again."
            SubmitBtn.Text         = "Activate"
            SubmitBtn.BackgroundColor3 = Color3.fromRGB(50, 80, 200)
        end
    end)
end

-- Wait for key validation via coroutine to avoid script timeout
local mainThread = coroutine.running()

local function onValidated()
    local co = mainThread
    if co and coroutine.status(co) == "suspended" then
        coroutine.resume(co)
    end
end

-- Patch tryActivate to resume coroutine on success
local _original = tryActivate
tryActivate = function()
    local input = KeyInput.Text:match("^%s*(.-)%s*$")
    if input == "" then
        StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        StatusLabel.Text       = "Please enter a key."
        return
    end
    StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 100)
    StatusLabel.Text       = "Validating..."
    SubmitBtn.Text         = "Checking..."
    SubmitBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    task.spawn(function()
        local valid = validateKey(input)
        if valid then
            StatusLabel.TextColor3 = Color3.fromRGB(80, 220, 100)
            StatusLabel.Text       = "Access granted. Loading..."
            SubmitBtn.Text         = "Activated"
            SubmitBtn.BackgroundColor3 = Color3.fromRGB(30, 140, 60)
            keyValidated = true
            task.wait(0.8)
            KeyGui:Destroy()
            onValidated()
        else
            StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
            StatusLabel.Text       = "Invalid key. Try again."
            SubmitBtn.Text         = "Activate"
            SubmitBtn.BackgroundColor3 = Color3.fromRGB(50, 80, 200)
        end
    end)
end

SubmitBtn.MouseButton1Click:Connect(tryActivate)
KeyInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then tryActivate() end
end)

    -- Key valid — run main script
    task.spawn(function()
        task.wait(0.9)
    -- ============================================================
    --   DEADLY ENDINGS
    --   Min-2 mode prepends "eh" at rank 1.
    -- ============================================================
    local DeadlyEndingsDefault = {
        "eo","oi","lah","ts","tt","lt","x","cy","ty","gy","ly","oy",
        "mp","ks","ao","rp","rb","rd","pp","by","if","yeh"
    }
    local DeadlyEndingsMin2 = {"eh"}
    for _, v in ipairs(DeadlyEndingsDefault) do
        DeadlyEndingsMin2[#DeadlyEndingsMin2 + 1] = v
    end
    
    local DeadlyEndings = DeadlyEndingsDefault
    local DEADLY_COUNT  = #DeadlyEndings
    
    -- ============================================================
    --   BLOCKED WORDS
    -- ============================================================
    local BlockedWords = {
        "xix","xan","xii","xiv","xvi","xiii","xacum",
        "ifikasi","ksif","ksekutif","ksklusif","kskursif",
        "kspansif","ksplosif","kstraktif","ksploratif"
    }
    local BlockedSet = {}
    for _, w in ipairs(BlockedWords) do BlockedSet[w] = true end
    
    -- ============================================================
    --   SETTINGS
    -- ============================================================
    local MIN_LENGTH  = 3
    local SORT_MODE   = "killer"
    local MAX_RESULTS = 50
    local lastText    = ""
    
    -- ============================================================
    --   HELPERS
    -- ============================================================
    local function isCleanWord(word)
        for i = 1, #word do
            local b = string.byte(word, i)
            if b < 97 or b > 122 then return false end
        end
        return true
    end
    
    -- Permanent score using DEFAULT endings, computed once at load.
    local function getDefaultScore(word)
        for rank, ending in ipairs(DeadlyEndingsDefault) do
            local elen = #ending
            if #word >= elen and word:sub(-elen) == ending then
                return rank
            end
        end
        return #DeadlyEndingsDefault + 1
    end
    
    -- Live score using ACTIVE endings (only used for the small matched
    -- pool in killer+Min2 mode, not the full bucket).
    local LiveScoreCache = {}
    local function getLiveScore(word)
        local c = LiveScoreCache[word]
        if c then return c end
        local result = DEADLY_COUNT + 1
        for rank, ending in ipairs(DeadlyEndings) do
            local elen = #ending
            if #word >= elen and word:sub(-elen) == ending then
                result = rank
                break
            end
        end
        LiveScoreCache[word] = result
        return result
    end
    
    -- ============================================================
    --   LOAD WORD LIST
    -- ============================================================
    local raw = ""
    local loadOk, loadErr = pcall(function()
        raw = game:HttpGet(WORDLIST_URL, true)
    end)
    if not loadOk then
        warn("[LUNARIS] Failed to fetch word list: " .. tostring(loadErr))
        raw = ""
    end
    
    -- ============================================================
    --   PRE-BUILT TRI-INDEX
    --   Three separate sorted arrays per first-letter bucket built
    --   once at load. Query time = prefix scan only, no sorting.
    --
    --   IndexKiller   : score asc, len asc, alpha
    --   IndexShortest : len asc,   alpha
    --   IndexLongest  : len desc,  alpha
    -- ============================================================
    local IndexKiller   = {}
    local IndexShortest = {}
    local IndexLongest  = {}
    local Seen          = {}
    local Dictionary    = {}
    
    for line in raw:gmatch("[^\r\n]+") do
        local word = line:lower():match("^%s*(.-)%s*$")
        if word:find("%s") then word = "" end
        if word ~= ""
           and not word:match("^%-%-%")
           and not Seen[word]
           and #word >= 2
           and not BlockedSet[word]
           and isCleanWord(word)
        then
            Seen[word] = true
            local key  = word:sub(1, 1)
            local len  = #word
            local sc   = getDefaultScore(word)
            local entry = { word = word, len = len, sc = sc }
    
            if not IndexKiller[key]   then IndexKiller[key]   = {} end
            if not IndexShortest[key] then IndexShortest[key] = {} end
            if not IndexLongest[key]  then IndexLongest[key]  = {} end
    
            table.insert(IndexKiller[key],   entry)
            table.insert(IndexShortest[key], entry)
            table.insert(IndexLongest[key],  entry)
            table.insert(Dictionary, word)
        end
    end
    
    -- Sort all three indexes once
    for key in pairs(IndexKiller) do
        table.sort(IndexKiller[key], function(a, b)
            if a.sc  ~= b.sc  then return a.sc  < b.sc  end
            if a.len ~= b.len then return a.len < b.len end
            return a.word < b.word
        end)
        table.sort(IndexShortest[key], function(a, b)
            if a.len ~= b.len then return a.len < b.len end
            return a.word < b.word
        end)
        table.sort(IndexLongest[key], function(a, b)
            if a.len ~= b.len then return a.len > b.len end
            return a.word < b.word
        end)
    end
    
    -- ============================================================
    --   SEARCH
    --   Prefix scan on the correct pre-sorted bucket.
    --   Killer+Min2: live-rescore only the small matched pool.
    -- ============================================================
    local searchResults = {}
    
    local function doSearch(query)
        local q = query:lower()
        searchResults = {}
        if #q == 0 then return end
        local isZQuery = (q:sub(1, 1) == "z")
        local firstChar = q:sub(1, 1)
    
        local bucket
        if SORT_MODE == "shortest" then
            bucket = IndexShortest[firstChar]
        elseif SORT_MODE == "longest" then
            bucket = IndexLongest[firstChar]
        else
            bucket = IndexKiller[firstChar]
        end
        if not bucket then return end
    
        local pool = {}
        local qlen = #q
        for _, entry in ipairs(bucket) do
            if entry.word:sub(1, qlen) == q then
                if not isZQuery or entry.len >= 4 then
                    pool[#pool + 1] = entry
                end
            end
        end
    
        -- Killer + Min-2: re-sort the matched pool with live "eh" priority.
        -- Pool is usually small (prefix-filtered), so this is fast.
        if SORT_MODE == "killer" and MIN_LENGTH == 2 then
            local scored = {}
            for i, e in ipairs(pool) do
                scored[i] = { word = e.word, len = e.len, sc = getLiveScore(e.word) }
            end
            table.sort(scored, function(a, b)
                if a.sc  ~= b.sc  then return a.sc  < b.sc  end
                if a.len ~= b.len then return a.len < b.len end
                return a.word < b.word
            end)
            pool = scored
        end
    
        local limit = math.min(#pool, MAX_RESULTS)
        for i = 1, limit do
            searchResults[i] = pool[i]
        end
    end
    
    local function searchAndRender(query)
        doSearch(query)
    end
    
    -- ============================================================
    --   THEMES
    -- ============================================================
    local Themes = {
        {
            name       = "Dark",
            frame      = Color3.fromRGB(20, 20, 30),
            header     = Color3.fromRGB(10, 10, 20),
            headerText = Color3.fromRGB(180, 180, 255),
            search     = Color3.fromRGB(35, 35, 50),
            searchText = Color3.fromRGB(255, 255, 255),
            btnNormal  = Color3.fromRGB(30, 30, 45),
            btnDeadly  = Color3.fromRGB(80, 20, 20),
            txtNormal  = Color3.fromRGB(200, 200, 200),
            txtDeadly  = Color3.fromRGB(255, 100, 100),
            settings   = Color3.fromRGB(15, 15, 25),
            settingsTxt= Color3.fromRGB(200, 200, 255),
            input      = Color3.fromRGB(30, 30, 50),
            sortActive = Color3.fromRGB(70, 90, 200),
            sortIdle   = Color3.fromRGB(40, 40, 60),
        },
        {
            name       = "Light",
            frame      = Color3.fromRGB(240, 240, 245),
            header     = Color3.fromRGB(210, 210, 230),
            headerText = Color3.fromRGB(60, 60, 120),
            search     = Color3.fromRGB(255, 255, 255),
            searchText = Color3.fromRGB(30, 30, 30),
            btnNormal  = Color3.fromRGB(220, 220, 235),
            btnDeadly  = Color3.fromRGB(255, 200, 200),
            txtNormal  = Color3.fromRGB(40, 40, 60),
            txtDeadly  = Color3.fromRGB(180, 30, 30),
            settings   = Color3.fromRGB(225, 225, 240),
            settingsTxt= Color3.fromRGB(50, 50, 100),
            input      = Color3.fromRGB(200, 200, 220),
            sortActive = Color3.fromRGB(80, 100, 210),
            sortIdle   = Color3.fromRGB(170, 170, 200),
        },
        {
            name       = "Midnight",
            frame      = Color3.fromRGB(10, 10, 15),
            header     = Color3.fromRGB(5, 5, 10),
            headerText = Color3.fromRGB(100, 220, 255),
            search     = Color3.fromRGB(20, 20, 30),
            searchText = Color3.fromRGB(100, 220, 255),
            btnNormal  = Color3.fromRGB(15, 15, 25),
            btnDeadly  = Color3.fromRGB(60, 10, 10),
            txtNormal  = Color3.fromRGB(100, 220, 255),
            txtDeadly  = Color3.fromRGB(255, 80, 80),
            settings   = Color3.fromRGB(8, 8, 12),
            settingsTxt= Color3.fromRGB(100, 220, 255),
            input      = Color3.fromRGB(20, 20, 35),
            sortActive = Color3.fromRGB(0, 130, 200),
            sortIdle   = Color3.fromRGB(25, 25, 40),
        },
        {
            name       = "Forest",
            frame      = Color3.fromRGB(15, 30, 20),
            header     = Color3.fromRGB(10, 20, 12),
            headerText = Color3.fromRGB(100, 220, 130),
            search     = Color3.fromRGB(25, 45, 30),
            searchText = Color3.fromRGB(200, 255, 210),
            btnNormal  = Color3.fromRGB(20, 40, 25),
            btnDeadly  = Color3.fromRGB(70, 20, 10),
            txtNormal  = Color3.fromRGB(180, 240, 190),
            txtDeadly  = Color3.fromRGB(255, 100, 80),
            settings   = Color3.fromRGB(10, 22, 14),
            settingsTxt= Color3.fromRGB(100, 220, 130),
            input      = Color3.fromRGB(20, 40, 25),
            sortActive = Color3.fromRGB(30, 130, 60),
            sortIdle   = Color3.fromRGB(25, 50, 30),
        },
    }
    
    local currentThemeIndex = 1
    local currentHeight     = 1.0
    
    -- ============================================================
    --   SERVICES
    -- ============================================================
    -- Services already declared above (key system)
    
    if pGui:FindFirstChild("KamusGui") then pGui.KamusGui:Destroy() end
    
    -- ============================================================
    --   ROOT GUI
    -- ============================================================
    local ScreenGui = Instance.new("ScreenGui", pGui)
    ScreenGui.Name           = "KamusGui"
    ScreenGui.ResetOnSpawn   = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local Frame = Instance.new("Frame", ScreenGui)
    Frame.Size             = UDim2.new(0, 270, 1.0, 0)
    Frame.Position         = UDim2.new(0, 10, 0, 0)
    Frame.BackgroundColor3 = Themes[1].frame
    Frame.BorderSizePixel  = 0
    Frame.Active           = true
    Frame.Draggable        = true
    
    -- ============================================================
    --   HEADER
    -- ============================================================
    local Header = Instance.new("Frame", Frame)
    Header.Size             = UDim2.new(1, 0, 0, 18)
    Header.Position         = UDim2.new(0, 0, 0, 0)
    Header.BackgroundColor3 = Themes[1].header
    Header.BorderSizePixel  = 0
    
    local Indicator = Instance.new("Frame", Header)
    Indicator.Size             = UDim2.new(0, 10, 0, 10)
    Indicator.Position         = UDim2.new(0, 5, 0.5, -5)
    Indicator.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
    Indicator.BorderSizePixel  = 0
    Indicator.ZIndex           = 5
    Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)
    
    local AutoDot = Instance.new("Frame", Header)
    AutoDot.Size             = UDim2.new(0, 10, 0, 10)
    AutoDot.Position         = UDim2.new(0, 18, 0.5, -5)
    AutoDot.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    AutoDot.BorderSizePixel  = 0
    AutoDot.ZIndex           = 5
    Instance.new("UICorner", AutoDot).CornerRadius = UDim.new(1, 0)
    
    local Credit = Instance.new("TextLabel", Header)
    Credit.Size                   = UDim2.new(1, -55, 1, 0)
    Credit.Position               = UDim2.new(0, 32, 0, 0)
    Credit.BackgroundTransparency = 1
    Credit.TextColor3             = Themes[1].headerText
    Credit.Text                   = TITLE
    Credit.TextSize               = 11
    Credit.Font                   = Enum.Font.GothamBold
    Credit.BorderSizePixel        = 0
    
    local GearBtn = Instance.new("TextButton", Header)
    GearBtn.Size                   = UDim2.new(0, 20, 1, 0)
    GearBtn.Position               = UDim2.new(1, -21, 0, 0)
    GearBtn.BackgroundTransparency = 1
    GearBtn.TextColor3             = Themes[1].headerText
    GearBtn.Text                   = "⚙"
    GearBtn.TextSize               = 13
    GearBtn.Font                   = Enum.Font.GothamBold
    GearBtn.BorderSizePixel        = 0
    
    -- ============================================================
    --   AUTO SEARCH STATUS BAR
    -- ============================================================
    local AutoLabel = Instance.new("TextLabel", Frame)
    AutoLabel.Size                   = UDim2.new(1, -10, 0, 16)
    AutoLabel.Position               = UDim2.new(0, 5, 0, 20)
    AutoLabel.BackgroundTransparency = 1
    AutoLabel.TextColor3             = Color3.fromRGB(120, 120, 140)
    AutoLabel.Text                   = "Auto Search: standby"
    AutoLabel.TextSize               = 10
    AutoLabel.Font                   = Enum.Font.GothamBold
    AutoLabel.TextXAlignment         = Enum.TextXAlignment.Left
    AutoLabel.BorderSizePixel        = 0
    
    -- ============================================================
    --   SEARCH BOX
    -- ============================================================
    local SearchBox = Instance.new("TextBox", Frame)
    SearchBox.Size             = UDim2.new(1, -10, 0, 28)
    SearchBox.Position         = UDim2.new(0, 5, 0, 38)
    SearchBox.BackgroundColor3 = Themes[1].search
    SearchBox.TextColor3       = Themes[1].searchText
    SearchBox.PlaceholderText  = "Search prefix...  (press 1)"
    SearchBox.Text             = ""
    SearchBox.TextSize         = 13
    SearchBox.Font             = Enum.Font.Gotham
    SearchBox.ClearTextOnFocus = false
    SearchBox.BorderSizePixel  = 0
    
    -- ============================================================
    --   RESULT LIST
    -- ============================================================
    local Scroll = Instance.new("ScrollingFrame", Frame)
    Scroll.Size                   = UDim2.new(1, -10, 1, -74)
    Scroll.Position               = UDim2.new(0, 5, 0, 70)
    Scroll.BackgroundTransparency = 1
    Scroll.BorderSizePixel        = 0
    Scroll.ScrollBarThickness     = 4
    Scroll.CanvasSize             = UDim2.new(0, 0, 0, 0)
    
    local UIList = Instance.new("UIListLayout", Scroll)
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    UIList.Padding   = UDim.new(0, 2)
    
    local Buttons = {}
    for i = 1, MAX_RESULTS do
        local btn = Instance.new("TextButton", Scroll)
        btn.Size             = UDim2.new(1, 0, 0, 22)
        btn.LayoutOrder      = i
        btn.BackgroundColor3 = Themes[1].btnNormal
        btn.TextColor3       = Themes[1].txtNormal
        btn.TextSize         = 12
        btn.Font             = Enum.Font.Gotham
        btn.BorderSizePixel  = 0
        btn.Text             = ""
        btn.Visible          = false
        btn:SetAttribute("word", "")
        btn:SetAttribute("len", 0)
        btn.MouseButton1Click:Connect(function()
            local w = btn:GetAttribute("word")
            if w ~= "" and setclipboard then setclipboard(w) end
        end)
        Buttons[i] = btn
    end
    
    -- ============================================================
    --   RENDER
    -- ============================================================
    local function renderResults()
        local t          = Themes[currentThemeIndex]
        local killerMode = (SORT_MODE == "killer")
        for i = 1, MAX_RESULTS do
            local btn   = Buttons[i]
            local entry = searchResults[i]
            if entry and #entry.word >= MIN_LENGTH then
                -- Deadly highlight only active in Killer mode
                local isDeadly = killerMode and (getLiveScore(entry.word) <= DEADLY_COUNT)
                btn.Text             = entry.word
                btn.BackgroundColor3 = isDeadly and t.btnDeadly or t.btnNormal
                btn.TextColor3       = isDeadly and t.txtDeadly or t.txtNormal
                btn:SetAttribute("word", entry.word)
                btn:SetAttribute("len",  #entry.word)
                btn.Visible          = true
            else
                btn.Text    = ""
                btn.Visible = false
                btn:SetAttribute("word", "")
                btn:SetAttribute("len",  0)
            end
        end
        Scroll.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y + 4)
    end
    
    -- ============================================================
    --   MIN LENGTH TOGGLE
    -- ============================================================
    local function setMinLength(n)
        MIN_LENGTH = n
        -- Swap active deadly list and clear live cache
        if n == 2 then
            DeadlyEndings = DeadlyEndingsMin2
        else
            DeadlyEndings = DeadlyEndingsDefault
        end
        DEADLY_COUNT   = #DeadlyEndings
        LiveScoreCache = {}
        Indicator.BackgroundColor3 = n == 2
            and Color3.fromRGB(220, 60, 60)
            or  Color3.fromRGB(80, 200, 80)
        -- Re-run search so killer+Min2 re-scores with "eh" priority
        if lastText ~= "" then
            doSearch(lastText)
        end
        for i = 1, MAX_RESULTS do
            local btn = Buttons[i]
            local len = btn:GetAttribute("len")
            if len and len > 0 then
                btn.Visible = len >= MIN_LENGTH
            end
        end
        renderResults()
        Scroll.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y + 4)
    end
    
    -- ============================================================
    --   AUTO SEARCH
    --   Path: MatchUI -> WordServerFrame -> WordServer
    -- ============================================================
    local autoEnabled = true
    local lastPrefix  = ""
    
    local function getWordServerLabel()
        local matchUI = pGui:FindFirstChild("MatchUI")
        if not matchUI then return nil end
        local wsf = matchUI:FindFirstChild("WordServerFrame", true)
        if not wsf then return nil end
        return wsf:FindFirstChild("WordServer", true)
    end
    
    task.spawn(function()
        while true do
            task.wait(0.3)
            if not autoEnabled then
                AutoLabel.Text           = "Auto Search: disabled"
                AutoDot.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            else
                local label = getWordServerLabel()
                if not label then
                    AutoLabel.Text           = "Auto Search: awaiting match..."
                    AutoDot.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
                    lastPrefix = ""
                else
                    local prefix = (label.Text or ""):lower():match("^([a-z]+)")
                    if not prefix or #prefix == 0 then
                        AutoLabel.Text           = "Auto Search: awaiting turn..."
                        AutoDot.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
                        lastPrefix = ""
                    else
                        if prefix ~= lastPrefix then
                            lastPrefix               = prefix
                            SearchBox.Text           = prefix
                            AutoLabel.Text           = "Auto Search: prefix [" .. prefix .. "]"
                            AutoDot.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
                            searchAndRender(prefix)
                            renderResults()
                            Scroll.CanvasPosition    = Vector2.new(0, 0)
                            task.wait(0.05)
                            AutoDot.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
                        end
                    end
                end
            end
        end
    end)
    
    -- ============================================================
    --   SETTINGS PANEL  (ScrollingFrame so it can grow)
    -- ============================================================
    local SettingsPanel = Instance.new("ScrollingFrame", Frame)
    SettingsPanel.Size               = UDim2.new(1, 0, 1, -18)
    SettingsPanel.Position           = UDim2.new(0, 0, 0, 18)
    SettingsPanel.BackgroundColor3   = Themes[1].settings
    SettingsPanel.BorderSizePixel    = 0
    SettingsPanel.Visible            = false
    SettingsPanel.ZIndex             = 5
    SettingsPanel.ScrollBarThickness = 3
    SettingsPanel.CanvasSize         = UDim2.new(0, 0, 0, 480)
    
    local SPLayout = Instance.new("UIListLayout", SettingsPanel)
    SPLayout.SortOrder           = Enum.SortOrder.LayoutOrder
    SPLayout.Padding             = UDim.new(0, 6)
    SPLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    local SPPadding = Instance.new("UIPadding", SettingsPanel)
    SPPadding.PaddingTop    = UDim.new(0, 8)
    SPPadding.PaddingBottom = UDim.new(0, 8)
    
    -- ---- helpers ----
    local function spLabel(text, order)
        local lbl = Instance.new("TextLabel", SettingsPanel)
        lbl.Size                   = UDim2.new(1, -20, 0, 16)
        lbl.BackgroundTransparency = 1
        lbl.TextColor3             = Themes[1].settingsTxt
        lbl.Text                   = text
        lbl.TextSize               = 10
        lbl.Font                   = Enum.Font.GothamBold
        lbl.TextXAlignment         = Enum.TextXAlignment.Left
        lbl.LayoutOrder            = order
        lbl.ZIndex                 = 5
        return lbl
    end
    
    local function spInput(default, order)
        local box = Instance.new("TextBox", SettingsPanel)
        box.Size             = UDim2.new(1, -20, 0, 26)
        box.BackgroundColor3 = Themes[1].input
        box.TextColor3       = Themes[1].settingsTxt
        box.Text             = default
        box.TextSize         = 12
        box.Font             = Enum.Font.Gotham
        box.BorderSizePixel  = 0
        box.ClearTextOnFocus = false
        box.LayoutOrder      = order
        box.ZIndex           = 5
        return box
    end
    
    local function spBtn(text, bg, order)
        local btn = Instance.new("TextButton", SettingsPanel)
        btn.Size             = UDim2.new(1, -20, 0, 26)
        btn.BackgroundColor3 = bg
        btn.TextColor3       = Color3.fromRGB(220, 220, 220)
        btn.Text             = text
        btn.TextSize         = 11
        btn.Font             = Enum.Font.GothamBold
        btn.BorderSizePixel  = 0
        btn.LayoutOrder      = order
        btn.ZIndex           = 5
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 3)
        return btn
    end
    
    local function spDivider(order)
        local d = Instance.new("Frame", SettingsPanel)
        d.Size             = UDim2.new(1, -20, 0, 1)
        d.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        d.BorderSizePixel  = 0
        d.LayoutOrder      = order
        d.ZIndex           = 5
        return d
    end
    
    -- ============================================================
    --   SETTINGS — SECTION 1: Panel Height
    -- ============================================================
    spLabel("PANEL HEIGHT", 10)
    local HeightInput    = spInput("100", 11)
    local ApplyHeightBtn = spBtn("Apply Height", Color3.fromRGB(45, 75, 155), 12)
    spDivider(13)
    
    -- ============================================================
    --   SETTINGS — SECTION 2: Auto Search
    -- ============================================================
    spLabel("AUTO SEARCH", 20)
    local AutoToggleBtn = spBtn("Auto Search  [ON]", Color3.fromRGB(25, 110, 70), 21)
    spDivider(22)
    
    -- ============================================================
    --   SETTINGS — SECTION 3: Result Sorting
    -- ============================================================
    spLabel("RESULT SORTING", 30)
    
    -- Three sort buttons laid out horizontally inside a container
    local SortContainer = Instance.new("Frame", SettingsPanel)
    SortContainer.Size             = UDim2.new(1, -20, 0, 26)
    SortContainer.BackgroundTransparency = 1
    SortContainer.BorderSizePixel  = 0
    SortContainer.LayoutOrder      = 31
    SortContainer.ZIndex           = 5
    
    local SortLayout = Instance.new("UIListLayout", SortContainer)
    SortLayout.FillDirection = Enum.FillDirection.Horizontal
    SortLayout.SortOrder     = Enum.SortOrder.LayoutOrder
    SortLayout.Padding       = UDim.new(0, 4)
    
    local SORT_MODES = { "Shortest", "Longest", "Killer" }
    local SORT_KEYS  = { "shortest", "longest", "killer" }
    local SortBtns   = {}
    
    for i, label in ipairs(SORT_MODES) do
        local btn = Instance.new("TextButton", SortContainer)
        btn.Size             = UDim2.new(0, 72, 1, 0)
        btn.BackgroundColor3 = (SORT_KEYS[i] == SORT_MODE)
            and Themes[1].sortActive
            or  Themes[1].sortIdle
        btn.TextColor3       = Color3.fromRGB(220, 220, 220)
        btn.Text             = label
        btn.TextSize         = 10
        btn.Font             = Enum.Font.GothamBold
        btn.BorderSizePixel  = 0
        btn.LayoutOrder      = i
        btn.ZIndex           = 5
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 3)
        SortBtns[i] = btn
    end
    
    -- Sort description label
    local SortDescLabel = Instance.new("TextLabel", SettingsPanel)
    SortDescLabel.Size                   = UDim2.new(1, -20, 0, 13)
    SortDescLabel.BackgroundTransparency = 1
    SortDescLabel.TextColor3             = Color3.fromRGB(120, 120, 150)
    SortDescLabel.Text                   = "Current: Killer  —  prioritizes trap endings"
    SortDescLabel.TextSize               = 9
    SortDescLabel.Font                   = Enum.Font.Gotham
    SortDescLabel.TextXAlignment         = Enum.TextXAlignment.Left
    SortDescLabel.LayoutOrder            = 32
    SortDescLabel.ZIndex                 = 5
    
    spDivider(33)
    
    -- ============================================================
    --   SETTINGS — SECTION 4: Theme
    -- ============================================================
    spLabel("THEME", 40)
    
    local ThemeContainer = Instance.new("Frame", SettingsPanel)
    ThemeContainer.Size                   = UDim2.new(1, -20, 0, 26)
    ThemeContainer.BackgroundTransparency = 1
    ThemeContainer.BorderSizePixel        = 0
    ThemeContainer.LayoutOrder            = 41
    ThemeContainer.ZIndex                 = 5
    
    local ThemeLayout = Instance.new("UIListLayout", ThemeContainer)
    ThemeLayout.FillDirection = Enum.FillDirection.Horizontal
    ThemeLayout.SortOrder     = Enum.SortOrder.LayoutOrder
    ThemeLayout.Padding       = UDim.new(0, 4)
    
    local ThemeButtons = {}
    local themeNames   = { "Dark", "Light", "Midnight", "Forest" }
    for i, name in ipairs(themeNames) do
        local btn = Instance.new("TextButton", ThemeContainer)
        btn.Size             = UDim2.new(0, 52, 1, 0)
        btn.BackgroundColor3 = (i == 1)
            and Color3.fromRGB(70, 90, 190)
            or  Color3.fromRGB(40, 40, 60)
        btn.TextColor3       = Color3.fromRGB(210, 210, 210)
        btn.Text             = name
        btn.TextSize         = 10
        btn.Font             = Enum.Font.Gotham
        btn.BorderSizePixel  = 0
        btn.LayoutOrder      = i
        btn.ZIndex           = 5
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 3)
        ThemeButtons[i] = btn
    end
    
    -- ============================================================
    --   SORT BUTTON LOGIC
    -- ============================================================
    local sortDescriptions = {
        shortest = "Current: Shortest  —  fewest letters first",
        longest  = "Current: Longest  —  most letters first",
        killer   = "Current: Killer  —  prioritizes trap endings",
    }
    
    local function applySortMode(mode)
        SORT_MODE = mode
        for i, btn in ipairs(SortBtns) do
            btn.BackgroundColor3 = (SORT_KEYS[i] == mode)
                and Themes[currentThemeIndex].sortActive
                or  Themes[currentThemeIndex].sortIdle
        end
        SortDescLabel.Text = sortDescriptions[mode]
        -- Re-run search so results are re-sorted from the full bucket
        if lastText ~= "" then
            doSearch(lastText)
        end
        renderResults()
        Scroll.CanvasPosition = Vector2.new(0, 0)
    end
    
    for i, btn in ipairs(SortBtns) do
        btn.MouseButton1Click:Connect(function()
            applySortMode(SORT_KEYS[i])
        end)
    end
    
    -- ============================================================
    --   APPLY THEME
    -- ============================================================
    local function applyTheme(t)
        Frame.BackgroundColor3         = t.frame
        Header.BackgroundColor3        = t.header
        Credit.TextColor3              = t.headerText
        GearBtn.TextColor3             = t.headerText
        SearchBox.BackgroundColor3     = t.search
        SearchBox.TextColor3           = t.searchText
        SettingsPanel.BackgroundColor3 = t.settings
    
        for _, child in ipairs(SettingsPanel:GetDescendants()) do
            if child:IsA("TextLabel") then
                if child ~= SortDescLabel then
                    child.TextColor3 = t.settingsTxt
                end
            elseif child:IsA("TextBox") then
                child.BackgroundColor3 = t.input
                child.TextColor3       = t.settingsTxt
            end
        end
    
        -- Re-color sort buttons with new theme's sort colors
        for i, btn in ipairs(SortBtns) do
            btn.BackgroundColor3 = (SORT_KEYS[i] == SORT_MODE)
                and t.sortActive
                or  t.sortIdle
        end
    
        for i = 1, MAX_RESULTS do
            local btn = Buttons[i]
            local w   = btn:GetAttribute("word")
            if w and w ~= "" then
                local killerMode = (SORT_MODE == "killer")
                local entry2     = searchResults[i]
                local isDeadly   = killerMode and entry2 and (getLiveScore(entry2.word) <= DEADLY_COUNT)
                btn.BackgroundColor3 = isDeadly and t.btnDeadly or t.btnNormal
                btn.TextColor3       = isDeadly and t.txtDeadly or t.txtNormal
            end
        end
    end
    
    for i, btn in ipairs(ThemeButtons) do
        btn.MouseButton1Click:Connect(function()
            currentThemeIndex = i
            applyTheme(Themes[i])
            for j, b in ipairs(ThemeButtons) do
                b.BackgroundColor3 = (j == i)
                    and Color3.fromRGB(70, 90, 190)
                    or  Color3.fromRGB(40, 40, 60)
            end
        end)
    end
    
    -- ============================================================
    --   AUTO TOGGLE
    -- ============================================================
    local function toggleAuto()
        autoEnabled = not autoEnabled
        if autoEnabled then
            AutoToggleBtn.BackgroundColor3 = Color3.fromRGB(25, 110, 70)
            AutoToggleBtn.Text             = "Auto Search  [ON]"
            lastPrefix = ""
        else
            AutoToggleBtn.BackgroundColor3 = Color3.fromRGB(100, 30, 30)
            AutoToggleBtn.Text             = "Auto Search  [OFF]"
            AutoLabel.Text                 = "Auto Search: disabled"
            AutoDot.BackgroundColor3       = Color3.fromRGB(80, 80, 80)
            lastPrefix = ""
        end
    end
    AutoToggleBtn.MouseButton1Click:Connect(toggleAuto)
    
    -- ============================================================
    --   APPLY HEIGHT
    -- ============================================================
    ApplyHeightBtn.MouseButton1Click:Connect(function()
        local val = tonumber(HeightInput.Text)
        if not val then return end
        val = math.clamp(val, 10, 100)
        HeightInput.Text = tostring(math.floor(val))
        currentHeight    = val / 100
        Frame.Size       = UDim2.new(0, 270, currentHeight, 0)
        Frame.Position   = UDim2.new(0, 10, (1 - currentHeight) / 2, 0)
    end)
    
    -- ============================================================
    --   GEAR TOGGLE
    -- ============================================================
    GearBtn.MouseButton1Click:Connect(function()
        SettingsPanel.Visible = not SettingsPanel.Visible
    end)
    
    -- ============================================================
    --   HOTKEYS
    --   1 = focus search box
    --   2 = min length 2
    --   3 = min length 3
    --   4 = toggle auto search
    --   LCtrl = hide / show panel
    -- ============================================================
    local guiVisible = true
    UIS.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.One   then SearchBox:CaptureFocus() end
        if input.KeyCode == Enum.KeyCode.Two   then setMinLength(2) end
        if input.KeyCode == Enum.KeyCode.Three then setMinLength(3) end
        if input.KeyCode == Enum.KeyCode.Four  then toggleAuto() end
        if input.KeyCode == Enum.KeyCode.LeftControl then
            guiVisible    = not guiVisible
            Frame.Visible = guiVisible
        end
    end)
    
    -- ============================================================
    --   MANUAL SEARCH
    -- ============================================================
    local pendingRender = false
    
    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local txt = SearchBox.Text
        if txt == lastText then return end
        lastText = txt
        searchAndRender(txt)
        if not pendingRender then
            pendingRender = true
            task.defer(function()
                pendingRender = false
                renderResults()
            end)
        end
    end)
    
    -- ============================================================
    --   STARTUP LOG
    -- ============================================================
    print(string.format("[LUNARIS] v4.2 | %d words loaded | sort: %s", #Dictionary, SORT_MODE))
    print("[LUNARIS] Auto Search ready  ->  MatchUI / WordServerFrame / WordServer")
    print("[LUNARIS] Keys: 1=Focus  2=Min2  3=Min3  4=AutoToggle  LCtrl=Hide")
end)
