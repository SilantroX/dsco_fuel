fx_version "cerulean"
game "gta5"

author "DSCO-Network (Forked from Andyyy#7666, N1K0#0001)"
description "ESX/QB fuel with hose & nozle"
version "2.0.0"



files {
    "web/*.*"
}

ui_page "web/index.html"

shared_script "config.lua"

server_scripts {
    "server/*.lua"
}
client_scripts {
    "client/main.lua",
    "client/*.lua"
}
