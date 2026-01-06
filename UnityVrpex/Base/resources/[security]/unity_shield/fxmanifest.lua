fx_version 'cerulean'
game 'gta5'

author 'Trae AI'
description 'Unity Shield - Sistema de Segurança para vRP'
version '1.0.0'

server_scripts {
    '@vrp/lib/utils.lua',
    'config.lua',
    'server.lua'
}

client_scripts {
    'config.lua',
    'client.lua'
}
