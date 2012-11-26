if ENV['RUBY_DEBUG'] == 'true'
	app_trace = Hash.new
	set_trace_func proc { |event, file, line, id, binding, classname|
	  # only interested in events of type 'call' (Ruby method calls)
	  # see the docs for set_trace_func for other supported event types

	  #printf "%8s %s:%-2d %10s %8s\n", event, file, line, id, classname
	  #    call prog.rb:2        test     Test
	  if app_trace["#{classname}.#{id}.#{file}.#{line}"].nil?
	  	app_trace["#{classname}.#{id}.#{file}.#{line}"] = 0
	  else
	  	app_trace["#{classname}.#{id}.#{file}.#{line}"] += 1
	  end

	  count = app_trace["#{classname}.#{id}.#{file}.#{line}"]
	  puts "\e[31mMethod Call: `#{classname}.#{id}` called (#{count} times)\n\tin #{file}:#{line}.\n\e[0m" if event == 'call'
	}
end