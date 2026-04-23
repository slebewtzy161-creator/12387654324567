if not game:IsLoaded() then
    game.Loaded:Wait()
end

local success, err = pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/slebewtzy161-creator/12387654324567/main/LUNARIS.lua"))()
end)

if not success then
    warn("Failed load LUNARIS:", err)
end
