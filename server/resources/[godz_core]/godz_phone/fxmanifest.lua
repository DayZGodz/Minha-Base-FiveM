fx_version 'cerulean'
game 'gta5'

author 'Familía God Dev Team'
description 'God-Phone: O celular mais avançado do FiveM com IA Integrada'
version '1.0.0'

ui_page 'html/index.html'

client_scripts {
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    '@vrp/lib/utils.lua',
    'server.lua'
}

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/assets/*'
}

lua54 'yes'
