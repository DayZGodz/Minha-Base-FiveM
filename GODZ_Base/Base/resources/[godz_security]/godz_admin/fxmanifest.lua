fx_version 'cerulean'
game 'gta5'

description 'GODZ Admin - Painel de Gestão de Elite'
version '1.0.0'

shared_script 'config.lua'

client_scripts {
    'client.lua'
}

server_scripts {
    '@vrp/lib/utils.lua',
    'server.lua'
}

ui_page 'nui/index.html'

files {
    'nui/index.html',
    'nui/style.css',
    'nui/script.js',
    'nui/img/*.png'
}
