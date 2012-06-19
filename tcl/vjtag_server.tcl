# Basic TCP server gateway for the (virtual) JTAG Interface
# WORK IN PROGRESS!
# TCL script derived from the example posted on
# http://idle-logic.com/2012/04/15/talking-to-the-de0-nano-using-the-virtual-jtag-interface/

# This portion of the script is derived from some of the examples from Altera

global usbblaster_name
global test_device
foreach hardware_name [get_hardware_names] {
	if { [string match "USB-Blaster*" $hardware_name] } {
		set usbblaster_name $hardware_name
	}
}
puts "Select JTAG chain connected to $usbblaster_name.";
# List all devices on the chain, and select the first device on the chain.
foreach device_name [get_device_names -hardware_name $usbblaster_name] {
	if { [string match "@1*" $device_name] } {
		set test_device $device_name
	}
}
puts "Selected device: $test_device";

# Open device 
proc openport {} {
	global usbblaster_name
    global test_device
	open_device -hardware_name $usbblaster_name -device_name $test_device
}

# Close device.  Just used if communication error occurs
proc closeport { } {
	catch {device_unlock}
	catch {close_device}
}

proc Write_JTAG {send_data} {
	openport   
	device_lock -timeout 1000
	# Shift through DR.  Note that -dr_value is unimportant since we're not actually capturing the value inside the part, just seeing what shifts out
	puts "Writing -> $send_data"
    # set IR to 1 which is write to reg mode
	device_virtual_ir_shift -instance_index 0 -ir_value 1 -no_captured_ir_value
	device_virtual_dr_shift -dr_value $send_data -instance_index 0  -length 3 -no_captured_dr_value
	# Set IR back to 0, which is bypass mode
	device_virtual_ir_shift -instance_index 0 -ir_value 0 -no_captured_ir_value
	closeport
}

# TCP/IP Server
# Code Dervied from Tcl Developer Exchange - http://www.tcl.tk/about/netserver.html

proc Start_Server {port} {
	set s [socket -server ConnAccept $port]
	puts "Started socket server on port $port"
	vwait forever
}
	
proc ConnAccept {sock addr port} {
    global conn
    # Record the client's information
    puts "Accept $sock from $addr port $port"
    set conn(addr,$sock) [list $addr $port]
    # Ensure that each "puts" by the server
    # results in a network transmission
    fconfigure $sock -buffering line
    # Set up a callback for when the client sends data
    fileevent $sock readable [list IncomingData $sock]
}

proc IncomingData {sock} {
    global conn
    # Check end of file or abnormal connection drop, then write the data to the vJTAG
    if {[eof $sock] || [catch {gets $sock line}]} {
        close $sock
        puts "Close $conn(addr,$sock)"
        unset conn(addr,$sock)
    } else {
        # Let's check for it and trap it
        set data_len [string length $line]
        if {$data_len >= 3} then {
            # Extract the first 3 bits
            set line [string range $line 0 2] 
            # Send the vJTAG Commands to update the register
            Write_JTAG $line
        }
    }
}

#Start thet Server at Port 1337
Start_Server 1337

#EOF