fx_version 'cerulean'
game 'gta5'

author 'GODZ Team'
description 'GODZ World Events - AI Director'
version '1.0.0'

server_scripts {
    '@vrp/lib/utils.lua',
    'server.lua'
}

client_scripts {
    'client.lua'
}

dependencies {
    'vrp',
    'godz_notify'
}
