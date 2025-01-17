Config = {}

Config.Models = { -- Any TV Models used on the map or in locations must be defined here.
    [`des_tvsmash_start`] = {
        DefaultVolume = 0.5,
        Range = 20.0,
        Target = "tvscreen", -- Only use if prop has render-target name.
        Scale = 0.085,
        Offset = vector3(-1.02, -0.055, 1.04)
    },
    [`prop_flatscreen_overlay`] = {
        DefaultVolume = 0.5,
        Range = 20.0,
        Target = "tvscreen", -- Only use if prop has render-target name.
        Scale = 0.085,
        Offset = vector3(-1.02, -0.055, 1.04)
    },
    [`prop_laptop_lester2`] = {
        DefaultVolume = 0.5,
        Range = 20.0,
        Target = "tvscreen", -- Only use if prop has render-target name.
        Scale = 0.085,
        Offset = vector3(-1.02, -0.055, 1.04)
    },
    [`prop_monitor_02`] = {
        DefaultVolume = 0.5,
        Range = 20.0,
        Target = "tvscreen", -- Only use if prop has render-target name.
        Scale = 0.085,
        Offset = vector3(-1.02, -0.055, 1.04)
    },
    [`prop_trev_tv_01`] = {
        DefaultVolume = 0.5,
        Range = 20.0,
        Target = "tvscreen", -- Only use if prop has render-target name.
        Scale = 0.085,
        Offset = vector3(-1.02, -0.055, 1.04)
    },
    [`prop_tv_02`] = {
        DefaultVolume = 0.5,
        Range = 20.0,
        Target = "tvscreen", -- Only use if prop has render-target name.
        Scale = 0.085,
        Offset = vector3(-1.02, -0.055, 1.04)
    },
    [`prop_tv_03_overlay`] = {
        DefaultVolume = 0.5,
        Range = 20.0,
        Target = "tvscreen", -- Only use if prop has render-target name.
        Scale = 0.085,
        Offset = vector3(-1.02, -0.055, 1.04)
    },
    [`prop_tv_06`] = {
        DefaultVolume = 0.5,
        Range = 20.0,
        Target = "tvscreen", -- Only use if prop has render-target name.
        Scale = 0.085,
        Offset = vector3(-1.02, -0.055, 1.04)
    },
    [`prop_tv_flat_01`] = {
        DefaultVolume = 0.5,
        Range = 15.0,
        Target = "tvscreen", -- Only use if prop has render-target name.
        Scale = 0.085,
        Offset = vector3(-1.02, -0.055, 1.04)
    },
    [`xm_prop_x17_tv_flat_02`] = {
        DefaultVolume = 0.5,
        Range = 15.0,
        Scale = 0.085,
        Offset = vector3(-1.02, -0.055, 1.04)
    },
    [`v_ilev_cin_screen`] = {
        DefaultVolume = 1.0,
        Interior = true,
        Target = "cinscreen",
        SoundOffset = vector3(0, -30.0, 0),
        SoundRange = 25.0,
        Range = 50.0,
        Scale = 0.58,
        Offset = vector3(-6.96, -0.55, 3.0)
    },
    [`prop_tv_flat_01_screen`] = {
        DefaultVolume = 0.5,
        Range = 20.0,
        Target = "tvscreen", -- Only use if prop has render-target name.
        Scale = 0.085,
        Offset = vector3(-1.02, -0.055, 1.04)
    },
    [`prop_tv_flat_02b`] = {
        DefaultVolume = 0.5,
        Range = 20.0,
        Target = "tvscreen", -- Only use if prop has render-target name.
        Scale = 0.085,
        Offset = vector3(-1.02, -0.055, 1.04)
    },
    [`prop_tv_flat_03`] = {
        DefaultVolume = 0.5,
        Range = 20.0,
        Target = "tvscreen", -- Only use if prop has render-target name.
        Scale = 0.085,
        Offset = vector3(-1.02, -0.055, 1.04)
    },
    [`prop_tv_flat_03b`] = {
        DefaultVolume = 0.5,
        Range = 20.0,
        Target = "tvscreen", -- Only use if prop has render-target name.
        Scale = 0.085,
        Offset = vector3(-1.02, -0.055, 1.04)
    },
    [`prop_tv_flat_michael`] = {
        DefaultVolume = 0.5,
        Interior = true,
        SameRoom = true,
        Range = 20.0,
        Target = "tvscreen", -- Only use if prop has render-target name.
        Scale = 0.085,
        Offset = vector3(-1.02, -0.055, 1.04)
    },
    [`prop_monitor_w_large`] = {
        DefaultVolume = 0.5,
        Range = 20.0,
        Target = "tvscreen", -- Only use if prop has render-target name.
        Scale = 0.085,
        Offset = vector3(-1.02, -0.055, 1.04)
    },
    [`prop_tv_03`] = {
        DefaultVolume = 0.5,
        Range = 20.0,
        Target = "tvscreen", -- Only use if prop has render-target name.
        Scale = 0.085,
        Offset = vector3(-1.02, -0.055, 1.04)
    },
    [`prop_tv_flat_02`] = {
        DefaultVolume = 0.5,
        Range = 20.0,
        Target = "tvscreen", -- Only use if prop has render-target name.
        Scale = 0.085,
        Offset = vector3(-1.02, -0.055, 1.04)
    },
    [`v_ilev_mm_screen2`] = {
        DefaultVolume = 0.8,
        Range = 30.0,
        Target = "tvscreen", -- Only use if prop has render-target name.
        Scale = 0.085,
        Offset = vector3(-1.02, -0.055, 1.04)
    }
}

Config.Locations = { -- REMOVE ALL IF NOT USING ONESYNC, OR IT SHALL BREAK.
    -- {
    --     Model = `prop_tv_flat_01`,
    --     Position = vector4(144.3038, -1037.4647, 29.4173, 70.1882)
    -- },
    -- {
    --     Model = `prop_tv_flat_01`,
    --     Position = vector4(264.0882, -830.7057, 29.4569, 340.7550)
    -- },
}

Config.Channels = { -- These channels are default channels and cannot be overriden.
    {name = "COPS", url = "https://www.youtube.com/watch?v=MmVJOVuzEvI"},
}

Config.Events = { -- Events for approving broadcasts / interactions (due to popular demand).
    ScreenInteract = function(source, data, key, value, cb) -- cb() to approve.
        if Player(source).state.inJail or Player(source).state.comserv then
            return
        end

        if Player(source).state.insideHouse or IsPlayerAceAllowed(source, "controltv") then
            cb()
        end
    end,
    Broadcast = function(source, data, cb)  -- cb() to approve.
        if Player(source).state.inJail or Player(source).state.comserv then
            return
        end

        if IsPlayerAceAllowed(source, "controltv") then
            cb()
        end
    end,
}