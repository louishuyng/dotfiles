return function(...)
  local temp = {}
  local index = 1
  local result = {}

  math.randomseed(os.time())

  for i, tbl in ipairs({ ... }) do
    for k, v in pairs(tbl) do
      if type(k) == 'number' then
        -- randomize numeric keys
        k = math.random() * i * k
      end

      temp[k] = v
    end
  end

  for k, v in pairs(temp) do
    if type(k) == "number" then
      -- Sort numeric keys into order
      if result[index] then index = index + 1 end

      k = index
    end

    result[k] = v
  end

  return result
end
