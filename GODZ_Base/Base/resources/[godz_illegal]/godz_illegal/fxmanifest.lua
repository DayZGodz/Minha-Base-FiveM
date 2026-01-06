fx_version 'bodacious'
game 'gta5'

description 'GODZ Ecosystem - Illegal System'
version '1.0.0'

ui_page 'nui/index.html'

files {
    'nui/index.html',
    'nui/style.css',
    'nui/script.js',
    'nui/img/*.png'
}

client_scripts {
    'config.lua',
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'config.lua',
    'server.lua'
}

dependencies {
    'godz_inventory',
    'godz_logs',
    'godz_target'
}
