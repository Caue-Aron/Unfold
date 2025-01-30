-- local buddy_fold = require 'buddy_fold'

local collection = {
	name = "main",
	instances = {
		{
			id = "rendy",
			prototype = "/rendy/rendy.go",
			position = {
				y = 4.0,
				z = 5.0,
			},
			rotation = {
				x = -0.30160126,
				w = 0.95343417,
			}
		},
		{
			id = "cube",
			prototype = "/test_chamber/full_level.go",
			position = {
				z = 1.0,
			}
		},
		{
			id = "pillar",
			prototype = "/test_chamber/pillar.go",
		},
		{
			id = "cube1",
			prototype = "/test_chamber/cube.go",
			position = {
				x = -5.0,
			}
		}
	},
	scale_along_z = 0
}

print(debug.getinfo(1, "S").source)

-- err = buddy_fold.TableToCollection(collection, "../example/example.collection")
-- if err then
-- 	print(err)
-- 	return
-- end
