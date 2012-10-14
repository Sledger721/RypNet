--NOTE: This is not to be read, but to test every function on a server or DNS to find basic bugs. I wouldn't quite recommend using this as documentation either, just as a test mechanism for a server or DNS.

--A test of the Server.lua and DNS.lua.
--By: Sledger721
function openAll() -- A function to open all ports.
	rednet.open("top")
	rednet.open("left")
	rednet.open("right")
	rednet.open("back")
	rednet.open("front")
	rednet.open("bottom")
end
function test()
openAll() -- Openning all ports.
print("Enter the Server's ID:")
servid=read() -- Obtaining the server's ID.

net.rdnt.post(servid,"dat_to_post") -- Posting "dat_to_post" to the server's data_stack.
sleep(1) -- Waiting.
print("$POST has been completed, now attempting to retrieve.")
stack=net.rdnt.get(servid) -- Obtaining a copy of the stack.
print("Type of result: "..type(stack))

for i=1,#stack do -- Printing the stack of which was just obtained.
	print(stack[i])
end

net.rdnt.putFile(servid,"test_file","Data inside of the test file goes here.") -- Writes the file "test_file" (that's the path) with the next string as data.
file=net.rdnt.rip(servid,"test_file") -- Getting the data of the file: "test_file". That doesn't just pull from name, it pulls from path. 
print(file) -- Printing the data of which was obtained by using the net.rdnt.rip function.

a,b=net.rdnt.check(servid,"test_file") -- Getting the data of the file: "test_file". That doesn't just pull from name, it pulls from path.
print(a.."|"..b)

--Now, testing the DNS

print("Enter the DNS ID:") -- Getting the ID of the DNS.
dnsid=read()
net.dns.register(dnsid,"test")
id=net.dns.find(dnsid,"test")
net.dns.delete(dnsid,"test")
end
test()