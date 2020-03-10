std = "max"
read_globals = {"skynet"}
new_globals = {
    "import", 
    "print",
    }

include_files = {
    "lualib/*",
}

exclude_files = {
    'lualib/test/luaunit.lua',
    'lualib/perf/MemoryReferenceInfo.lua',
    'examples/service/hotfix/mod.lua',
    'lualib/3rd/*',
}

ignore = {
    "211", -- Unused local variable.
    "212", -- Unused argument.
}
