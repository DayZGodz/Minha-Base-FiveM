fx_version 'cerulean'
game 'gta5'

description 'GODZ Ecosystem - Target System'
version '1.0.0'

ui_page 'nui/index.html'

files {
    'nui/index.html',
    'nui/style.css',
    'nui/script.js',
    'nui/all.min.css' -- FontAwesome (assuming it's not local, but I linked CDN in html. This line is just in case I download it later)
}

client_scripts {
    'client.lua'
}

exports {
    'AddTargetModel',
    'AddTargetPlayer',
    'AddCircleZone'
}
