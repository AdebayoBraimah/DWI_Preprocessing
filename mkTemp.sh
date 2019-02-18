#!/bin/bash

#
# Define Usage & Function(s)
#=====================================================

function Usage() {
	cat << USAGE

Compulsory inputs are required in the following order:

<Output template directory>
<Output name for all corresponding files>
<Number of workers>

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

if [ ${#} -lt 3 ]; then
    Usage >&2
    exit
fi

## Find Job ID given Job Name

function nk_jobid {
    output=$($*)
    echo $output | head -n1 | cut -d'<' -f2 | cut -d'>' -f1
}

#
# Define Variables 
#=====================================================

templateDir=${1}
outName=${2}
n=${3}

ANTSPATH=/usr/local/ants/2.3.1/bin	# Path to ANTs v2.3.1 installation on the cluster

#
# Load Modules
#=====================================================

module load ants/2.3.1	# Loads module ANTs v2.3.1 (https://github.com/ANTsX/ANTs/releases)

#
# Make Template
#=====================================================

cd ${templateDir}

export ANTSPATH=${ANTSPATH}

bsub -J DWI_Template -n ${n} -W 4000 -M 32000 -o /users/brac4g/Desktop/log/%J.out -e /users/brac4g/Desktop/log/%J.err antsMultivariateTemplateConstruction2.sh -d 3 -i 10 -k 1 -a 1 -g 0.25 -n 0 -r 1 -l 1 -y 1 -f 6x4x2 -s 3x2x1vox -q 100x100x70 -t SyN -m CC -c 2 -j ${n} -o ${outName}_T_ *.nii*
