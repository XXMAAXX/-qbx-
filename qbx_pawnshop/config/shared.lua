return {
    pawnLocation = {
        {
            coords = vector3(412.34, 314.81, 103.13),
            size = vector3(1.5, 1.8, 2.0),
            heading = 207.0,
            debugPoly = false,
            distance = 3.0
        }
    },
    pawnItems = {
        {
            item = 'goldchain',
            price = math.random(50, 100)
        },
        {
            item = 'diamond_ring',
            price = math.random(50, 100)
        },
        {
            item = 'rolex',
            price = math.random(50, 100)
        },
        {
            item = '10kgoldchain',
            price = math.random(50, 100)
        },
        {
            item = 'tablet',
            price = math.random(50, 100)
        },
        {
            item = 'iphone',
            price = math.random(50, 100)
        },
        {
            item = 'samsungphone',
            price = math.random(50, 100)
        },
        {
            item = 'laptop',
            price = math.random(50, 100)
        }
    },
    meltingItems = { -- meltTime is amount of time in minutes per item
        {
            item = 'goldchain',
            rewards = {
                {
                    item = 'goldbar',
                    amount = 2
                }
            },
            meltTime = 0.15
        },
        {
            item = 'diamond_ring',
            rewards = {
                {
                    item = 'diamond',
                    amount = 1
                },
                {
                    item = 'goldbar',
                    amount = 1
                }
            },
            meltTime = 0.15
        },
        {
            item = 'rolex',
            rewards = {
                {
                    item = 'diamond',
                    amount = 1
                },
                {
                    item = 'goldbar',
                    amount = 1
                },
                {
                    item = 'electronickit',
                    amount = 1
                }
            },
            meltTime = 0.15
        },
        {
            item = '10kgoldchain',
            rewards = {
                {
                    item = 'diamond',
                    amount = 5
                },
                {
                    item = 'goldbar',
                    amount = 1
                }
            },
            meltTime = 0.15
        },
    }
}