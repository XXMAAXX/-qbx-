fx_version 'cerulean'
game 'gta5'

description 'QBX_Pawnshop'
repository 'https://github.com/Qbox-project/qbx_pawnshop'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
}

client_script 'client/main.lua'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
}

files {
    'config/client.lua',
    'config/shared.lua',
    'locales/*.json'
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'

ox_lib 'locale'
