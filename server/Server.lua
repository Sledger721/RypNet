--Default Server Software.
--I created this just to display what a basic piece of server software may look like, when using the net api.
--By: Sledger721
data={}
data_stack={}
stack={}
function split(str, pat) -- Split function, taken from the Lua-Users Wiki.
   local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
	 table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end
function openAll() -- Opens all rednet ports.
rednet.open("top")
rednet.open("left")
rednet.open("right")
rednet.open("back")
end
function fileCheck() -- Makes sure that the file structure is all good.
 if fs.exists("server")==false then
	fs.makeDir("server")
 end
 if fs.exists("server/log")==false then
    logFile=fs.open("server/log","w")
	if type(logFile)==nil then error("ERROR OPENING LOGFILE") else print(type(logFile)) end
	logFile.writeLine("HEADER")
	logFile.close()
 end
 if fs.exists("server/log")==true then -- "Clock|"..os.clock().."|Time|"..os.time().."|"..
	logFile=fs.open("server/log","a")
	logFile.writeLine("Clock|"..os.clock().."|Time|"..os.time().."|STARTUP|")
 end
end
function mainLoop() -- The primary loop within which the system runs.
openAll() -- Openning all ports
fileCheck() -- Making sure that the file structure is in-line
	print("Hosting on: "..os.getComputerID()) -- Printing base commands
	print("E - Exit")
	print("L - Push Logues")
	print("S - Show Stack")
	print("C - Clear Stack")
	print("A - Add Random to Stack")
	print("B - Broadcast Stack")
	print("H - Help")
	print("J - Push Stack Logues")
		while true do -- The infinite loop
			ev,id,msg=os.pullEvent()
			if ev=="rednet_message" then -- If the event is that of a rednet message
				if string.find(msg,"$") and string.find(msg,";") then -- Making sure that it got a command
					data=split(msg,";") -- Break it up by ;
						if data[1]=="$POST" then --$POST;Data
							var={}
							var=split(msg,";")
								table.insert(data_stack,var[2])
									print("Clock|"..os.clock().."|Time|"..os.time().."|"..id.."|$POST|"..tostring(var))
										logFile.writeLine("Clock|"..os.clock().."|Time|"..os.time().."|"..id.."|$POST|"..tostring(var))
						end
						if data[1]=="$GET" then -- $GET, returns the entire data stack.
						  sleep(0.1)
						   serialized_data_stack=textutils.serialize(data_stack)
						   print("Serializing data.")
							rednet.send(id,serialized_data_stack)
								print("Clock|"..os.clock().."|Time|"..os.time().."|"..id.."|$GET|")
									logFile.writeLine("Clock|"..os.clock().."|Time|"..os.time().."|"..id.."|$GET|")
						end
						if data[1]=="$PUT" then -- $PUT;path;data or $PUT;dir;path/to/dir
						  if data[2]~="dir" then
							f=fs.open("server/"..data[2],"w")
							f.write(data[3])
							f.close()
								print("Clock|"..os.clock().."|Time|"..os.time().."|"..id.."|$PUT|"..data[2])
									logFile.writeLine("Clock|"..os.clock().."|Time|"..os.time().."|"..id.."|$PUT|"..data[2])
						  else
						    f.makeDir("server/"..data[3])
								print("Clock|"..os.clock().."|Time|"..os.time().."|"..id.."|$PUT|DIRECTORY|"..data[2])
									logFile.writeLine("Clock|"..os.clock().."|Time|"..os.time().."|"..id.."|$PUT|DIRECTORY|"..data[2])
						  end
						end
						if data[1]=="$RIP" then -- $RIP;path
							if fs.exists("server/"..data[2]) then
								f=fs.open("server/"..data[2],"r")
								contents=f.readAll()
								f.close()
									sleep(0.1)
									rednet.send(id,contents)
										print("Clock|"..os.clock().."|Time|"..os.time().."|"..id.."|$RIP|"..data[2])
											logFile.writeLine("Clock|"..os.clock().."|Time|"..os.time().."|"..id.."|$RIP|"..data[2])
							else
								rednet.send(id,"Error, file was not found.")
									print("Clock|"..os.clock().."|Time|"..os.time().."|"..id.."|$RIP|FAILED|"..data[2])
										logFile.wrieLine("Clock|"..os.clock().."|Time|"..os.time().."|"..id.."|$RIP|FAILED|"..data[2])
							end
						end
						if data[1]=="$OBTAIN" then -- $OBTAIN;SETTING
							if data[2]=="SERVER.ID" then sleep(0.1) rednet.send(id,tostring(os.getComputerID())) end
								print("Clock|"..os.clock().."|Time|"..os.time().."|"..id.."|$OBTAIN|"..data[2])
									logFile.writeLine("Clock|"..os.clock().."|Time|"..os.time().."|"..id.."|$OBTAIN|"..data[2])
							else
								print("Clock|"..os.clock().."|Time|"..os.time().."|"..id.."|$OBTAIN|FAILURE")
						end
						if data[1]=="$CHECK" then -- %CHECK;path, returns an a,b. A is a bool on whether or not it exists, B is a bool on if it's a dir or not.
						  bExists, bDir = false, false
							if fs.exists("server/"..data[2]) then bExists=true end
							if fs.isDir("server/"..data[2]) then bDir=true end
							if fs.isReadOnly("server/"..data[2]) then bExists=false end
							sleep(0.1)
							rednet.send(id,tostring(bExists)..";"..tostring(bDir))
								print("Clock|"..os.clock().."|Time|"..os.time().."|"..id.."|$CHECK|"..data[2])
									logFile.writeLine("Clock|"..os.clock().."|Time|"..os.time().."|"..id.."|$CHECK|"..data[2])
						end
					else
					rednet.send(id,"Error, a $ and ; are required for server commands.")
						print("Clock|"..os.clock().."|Time|"..os.time().."|"..id.."|$SYNTAX_ERROR:"..msg)
							logFile.writeLine("Clock|"..os.clock().."|Time|"..os.time().."|"..id.."|$SYNTAX_ERROR:"..msg)
				end
			end
			if ev=="char" then -- If the event is that of a keystroke
				if id=="e" or id=="E" then -- Exit
				  print("Rebooting.")
				   sleep(3)
					os.reboot()
				end
				if id=="s" or id=="S" then -- Show Stack
				  print("Data Stack:")
					for i=1,#data_stack do
						print(data_stack[i])
					end
						logFile.writeLine("Clock|"..os.clock().."|Time|"..os.time().."|".."STACK_PRINTED")
				end
				if id=="l" or id=="L" then -- Push Logues
				  print("Pushing logues")
					logFile.close()
					logFile=fs.open("server/log.txt","a")
						logFile.writeLine("Clock|"..os.clock().."|Time|"..os.time().."|".."LOGUE_RESET")
				end
				if id=="c" or id=="C" then -- Clear Stack
					data_stack=nil
					data_stack={}
					  print("Stack cleared")
						logFile.writeLine("Clock|"..os.clock().."|Time|"..os.time().."|".."STACK_RESET")
				end
				if id=="a" or id=="A" then -- Add 5 Random to Stack
					a,b,c,d,e=math.random(),math.random(),math.random(),math.random(),math.random()
					table.insert(data_stack,a)
					table.insert(data_stack,b)
					table.insert(data_stack,c)
					table.insert(data_stack,d)
					table.insert(data_stack,e)
					  print("Added 5 random to stack")
						logFile.writeLine("Clock|"..os.clock().."|Time|"..os.time().."|".."5_RND_INSERTED_TO_STACK")
				end
				if id=="b" or id=="B" then -- Broadcast Stack
					serStack=textutils.serialize(data_stack)
					rednet.broadcast(serStack)
					print("Stack brodcasted.")
						logFile.writeLine("Clock|"..os.clock().."|Time|"..os.time().."|".."STACK_BROADCASTED")
				end
				if id=="j" or id=="J" then -- Push Stack Logues
				 print("Loguing Stack.")
				  logFile.writeLine("BEGINNING_STACK_LOG{")
					for i=1,#data_stack do
						logFile.writeLine(data_stack[i])
					end
				  logFile.writeLine("}")
				end
				if id=="h" or id=="H" then -- Help Command
				  term.setCursorPos(1,1)
				  term.clear()
					print("Hosting on: "..os.getComputerID())
					print("E - Exit")
					print("L - Push Logues")
					print("S - Show Stack")
					print("C - Clear Stack")
					print("A - Add Random to Stack")
					print("B - Broadcast Stack")
					print("H - Help")
					print("J - Push Stack Logues")
				end
			end
		end
end
mainLoop() -- Calling the main loop