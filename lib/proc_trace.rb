set_trace_func proc { |event, file, line, id, binding, classname|
  # only interested in events of type 'call' (Ruby method calls)
  # see the docs for set_trace_func for other supported event types

  #printf "%8s %s:%-2d %10s %8s\n", event, file, line, id, classname
  #    call prog.rb:2        test     Test
  puts "\e[32mMethod Call: `#{classname}.#{id}` called in #{file}:#{line}.\n\e[0m" if event == 'call'
}