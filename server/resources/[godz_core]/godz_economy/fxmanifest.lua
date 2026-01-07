fx_version 'bodacious'
game 'gta5'

author 'Godz AI'
description 'Godz Economy System with AI Integration'
version '1.0.0'

server_scripts {
    '@vrp/lib/utils.lua',
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

dependencies {
    'oxmysql',
    'vrp'
}
