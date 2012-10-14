--DNS Software by Sledger721.
--  DNS Commands:
--   -REGISTER - Register the URL.
--   -DELETE - Delete the URL registry.
--   -FIND - Find the ID of the URL.
--   -CHANGE - Change the ID of the URL.
data={}

function openAll()
rednet.open("top")
rednet.open("left")
rednet.open("right")
rednet.open("back")
end
function init()
	if fs.exists("dns")==false then
		fs.makeDir("dns")
	end
	if fs.exists("dns/sites")==false then
		fs.makeDir("dns/sites")
	end
	if fs.exists("dns/log.txt")==false then
		f=fs.open("dns/log.txt","w")
		f.write("HEADER")
		f.close()
	end
	logue=fs.open("dns/log.txt","a")
	logue.writeLine("CLOCK:"..os.clock().."|TIME:"..os.time().."|Intiation function.")
end
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
function mainLoop() -- Main loop of the DNS.
init()
openAll()
print("Hosting DNS on: "..os.getComputerID())
print("E - Exit")
print("L - Push Logues")
print("--------------------------------------------------")
	while true do
		ev,id,msg=os.pullEvent()
		if ev=="rednet_message" then
			if string.find(msg,"$") and string.find(";") then
				data=split(msg,";")
				if data[1]=="$REGISTER" then -- $REGISTER;URL returns %TRUE%
					f=fs.open("dns/sites/"..data[2],"w")
					f.write(id)
					f.close()
						rednet.send(id,"%TRUE%")
							print(id.."|Registered: "..data[2])
							logue.writeLine("CLOCK:"..os.clock().."|TIME:"..os.time().."|"..id.."|Registered: "..data[2])
				end
				if data[1]=="$DELETE" then -- $DELETE;URL returns %TRUE% or %FALSE%
					if fs.exists("dns/"..data[2]) then
						fs.delete("dns/"..data[2])
							rednet.send(id,"%TRUE%")
							print(id.."|Deleted: "..data[2])
								logue.writeLine("CLOCK:"..os.clock().."|TIME:"..os.time().."|"..id.."|Succesfully deleted: "..data[2])
					else
						rednet.send(id,"%FALSE%")
						print(id.."|Failed attempt to delete: "..data[2])
							logue.writeLine("CLOCK:"..os.clock().."|TIME:"..os.time().."|Failed attempt to delete: "..data[2])
					end
				end
				if data[1]=="$FIND" then -- $FIND;URL returns ID;%TRUE% or %FALSE%
					if fs.exists("dns/"..data[2]) then
						f=fs.open("dns/"..data[2],"r")
						contents=f.readAll()
						f.close()
						  sleep(0.5)
							rednet.send(id,contents..";%TRUE%")
							print(id.."|Query done on: "..data[2])
								logue.writeLine("CLOCK:"..os.clock().."|TIME:"..os.time().."|"..id.."|Query succesful: "..data[2])
					else
						rednet.send(id,"%FALSE%")
						print(id.."|Query failed on: "..data[2])
							logue.writeLine("CLOCK:"..os.clock().."|TIME:"..os.time().."|"..id.."|Query failed: "..data[2])
					end
				end
				else
				rednet.send(id,"ERROR")
			end
		end
		if ev=="char" then -- Detecting the exit key here.
			if id=="l" or id=="L" then
			  print("Logues Pushed.")
				logue.close()
				logue=fs.open("dns/log.txt","a")
			end
			if id=="e" or id=="E" then
				os.reboot()
				logue.writeLine("CLOCK:"..os.clock().."|TIME:"..os.time().."|Exit function.")
				print("E recognized, if you see this, shell error.")
		end
		
	end
end
end
mainLoop()
