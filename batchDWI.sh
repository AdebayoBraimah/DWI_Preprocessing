#!/bin/bash

#
# Define Usage & Function(s)
#=====================================================

function Usage() {
	cat << USAGE

This script is intended to preprocess the DWI data
for Neonates in the IRC287H study.
 
Compulsory inputs required in the following order:

<Parent Directory of study participants>
<Scripts Directory for DWI Processing>

Note: BVALs, BVECs and the index file must be in 
the same directory as the DWI.

USAGE
	exit 1
}

## Print Status (Blue text)

printStatus() {
    printf \\e\[36m"\tFunc: ${1}\n"\\e\[0m
}

## Print Warning (Red text)

printWarning() {
    printf \\e\[31m"\tFunc: ${1}\n"\\e\[0m
}

if [ ${#} -lt 2 ]; then
    Usage >&2
    exit
fi

#
# Define Variables 
#=====================================================

dir=${1}
scriptsDir=${2}

# a=(C01 01 02 03) 	# Directory name, and job counter | B800 & B2000
# 
# c=(0.057011 0.057011 0.057011 0.057011)		# B800 Readout Times
# d=(0.0731956 0.0731956 0.0731956 0.04124514)	# B2000 Readout Times

#
# DWI Preprocess
#=====================================================

cd ${dir}

# #
# # Oringinal DWI Preprocess
# #=====================================================
# 
# 
# ##
# ## B800
# ##====================================================
# 
# for ((i = 0; i < ${#a[@]}; i++)); do
# 	e=$(find `pwd` -path "*${a[$i]}*/IRC317*DWI*B800*_${a[$i]}*.nii*")
# 	bsub -J DWI800_${a[$i]} -n 1 -W 2000 -M 32000 -R "rusage[gpu=1]" -o /users/brac4g/Desktop/log/%J.out -e /users/brac4g/Desktop/log/%J.err ${scriptsDir}/dwiPreProc.sh ${e} ${c[$i]} ${scriptsDir}
# done
# 
# ##
# ## B2000
# ##====================================================
# 
# for ((i = 0; i < ${#a[@]}; i++)); do
# 	e=$(find `pwd` -path "*${a[$i]}*/IRC317*DWI*B2000*_${a[$i]}*.nii*")
# 	bsub -J DWI2000_${a[$i]} -n 1 -W 2000 -M 32000 -R "rusage[gpu=1]" -o /users/brac4g/Desktop/log/%J.out -e /users/brac4g/Desktop/log/%J.err ${scriptsDir}/dwiPreProc.sh ${e} ${d[$i]} ${scriptsDir}
# done

#
# 1 PE Direction
#=====================================================

a=(05 C02) 	# Directory name, and job counter | B800 & B2000

c=(0.051880005 0.051880005)	# B800 Readout Times
d=(0.057011 0.0731956)		# B2000 Readout Times

cd ${dir}

##
## B800
##====================================================

for ((i = 0; i < ${#a[@]}; i++)); do
	e=$(find `pwd` -path "*${a[$i]}*/IRC317*DWI*B800*_${a[$i]}*.nii*")
	bsub -J DWI800_1_${a[$i]} -n 1 -W 2000 -M 32000 -R "rusage[gpu=1]" -o /users/brac4g/Desktop/log/%J.out -e /users/brac4g/Desktop/log/%J.err ${scriptsDir}/dwiPreProc_1PE.sh ${e} ${c[$i]} ${scriptsDir}
done

##
## B2000
##====================================================

for ((i = 0; i < ${#a[@]}; i++)); do
	e=$(find `pwd` -path "*${a[$i]}*/IRC317*DWI*B2000*_${a[$i]}*.nii*")
	bsub -J DWI2000_1_${a[$i]} -n 1 -W 2000 -M 32000 -R "rusage[gpu=1]" -o /users/brac4g/Desktop/log/%J.out -e /users/brac4g/Desktop/log/%J.err ${scriptsDir}/dwiPreProc_1PE.sh ${e} ${d[$i]} ${scriptsDir}
done

