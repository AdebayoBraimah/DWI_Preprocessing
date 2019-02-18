#!/usr/local/bin/bash

## Use: #!/bin/bash for cluster

#
# Define Usage & Function(s)
#=====================================================

function Usage() {
	cat << USAGE

usage: imgQC.sh <Parent Directory of study participants>

This script is intended to perform QA of the DWI data
for Neonates in the IRC287H study and was designed to
be evoked from a local work station (due to the fact
that the HPC version of fsleyes is not working 
correctly, CCHMC).
 
Compulsory input required:

<Parent Directory of study participants>

Note: This script uses array indices and as such
must be edited to suit the user's needs.

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

if [ ${#} -lt 1 ]; then
    Usage >&2
    exit
fi

#
# Define Variables 
#=====================================================

dir=${1}

a=(C01 C02)
a=(01 02 03 05)

ov1="fsleyes render --scene=ortho -of=FA_QC1.png DTI_FA.nii.gz DTI_V1.nii.gz -ot rgbvector"	# Overlay with orthongal views
ov2="fsleyes render --scene=lightbox -of=FA_QC2.png DTI_FA.nii.gz DTI_V1.nii.gz -ot rgbvector"	# Overlay with lightbox view

cd ${dir}

##
## B800
##====================================================

for ((i = 0; i < ${#a[@]}; i++)); do
	cd ${dir}/${a[$i]}
	e=$(find `pwd` -path "*${a[$i]}*/*B800*/**/*FA*.nii*")	# Find DTI_FA maps
	e=`dirname ${e}`					# Get FA maps' directory
	cd ${e}
	${ov1} && ${ov2}					# Create FA map Overlays
done

# for ((i = 0; i < ${#a[@]}; i++)); do
# 	cd ${dir}/${a[$i]}
# 	e=$(find `pwd` -path "*${a[$i]}*/*B800*/**/*FA*.nii*")	
# 	e=`dirname ${e}`					
# 	cd ${e}
# 	${ov1} && ${ov2}					
# done

##
## B2000
##====================================================

for ((i = 0; i < ${#a[@]}; i++)); do
	cd ${dir}/${a[$i]}
	e=$(find `pwd` -path "*${a[$i]}*/*B2000*/**/*FA*.nii*")	# Find DTI_FA maps
	e=`dirname ${e}`					# Get FA maps' directory
	cd ${e}
	${ov1} && ${ov2}					# Create FA map Overlays
done

