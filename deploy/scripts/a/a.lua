dra = create_dataref("test/dref_a","number",function()
	print("a changed")
end)

drb = find_dataref("test/dref_b")

print("A setting A to 1")
dra = 1

function flight_start()
	print("A setting B to -2")
	drb = -2
	print(dra)
	print(drb)
end

print("--------------------")

local t1 = { "a" }
t1[2] = find_dataref("test/dref_a")
t2 = { "a" }
t2[2] = find_dataref("test/dref_a")

dra = 77
local t3 = { "a" }
t3[2] = find_dataref("test/dref_a")


print(#t1)
for k,v in ipairs(t1) do
	print(k, v, type(v))
end
print(t1[2])

print(#t2)
for k,v in ipairs(t2) do
	print(k, v, type(v))
end
print(t2[2])

print(#t3)
for k,v in ipairs(t3) do
	print(k, v, type(v))
end
print(t3[2])
