LuaSet
======
Indexed set container in plain Lua.

Usage
=====

```lua
local set = require 'set'

local genMt = {
    -- custom hash function for data type
    __hash = function(v)
		assert(type(v)=='table' and type(v.x)=='number' and type(v.y)=='number' and type(v.z)=='number', 'Invalid element')
		return ('%f_%f_%f'):format(v.x, v.y, v.z)
    end,
    -- tostring function for convenience
	__tostring = function(v)
		return ('(%4.4f, %4.4f, %4.4f)'):format(v.x, v.y, v.z)
	end,
}

-- custom element generator
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

-- set A consists of three elements
local A = set.new {gen {1,1,1}, gen {1,2,1}, gen {2,1,3}}
-- set B consists of four elements
local B = set.new {gen {1,2,1}, gen {1,2,3}, gen {1,1,1}, gen {2,2,3}}

-- subtract elements from the set A
local C = A - B

-- set union from A, B and a new element
B = B + A + {gen {3,1,1}}

-- intersect elements
local D = A * B

-- conditional filter AND
local E = B.whereAnd {x = 1, y = 2}

-- conditional filter OR
local F = B.whereOr {x = 1, y = 2}

-- custom conditional filter
local G = B % function(element)
	return element.x >= 2
end
```

Authors
=======
* Mário Kašuba <soulik42@gmail.com>

Copying
=======
Copyright 2016 Mário Kašuba
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

* Redistributions of source code must retain the above copyright
  notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

