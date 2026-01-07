fx_version 'bodacious'
game 'gta5'

description 'GODZ Ecosystem - Smart Bank'
version '1.0.0'

ui_page 'nui/index.html'

files {
    'nui/index.html',
    'nui/style.css',
    'nui/script.js'
}

client_scripts {
    '@vrp/lib/utils.lua',
    'client.lua'
}

server_scripts {
    '@vrp/lib/utils.lua',
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

dependencies {
    'vrp',
    'oxmysql',
    'godz_target',
    'godz_notify'
}
