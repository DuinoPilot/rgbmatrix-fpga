# Basic TCP server gateway for the (virtual) JTAG Interface
# Part of the Adafruit RGB LED Matrix Display Driver project
# Written partially by Brian Nezvadovitz

# You can run this script through the Quartus II SignalTap II Tcl interpreter
# (quartus_stp.exe) by invoking it with the -t parameter.

# This TCL script is derived from the example posted online at
# http://idle-logic.com/2012/04/15/talking-to-the-de0-nano-using-the-virtual-jtag-interface/
# TCP/IP server code dervied from Tcl Developer Exchange - http://www.tcl.tk/about/netserver.html
# The JTAG portion of the script is derived from some of the examples from Altera.

# After starting this script, connect to localhost on port 1337 and send strings
# of hex characters followed by a newline ("\n") character.

proc Script_Main {} {
    # Print welcome banner
    puts "------------------------------------------------"
    puts ""
    puts " <<-=*\[  JTAG server for RGB LED Matrix  \]*-=>> "
    puts ""
    
    # Find the USB-Blaster device attached to the system
    puts "* Locating USB-Blaster device..."
    foreach hardware_name [get_hardware_names] {
        if { [string match "USB-Blaster*" $hardware_name] } {
            set usbblaster_name $hardware_name
        }
    }

    # List all devices on the chain, and select the first device on the chain.
    puts "* Finding devices attached to $usbblaster_name..."
    foreach device_name [get_device_names -hardware_name $usbblaster_name] {
        if { [string match "@1*" $device_name] } {
            set jtag_device $device_name
        }
    }
    
    # Open the selected JTAG device
    puts "* Opening $jtag_device"
    open_device -hardware_name $usbblaster_name -device_name $jtag_device
    
    # Start the TCP/IP listener
    puts "* Starting server on port 1337..."
    set s [socket -server ConnAccept 1337]
    
    # Wait for connections...
    vwait forever
    #catch {close_device}
}

proc Write_JTAG_DR {send_data data_length} {
    #puts "DEBUG: Write_JTAG_DR $send_data"
    device_lock -timeout 10000
    device_virtual_dr_shift -dr_value $send_data -instance_index 0 -length $data_length -value_in_hex -no_captured_dr_value
    catch {device_unlock}
}

proc Write_JTAG_IR {send_data} {
    puts "DEBUG: Write_JTAG_IR $send_data"
    device_lock -timeout 10000
    device_virtual_ir_shift -instance_index 0 -ir_value $send_data -no_captured_ir_value
    catch {device_unlock}
}

proc ConnAccept {sock addr port} {
    global conn
    puts "* Connection from $addr $port opened"
    set conn(addr,$sock) [list $addr $port]
    # Ensure that each "puts" by the server results in a network transmission
    fconfigure $sock -buffering line
    # Set up a callback for when the client sends data
    fileevent $sock readable [list IncomingData $sock]
    # Set IR to 1 which is "write to register" mode
    Write_JTAG_IR 1
}

proc IncomingData {sock} {
    global conn
    # Check for EOF or abnormal connection drop
    if {[eof $sock] || [catch {gets $sock line}]} {
        # Set IR back to 0, which is "bypass" mode
        Write_JTAG_IR 0
        # Clean up the socket
        close $sock
        puts "* Connection with $conn(addr,$sock) closed"
        unset conn(addr,$sock)
    } else {
        # Incoming data from the client
        set data_len [string length $line]
        # Check length
        if {$data_len >= 4} then {
            # Write to the data register
            Write_JTAG_DR $line [expr 4*$data_len]
        } elseif {$data_len == 3 && $line == "RST"} then {
            # Send reset command to the device
            puts "* Sending reset command!"
            Write_JTAG_IR 2
            # Put the device back in "write to register" mode
            Write_JTAG_IR 1
        } else {
            puts "DEBUG: Ignored incoming data of length $data_len chars"
        }
    }
}

# Start the script!
Script_Main

#EOF