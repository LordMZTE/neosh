-----[[-----------------------------------]]-----
----                                         ----
---        Extended NEOSH Lua stdlib          ---
---     This file is licensed under GPLv3     ---
----                                         ----
-----]]-----------------------------------[[-----

--- @class neosh
local neosh = neosh or {}

--- Return human-readable tables
neosh.inspect = require("inspect")
neosh.prompt = require("neosh.prompt")

--- Pretty print the given objects
neosh.fprint = function(...)
  local args = { ... }
  for _, arg in ipairs(args) do
    print(neosh.inspect(arg))
  end
end

--- Check if string is empty or if it is nil
--- @tparam str string The string to be checked
--- @return boolean
neosh.is_empty = function(str)
  return str == "" or str == nil
end

--- Escape special characters in a string
--- @tparam string str The string to be escaped
--- @return string
neosh.escape_str = function(str)
  local escape_patterns = {
    "%^",
    "%$",
    "%(",
    "%)",
    "%[",
    "%]",
    "%%",
    "%.",
    "%-",
    "%*",
    "%+",
    "%?",
  }

  return str:gsub(("([%s])"):format(table.concat(escape_patterns)), "%%%1")
end

--- Extract the given table keys names and returns them
--- @tparam table tbl The table to extract its keys
--- @return table
neosh.tbl_keys = function(tbl)
  local keys = {}

  for key, _ in pairs(tbl) do
    table.insert(keys, key)
  end

  return keys
end

--- Search if a table contains a value
--- @tparam table tbl The table to look for the given value
--- @tparam any val The value to be looked for
--- @return boolean
neosh.has_value = function(tbl, val)
  for _, value in ipairs(tbl) do
    if value == val then
      return true
    end
  end

  return false
end

--- Search if a table contains a key
--- @tparam table tbl The table to look for the given key
--- @tparam string key The key to be looked for
--- @return boolean
neosh.has_key = function(tbl, key)
  for _, k in ipairs(neosh.tbl_keys(tbl)) do
    if k == key then
      return true
    end
  end

  return false
end

--- Splits a string at N instances of a separator
--- @tparam string str The string to split
--- @tparam string sep The separator to be used when splitting the string
--- @tparam table kwargs Extra arguments:
---         - plain, boolean: pass literal `sep` to `string.find` call
---         - trim_empty, boolean: remove empty items from the returned table
---         - splits, number: number of instances to split the string
--- @return table
neosh.split = function(str, sep, kwargs)
    if not sep then
        sep = "%s"
    end
    kwargs = kwargs or {}
    local plain = kwargs.plain
    local trim_empty = kwargs.trim_empty
    local splits = kwargs.splits or -1

    local str_tbl = {}
    local nField, nStart = 1, 1
    local nFirst, nLast
    if plain then
        nFirst, nLast = str:find(sep, nStart, plain)
    else
        nFirst, nLast = str:find(sep, nStart)
    end

    while nFirst and splits ~= 0 do
        str_tbl[nField] = str:sub(nStart, nFirst - 1)
        nField = nField + 1
        nStart = nLast + 1
        nFirst, nLast = str:find(sep, nStart)
        splits = splits - 1
    end
    str_tbl[nField] = str:sub(nStart)

    if trim_empty then
        for i = #str_tbl, 1, -1 do
          if str_tbl[i] == "" then
            table.remove(str_tbl, i)
          end
        end
    end

    return str_tbl
end

neosh = setmetatable(neosh, {
  __index = function(_, key)
    return function(...)
      local args = { ... }
      local cmd = key
      for _, arg in ipairs(args) do
        cmd = cmd .. " " .. arg
      end
      os.execute(cmd)
    end
  end
})

return neosh

-- vim: sw=4:ts=4:sts=4:tw=100:
