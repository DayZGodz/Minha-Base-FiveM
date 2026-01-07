fx_version 'bodacious'
game 'gta5'

description 'GODZ Ecosystem - Notifications'
version '1.0.0'

ui_page 'nui/index.html'

files {
    'nui/index.html',
    'nui/style.css',
    'nui/script.js'
}

client_scripts {
    'client.lua'
}

exports {
    'SendNotification'
}
