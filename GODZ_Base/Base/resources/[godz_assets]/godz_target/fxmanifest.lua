fx_version 'cerulean'
game 'gta5'

description 'GODZ Target - Sistema de Interação Avançado'
version '1.0.0'

shared_script 'config.lua'

client_scripts {
    '@vrp/lib/utils.lua',
    'client.lua'
}

ui_page 'nui/index.html'

files {
    'nui/index.html',
    'nui/style.css',
    'nui/script.js',
    'nui/img/*.png',
    'nui/img/*.svg'
}

exports {
    'AddTargetModel',
    'AddTargetEntity',
    'AddTargetCircle',
    'RemoveTargetModel',
    'RemoveTargetEntity',
    'RemoveTargetCircle'
}
