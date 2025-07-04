return {
    statusIntervalSeconds = 5, -- how often to check hunger/thirst status to remove health if 0.
    loadingModelsTimeout = 30000, -- Waiting time for ox_lib to load the models before throws an error, for low specs pc

    pauseMapText = 'Bright Moon Community ✨', -- Text shown above the map when ESC is pressed. If left empty 'FiveM' will appear

    characters = {
        useExternalCharacters = false, -- Whether you have an external character management resource. (If true, disables the character management inside the core)
        enableDeleteButton = true, -- Whether players should be able to delete characters themselves.
        startingApartment = true, -- If set to false, skips apartment choice in the beginning (requires qbx_spawn if true)

        dateFormat = 'YYYY-MM-DD',
        dateMin = '1900-01-01', -- Has to be in the same format as the dateFormat config
        dateMax = '2006-12-31', -- Has to be in the same format as the dateFormat config

        limitNationalities = true, -- Setting this to false will allow people to enter whatever they want in the nationality field (To edit the list of nationalities, head to data/nationalities.lua)

        profanityWords = {
            ['bad word'] = true
        },

        locations = { -- Spawn locations for multichar, these are chosen randomly
            {
                pedCoords = vec4(969.25, 72.61, 116.18, 276.55),
                camCoords = vec4(972.2, 72.9, 116.68, 97.27),
            },
            {
                pedCoords = vec4(1104.49, 195.9, -49.44, 44.22),
                camCoords = vec4(1102.29, 198.14, -48.86, 225.07),
            },
            {
                pedCoords = vec4(-2163.87, 1134.51, -24.37, 310.05),
                camCoords = vec4(-2161.7, 1136.4, -23.77, 131.52),
            },
            {
                pedCoords = vec4(-996.71, -68.07, -99.0, 57.61),
                camCoords = vec4(-999.90, -66.30, -98.45, 241.68),
            },
            {
                pedCoords = vec4(-1023.45, -418.42, 67.66, 205.69),
                camCoords = vec4(-1021.8, -421.7, 68.14, 27.11),
            },
            {
                pedCoords = vec4(2265.27, 2925.02, -84.8, 267.77),
                camCoords = vec4(2268.24, 2925.02, -84.36, 90.88),
            },
            {
                pedCoords = vec4(-1004.5, -478.51, 50.03, 28.19),
                camCoords = vec4(-1006.36, -476.19, 50.50, 210.38),
            }
        },
    },

    discord = {
        enabled = true, -- This will enable or disable the built in discord rich presence.

        appId = '1357796661287587981', -- This is the Application ID (Replace this with you own)

        largeIcon = { -- To set this up, visit https://forum.cfx.re/t/how-to-updated-discord-rich-presence-custom-image/157686
            icon = 'Bright Moon Community  ✨', -- Here you will have to put the image name for the 'large' icon.
            text = '#𝙏𝙚𝙖𝙢_𝙊𝙫𝙚𝙧𝙓', -- Here you can add hover text for the 'large' icon.
        },

        smallIcon = {
            icon = '#𝙏𝙚𝙖𝙢_𝙊𝙫𝙚𝙧𝙓', -- Here you will have to put the image name for the 'small' icon.
            text = '#𝙏𝙚𝙖𝙢_𝙊𝙫𝙚𝙧𝙓', -- Here you can add hover text for the 'small' icon.
        },

        firstButton = {
            text = 'Bright Moon Community  ✨',
            link = 'https://discord.gg/FDHqTsFtB4',
        },

        secondButton = {
            text = '#𝙏𝙚𝙖𝙢_𝙊𝙫𝙚𝙧𝙓',
            link = 'https://discord.gg/MeU4xjPsWU',
        }
    },

    --- Only used by QB bridge
    hasKeys = function(plate, vehicle)
        return exports.qbx_vehiclekeys:HasKeys(vehicle)
    end,
}
