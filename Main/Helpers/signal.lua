local function getScript(url)
    print('getScript called with URL:', url)

    if (type(url) ~= 'string') then
        warn('getscript failed 1')
        return
    end

    print('URL is valid, proceeding to fetch script.')

    local baseUrl = 'https://raw.githubusercontent.com/developersecurity-rblx/Roblox-Shit/main/Main/Helpers/'
    print('Base URL:', baseUrl)

    local suc, res = pcall(function()
        local fullUrl = string.format('%s%s.lua', baseUrl, url)
        print('Attempting to fetch script from:', fullUrl)
        return game:HttpGet(fullUrl)
    end)

    if not suc then
        warn('getscript failed 2: HTTP request failed')
        return
    end

    print('Script fetch result:', res)

    if table.find({'404: Not Found', '400: Invalid Request'}, res) then
        warn('getscript failed 2: Invalid response from server')
        return
    end

    print('Response is valid, attempting to load script.')

    local fun, err = loadstring(res, url)
    if not fun then
        warn('getscript syntax err', err)
        return
    end

    print('Script successfully loaded. Executing...')
    return fun()
end

local Signal = getScript('signal');

local Maid = {};
Maid.ClassName = 'Maid';

function Maid.new()
	return setmetatable({
		_tasks = {}
	}, Maid);
end;

function Maid.isMaid(value)
	return type(value) == 'table' and value.ClassName == 'Maid';
end;

function Maid.__index(self, index)
	if (Maid[index]) then
		return Maid[index];
	else
		return self._tasks[index];
	end;
end;

function Maid:__newindex(index, newTask)
	if (Maid[index] ~= nil) then
		error(('"%s" is reserved'):format(tostring(index)), 2);
	end;

	local tasks = self._tasks;
	local oldTask = tasks[index];

	if (oldTask == newTask) then
		return;
	end;

	tasks[index] = newTask;

	if (oldTask) then
		if (type(oldTask) == 'function') then
			oldTask();
		elseif (typeof(oldTask) == 'RBXScriptConnection') then
			oldTask:Disconnect();
		elseif (typeof(oldTask) == 'table') then
			table.clear(oldTask);
		elseif (Signal.isSignal(oldTask)) then
			oldTask:Destroy();
		elseif (typeof(oldTask) == 'thread') then
			task.cancel(oldTask);
		elseif oldTask.Destroy then
			oldTask:Destroy();
		end;
	end;
end;

function Maid:GiveTask(task)
	if (not task) then
		error('Task cannot be false or nil', 2);
	end;

	local taskId = #self._tasks + 1;
	self[taskId] = task;

	return taskId;
end;

function Maid:DoCleaning()
	local tasks = self._tasks

	for index, task in pairs(tasks) do
		if (typeof(task) == 'RBXScriptConnection') then
			tasks[index] = nil;
			task:Disconnect();
		end;
	end;

	local index, taskData = next(tasks);
	while (taskData ~= nil) do
		tasks[index] = nil;
		if (type(taskData) == 'function') then
			taskData()
		elseif (typeof(taskData) == 'RBXScriptConnection') then
			taskData:Disconnect()
		elseif (Signal.isSignal(taskData)) then
			taskData:Destroy();
		elseif (typeof(taskData) == 'table') then
			table.clear(taskData);
		elseif (typeof(taskData) == 'thread') then
			task.cancel(taskData);
		elseif (taskData.Destroy) then
			taskData:Destroy();
		end;

		index, taskData = next(tasks);
	end;
end;

Maid.Destroy = Maid.DoCleaning;

return Maid;