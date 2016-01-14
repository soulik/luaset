local set = require 'set'

local genMt = {
    __hash = function(v)
		assert(type(v)=='table' and type(v.x)=='number' and type(v.y)=='number' and type(v.z)=='number', 'Invalid element')
		return ('%f_%f_%f'):format(v.x, v.y, v.z)
    end,
	__tostring = function(v)
		return ('(%4.4f, %4.4f, %4.4f)'):format(v.x, v.y, v.z)
	end,
}

local function gen(t)
	assert(type(t)=='table')
	local out = {
		x = t[1] or 0,
		y = t[2] or 0,
		z = t[3] or 0,
	}
	setmetatable(out, genMt)
	return out
end

local A = set.new {gen {1,1,1}, gen {1,2,1}, gen {2,1,3}}
local B = set.new {gen {1,2,1}, gen {1,2,3}, gen {1,1,1}, gen {2,2,3}}
local C = A - B
B = B + A + {gen {3,1,1}}

local D = A * B

-- conditional filter AND
local E = B.whereAnd {x = 1, y = 2}
-- conditional filter OR
local F = B.whereOr {x = 1, y = 2}
-- custom conditional filter
local G = B % function(element)
	return element.x >= 2
end

assert(#A == 3)
assert(#B == 6)
assert(#C == 1)
assert(#E == 2)
assert(#F == 4)
assert(#G == 3)

for k,v in ipairs(D) do
	print(k, v)
end
