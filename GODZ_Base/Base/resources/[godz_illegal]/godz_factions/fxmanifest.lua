fx_version 'cerulean'
game 'gta5'

description 'GODZ Ecosystem - Advanced Faction Management'
version '1.0.0'

ui_page 'nui/index.html'

files {
    'nui/index.html',
    'nui/style.css',
    'nui/script.js',
    'nui/img/*.png' -- Assuming we might have images
}

server_scripts {
    '@vrp/lib/utils.lua',
    'config.lua',
    'server.lua'
}

client_scripts {
    'config.lua',
    'client.lua'
}
