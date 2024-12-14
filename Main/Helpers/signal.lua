local Signal = {};
Signal.__index = Signal;

function Signal.new(name)
	local self = setmetatable({}, Signal);
	self.name = name or "Unnamed Signal";
	self._bindableEvent = Instance.new('BindableEvent');
	self._argData = nil;
	self._argCount = nil;
	return self;
end;

function Signal.isSignal(object)
	return typeof(object) == 'table' and getmetatable(object) == Signal;
end;

function Signal:Fire(...)
	self._argData = {...};
	self._argCount = select("#", ...);
	self._bindableEvent:Fire();

	---@diagnostic disable-next-line: undefined-global
	if (not library.fixSignal) then
		self._argData = nil;
		self._argCount = nil;
	end;
end;

function Signal:Connect(handler)
	if (not self._bindableEvent) then 
		return error('Signal has been destroyed') 
	end;

	if (type(handler) ~= 'function') then
		error(('connect(%s)'):format(typeof(handler)), 2);
	end;

	return self._bindableEvent.Event:Connect(function()
		if self._argData then
			handler(unpack(self._argData, 1, self._argCount));
		else
			warn(("Signal '%s' fired without arguments"):format(self.name));
		end
	end);
end;

function Signal:Wait()
	self._bindableEvent.Event:Wait();
	if self._argData then
		assert(self._argData, 'Missing arg data, likely due to :TweenSize/Position corrupting threadrefs.');
		return unpack(self._argData, 1, self._argCount);
	else
		warn("Signal waited without arguments");
		return nil;
	end
end;

function Signal:Destroy()
	if (self._bindableEvent) then
		self._bindableEvent:Destroy();
		self._bindableEvent = nil;
	end;

	self._argData = nil;
	self._argCount = nil;
end;

return Signal;