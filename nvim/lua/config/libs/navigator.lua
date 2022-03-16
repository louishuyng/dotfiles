local present, navigator = pcall(require, "Navigator")

if not (present) then
    return
end

navigator.setup()
