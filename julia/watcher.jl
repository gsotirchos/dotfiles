#
# ~/.julia/config/watcher.jl
#

# function to watch files and execute on change
function watcher(file::AbstractString)
    timeout = 1800 # 1800 sec = 3 min
    file_changed = false

    while true
        try
            # execute the file
            run(`clear`)
            include(file)
        catch err
            # Print error info and backtrace, and continue
            errBacktrace = stacktrace(catch_backtrace())
            println("\nERROR: ", err)
            println("\nBacktrace: ")
            for (i, v) in enumerate(errBacktrace)
                println("[", i, "] ", errBacktrace[i])
            end
        end

        try
            print("\nwatcher: watching file \""
                * file * "\" for changes...")

            # wait for file canges, for 30 min
            file_changed = watch_file(file, timeout).changed

            if file_changed == false;
                # stop watching if no change is observed for 30 min
                print("\nwatcher: timed out, stopped watching file \""
                    * file * "\"")
                return
            end
        catch InterruptException
            # stop watching on user interupt
            print("\nwatcher: stopped watching file \"" * file * "\"")
            return
        end

    end
end
