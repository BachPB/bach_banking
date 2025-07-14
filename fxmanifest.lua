fx_version "cerulean"
game "gta5"
lua54 "yes"
ui_page "web/build/index.html"

author "Bach"
description "Bach Banking"
version "1.0.0"

client_scripts {
    "client/**/**/**",
}

server_scripts {
    "@mysql-async/lib/MySQL.lua",
    "server/**/**/**",
}

shared_scripts {
    "@ox_lib/init.lua",
    "shared/**/**/**",
}

files {
    "web/build/**/**/**",
}

dependencies {
    "lb-phone",
    "ox_lib",
    "ox_target",
}

escrow_ignore {
    "config.lua",
    "server/*.lua",
}
