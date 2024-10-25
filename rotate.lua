local luasql = require "luasql.mysql"
local conn = freeswitch.Dbh("db_connection_string")

local db_host = "localhost"
local db_user = "freeswitch"
local db_password = "freeswitch"
local db_name = "caller_id_list"

local env = luasql.mysql()
local conn = env:connect(db_name, db_user, db_password, db_host)

local caller_ids = {}

local cur = conn:execute("SELECT phone_number FROM caller_id_list")
local row = cur:fetch({}, "a")

while row do
    table.insert(caller_ids, row.phone_number)
    row = cur:fetch(row, "a")
end

cur:close()
conn:close()
env:close()

if #caller_ids == 0 then
    freeswitch.consoleLog("ERR", "List Caller ID Empty!\n")
    return
end

math.randomseed(os.time())
local random_index = math.random(1, #caller_ids)
local selected_caller_id = caller_ids[random_index]

session:setVariable("effective_caller_id_number", selected_caller_id)
freeswitch.consoleLog("INFO", "Selected caller ID: " .. selected_caller_id .. "\n")