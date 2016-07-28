
print("****************** start test ******************")


button_sw_cover = {}


function make_close_cover_func(index)
	close_cover = 
	[[
	function close_button_cover%s()
		print("CLOSE COVER")
		button_sw_cover[%s] = 0
	end		
	]]
    assert(load(string.format(close_cover,
        index,
        index
    )))()
end   




function make_cover_handler_func(index)
	cover_handler = 
	[[
	function button_cover_handler%s()
		if is_timer_scheduled(close_button_cover%s) then
		print("STOP TIMER")
			stop_timer(close_button_cover%s)
		end
		print("START TIMER")
		run_after_time(close_button_cover%s, 5.0)
	end					
	]]
    assert(load(string.format(cover_handler,
        index,
        index,
        index,
        index
    )))()
end    	




function make_spring_loaded_cover_DR(index)

	local func = load("button_cover_handler" .. tostring(index) .. "()")
    button_sw_cover[index] = create_dataref("JGX/test/button_sw_cover" .. tostring(index), "number", func)

end




for i=0, 5 do
	make_close_cover_func(i)
	make_cover_handler_func(i)
    make_spring_loaded_cover_DR(i)
end

