###############################################################################
# NOTE: If the data coming from the serial port is in the correct format, you
# can read directly from the port using 
#       plot '/dev/ttyUSB0' using 1:2 with lines
#
# TODO: Add interrupts on keypress - 'r' to refresh the tempfile
# (c) ADBeta    Jun 2024
###############################################################################
import threading
import os

import subprocess
import serial
import tempfile
import atexit
import time

def exit_handler():
    tmp.close()
    ser.close()

### Setup #####################################################################
# Open UART port. Change port and Baud as needed
ser = serial.Serial('/dev/ttyACM0', 115200)

# Open Temp File to write the UART Data into
tmp = tempfile.NamedTemporaryFile(delete=False, mode='w')
tmp_name = tmp.name
print("Writing to temp_file: ", tmp_name)

# Start Gnuplot with pipes for stdin stdout and stderr
gnuplot = subprocess.Popen(['gnuplot'], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE )

# Setup the gnuplot enviroment, use any commands here
gnuplot.stdin.write(b'set term qt\n')

#gnuplot.stdin.write(b'set yrange [-10:10]\n')  # Adjust y range if needed

# Plot a single line
gnuplot.stdin.write(f'plot "{tmp_name}" using 1:2 with lines\n'.encode())

# Plot multiple lines
#gnuplot.stdin.write(f'plot "{tmp_name}" using 1:2 with lines, "{tmp_name}" using 1:3 with lines, "{tmp_name}" using 1:4 with lines\n'.encode())

gnuplot.stdin.flush()


### Threads ###################################################################
def read_data():
    while True:
        # Read a line from the UART (can have multiple space seperated fields)
        data = ser.readline().decode('utf-8')
       
        #print(data)
        # If there is data to send, send it
        if data:
            tmp.write(data )
            tmp.flush()


def replot():
    while True:
        # tell gnuplot to use the tempfiles data to plot again
        gnuplot.stdin.write(b'replot\n')
        gnuplot.stdin.flush()
    
        # Sleep to reducde load
        time.sleep(0.5)

# Create threads
data_thread = threading.Thread(target=read_data)
replot_thread = threading.Thread(target=replot)

# Start threads
data_thread.start()
replot_thread.start()    
