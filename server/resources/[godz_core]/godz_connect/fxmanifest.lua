fx_version 'bodacious'
game 'gta5'

description 'GODZ Ecosystem - Loading Screen'
author 'GODZ Dev'
version '1.0.0'

-- loadscreen 'index.html'

server_scripts {
    '@vrp/lib/utils.lua',
    'server.lua'
}
client_script 'client.lua'

-- files {
--     'index.html',
--     'style.css',
--     'script.js',
-- }

loadscreen_manual_shutdown 'yes'
