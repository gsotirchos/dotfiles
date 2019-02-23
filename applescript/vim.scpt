on run {input, parameters}
	
	set commands to {}
	
	if input is not {} then
		repeat with oneItem in input
			set filename to quoted form of the POSIX path of the oneItem
			set cmd to "cd \"$(dirname " & filename & ")\"; vim " & filename
			copy cmd to the end of commands
		end repeat
	else
		copy "vim" to end of commands
	end if
	
	repeat with cmd in commands
		tell application "Terminal"
			launch
			do script cmd
			activate
		end tell
	end repeat
	
end run
