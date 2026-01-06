fx_version 'bodacious'
game 'gta5'

description 'GODZ Ecosystem - Smart Bank'
version '1.0.0'

ui_page 'nui/index.html'

files {
    'nui/index.html',
    'nui/style.css',
    'nui/script.js',
    'nui/img/*.png',
    'nui/fonts/*.ttf'
}

client_scripts {
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

dependencies {
    'godz_target',
    'godz_notify'
}
