drb = create_dataref("test/dref_b","number",function()
	print("b changed")
end)

dra = find_dataref("test/dref_a")

print("B setting B to 2")
drb = 2

function flight_start()
	print("B setting A to -1")
	dra = -1
	print(dra)
	print(drb)
end
