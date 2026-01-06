fx_version 'cerulean'
game 'gta5'

author 'GODZ Dev Team'
description 'GODZ Clothing & Uniforms'
version '1.0.0'

files {
    'cfg/uniforms.lua'
}

data_file 'DLC_ITYP_REQUEST' 'stream/godz_clothing.ytyp' -- Exemplo se houver ytyp custom

-- Stream files
files {
    'stream/*.ytd',
    'stream/*.ydd',
    'stream/*.yft',
    'stream/*.ytyp'
}
