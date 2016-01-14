local sha1 = require 'sha1'
local ti, ts = table.insert, table.sort

local _hash, _HMAC = sha1.binary, sha1.hmac_binary

local HMAC_IV = "1234567890"

local function _getElementHash(element)
	local mt = getmetatable(v)
	if type(mt)=='table' and type(mt.__hash)=='function' then
		return mt.__hash(v)
	else
		assert(type(_hash)=='function', 'Invalid hash function')
		return _hash(tostring(element))
	end
end

local function _compareElements(a, b)
	return tostring(a) < tostring(b)
end

local function new(initialElements, getElementHash, compareElements)
	local obj = {}

	local elements = {}
	local index = {}

	local checkSum = ""
	local checkSumIV = sha1.binary(HMAC_IV)
	local elementsCount = 0

	local getElementHash = getElementHash or _getElementHash
	local compareElements = compareElements or _compareElements

	local function sort()
		if compareElements ~= _compareElements then
			print(compareElements, _compareElements)
			ts(elements, compareElements)
		end
	end

	local function rehash()
		assert(type(_HMAC)=='function', 'Invalid HMAC function')

		local getElementHash = obj.hash
		local out = checkSumIV
		index = {}
		sort()

		for i,v in ipairs(elements) do
			local hash = getElementHash(v)

			index[hash] = i
			out = _HMAC(out, hash)
		end
		checkSum = out
	end

	local function init(initialElements)
		for _,v in ipairs(initialElements) do
			ti(elements, v)
		end
		rehash()
		elementsCount = #elements
	end

	local function clone()
		return new(elements, getElementHash, compareElements)
	end

	local function getElement(_, index)
		if index=='hash' then
			return getElementHash
		elseif index=='compare' then
			return compareElements
		else
			return elements[index]
		end
	end

	local function setElement(_, k, v)
		if k=='hash' then
			assert(type(v)=='function', 'Invalid hash function')
			getElementHash = v
			rehash()
		elseif k=='compare' then
			assert(type(v)=='function', 'Invalid compare function')
			compareElements = v
			sort()
		end
	end

	local function hasElement(element)
		local hash = getElementHash(element)
		return type(index[hash])=='number'
	end; obj.has = hasElement

	local function new2(t, a, b)
		return new(t, (a.hash ~= _getElementHash) and a.hash or b.hash, (a.compare ~= _compareElements) and a.compare or b.compare)
	end

	local function addElements(a, b)
		assert(type(a)=='table', 'Invalid argument type on the left side')
		assert(type(b)=='table', 'Invalid argument type on the right side')
		local out = {}

		if type(a.has)=='function' and type(b.has)=='function' then
			local has = a.has

			if (a.checkSum() ~= b.checkSum()) then
				for _,v in ipairs(a) do
					ti(out, v)
				end
				for _,v in ipairs(b) do
					if not has(v) then
						ti(out, v)
					end
				end

				return new2(out, a, b)
	    	else
	    		return a()
	    	end
		elseif type(a.has)=='function' then
			local has = a.has

			for _,v in ipairs(a) do
				ti(out, v)
			end
			for _,v in ipairs(b) do
				if not has(v) then
					ti(out, v)
				end
			end

			return new(out, a.hash, a.compare)
		elseif type(b.has)=='function' then
			local has = b.has

			for _,v in ipairs(b) do
				ti(out, v)
			end
			for _,v in ipairs(a) do
				if not has(v) then
					ti(out, v)
				end
			end

			return new(out, b.hash, b.compare)
		else
			error('Invalid arguments')
		end
	end

	local function subtractElements(a, b)
		assert(type(a)=='table', 'Invalid argument type on the left side')
		assert(type(b)=='table', 'Invalid argument type on the right side')
		local out = {}

		if type(a.has)=='function' and type(b.has)=='function' then
			if (a.checkSum() ~= b.checkSum()) then
				for _,v in ipairs(a) do
					if not b.has(v) then
						ti(out, v)
					end
				end	
			end
        	return new2(out, a, b)
		elseif type(a.has)=='function' then
			local index = {}
			local getElementHash = a.hash

			for i,v in ipairs(b) do
				index[getElementHash(v)] = i
			end

			for _,v in ipairs(a) do
				local hash = getElementHash(v)

				if type(index[hash])~='number' then
					ti(out, v)
				end
			end

			return new(out, a.hash, a.compare)
		elseif type(b.has)=='function' then
			local index = {}
			local getElementHash = b.hash

			for i,v in ipairs(a) do
				index[getElementHash(v)] = i
			end

			for _,v in ipairs(b) do
				local hash = getElementHash(v)

				if type(index[hash])~='number' then
					ti(out, v)
				end
			end

			return new(out, b.hash, b.compare)
		else
			error('Invalid arguments')
		end
	end

	local function commonElements(a, b)
		assert(type(a)=='table', 'Invalid argument type on the left side')
		assert(type(b)=='table', 'Invalid argument type on the right side')
		local out = {}

		if type(a.has)=='function' and type(b.has)=='function' then
			if (a.checkSum() ~= b.checkSum()) then
				for _,v in ipairs(a) do
					if b.has(v) then
						ti(out, v)
					end
				end	
			end

			return new2(out, a, b)
		elseif type(a.has)=='function' then
			local index = {}
			local getElementHash = a.hash

			for i,v in ipairs(b) do
				index[getElementHash(v)] = i
			end

			for _,v in ipairs(a) do
				local hash = getElementHash(v)

				if type(index[hash])=='number' then
					ti(out, v)
				end
			end

			return new(out, a.hash, a.compare)
		elseif type(b.has)=='function' then
			local index = {}
			local getElementHash = b.hash

			for i,v in ipairs(a) do
				index[getElementHash(v)] = i
			end

			for _,v in ipairs(b) do
				local hash = getElementHash(v)

				if type(index[hash])=='number' then
					ti(out, v)
				end
			end

			return new(out, b.hash, b.compare)
		else
			error('Invalid arguments')
		end
	end

	local function operateOnElements(_, fn)
		assert(type(fn)=='function', 'Function argument expected')
		for _,v in ipairs(elements) do
			fn(v)
		end
	end

	local function filterElements(_, fn)
		assert(type(fn)=='function', 'Function argument expected')
		local out = {}

		for _,v in ipairs(elements) do
			if fn(v) then
				ti(out, v)
			end
		end

		return new(out, getElementHash, compareElements)
	end

	local function pairsIterator(_)
		return pairs(elements)
	end

	local function ipairsIterator(_)
		return ipairs(elements)
	end

	local function getElementsCount(_)
		return elementsCount
	end

	local function setComparator(a, b)
		assert(type(a)=='table' and type(a.checkSum)=='function', 'Invalid operand type on the left side')
		assert(type(b)=='table' and type(b.checkSum)=='function', 'Invalid operand type on the right side')
		return a.checkSum() == b.checkSum()
	end

	local function lessThan(a, b)
		assert(type(a)=='table', 'Invalid operand type on the left side')
		assert(type(b)=='table', 'Invalid operand type on the right side')
		return #a < #b
	end
	
	local function lessThanOrEqual(a, b)
		assert(type(a)=='table', 'Invalid operand type on the left side')
		assert(type(b)=='table', 'Invalid operand type on the right side')
		return #a <= #b
	end

	obj.checkSum = function()
		return checkSum
	end

	obj.whereAnd = function(t)
		assert(type(t)=='table', 'Table argument expected')
		
		return obj % function(v)
			for pk, pv in pairs(t) do
				if v[pk] ~= pv then
					return false
				end
			end
			return true
		end
	end

	obj.whereOr = function(t)
		assert(type(t)=='table', 'Table argument expected')

		return obj % function(v)
			for pk, pv in pairs(t) do
				if v[pk] == pv then
					return true
				end
			end
			return false
		end
	end

	setmetatable(obj, {
		__index = getElement,
		__newindex = setElement,
		__len = getElementsCount,

		__add = addElements,
		__sub = subtractElements,
		__mul = commonElements,
		__div = operateOnElements,
		__mod = filterElements,
		__pairs = pairsIterator,
		__ipairs = ipairsIterator,
		__eq = setComparator,
		__lt = lessThan,
		__le = lessThanOrEqual,
		__call = clone,
	})

	if type(initialElements)=='table' then
		init(initialElements)
	end

	return obj
end

return {
	new = new,
	hash = sha1.binary,
	HMAC = sha1.hmac_binary,
}
