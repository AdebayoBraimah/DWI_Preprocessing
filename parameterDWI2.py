import pandas as pd
import os
import io
import subprocess
import sys

arg1=sys.argv[1]	# Template acquisition parameter file
arg2=sys.argv[2]	# Readout Time
arg3=sys.argv[3]	# Output name (no file extension)

## Creates dataframe and appends the Readout time 
## to the parameter acquisition file

data=pd.read_csv(arg1,header=None)				# Template parameter file, assumes phase encoding (PE) directions are UP, then DOWN
data.columns=['PE_directions']					# Labels column with PE direction label
data['ReadOutTime'] = arg2					# Lables column with Readout Time label
arg4 = arg3 + ".acqp"						# Append file extension
data.to_csv(arg4, index=False,header=False,sep='	')	# Prints .acqp file complete with PE directions, and Readout Time

