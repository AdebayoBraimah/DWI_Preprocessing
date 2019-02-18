#!/bin/bash

#
# Define Usage & Function(s)
#=====================================================

function Usage() {
	cat << USAGE

This script is intended to preprocess the DWI data
for Neonates in the IRC287H study.
 
Compulsory inputs required in the following order:

<Diffusion Weighted Image (DWI)>
<Readout Time>
<Scripts Directory>

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

if [ ${#} -lt 3 ]; then
    Usage >&2
    exit
fi

#
# Define Variables 
#=====================================================

dwi=${1}
readOutTime=${2}
scriptsDir=${3}

## Redefined variable names

dir=`dirname ${dwi}`	# (Relative) directory variable

dwi=`basename ${dwi}`
idx=`basename ${idx}`

#
# Load Modules
#=====================================================

module load fsl/5.0.11		# Loads FSL v5.0.11
module load mrtrix3		# Loads MRtrix3
module load cuda/7.5		# Loads Cuda
# module load AFNI/7		# Loads AFNI v16.2.13
module load anaconda3/1.0.0 	# Loads Anaconda 3 v1.0.0
# module load ica-aroma		# Loads ICA-AROMA(.py) v0.3-beta
# module load fix		# Loads FIX v1.0.6
# module load python/2.7.13	# Loads Python v2.7.13

#
# Create Original Data Directory &
# Complimentary Data Directory
#=====================================================

cd ${dir}

bval=*.bval*
bvec=*.bvec*
idx=*.idx

if [ ! -d ${dir}/OriginalData ]; then
	printStatus "Making temporary directory ${dir}/OriginalData " 
	mkdir -p ${dir}/OriginalData 	
fi

# gzip *.nii

cp ${dir}/* ${dir}/OriginalData

comp=${dir}/ComplimentaryData

if [ ! -d ${comp} ]; then
	printStatus "Making temporary directory ${comp} " 
	mkdir -p ${comp} 	
fi

mv ${dir}/${dwi} ${comp}/DWI.nii.gz
mv ${dir}/${bval} ${comp}/DWI_bval.bval
mv ${dir}/${bvec} ${comp}/DWI_bvec.bvec
mv ${dir}/${idx} ${comp}/DWI.idx

## Redefine variables

dwi=${comp}/DWI.nii.gz
bval=${comp}/DWI_bval.bval
bvec=${comp}/DWI_bvec.bvec
idx=${comp}/DWI.idx

cd ${comp}

# #
# # DWI/B0 reformat (Should not be used as the default)
# #=====================================================
# 
# ## This is only used when data is acquired with an odd
# ## number of slices (in the z/sup->inf) direction.
# ## This slice acquisition causes an error in topup and
# ## subsequently additional errors throughout the
# ## preprocessing pipeline. Moreover, this step simply
# ## deletes the first slice from the top to ensure an
# ## even number of slices.
# 
# ## B0 (top) slice removal
# 
# fslslice ${b0} B0s
# rm B0s_slice_0000.nii.gz 
# fslmerge -z sB0 B0s_slice_0*.nii*
# 
# wait ${!} && rm -rf B0s_slice*.nii*
# 
# ## DWI (top) slice removal
# 
# fslslice ${dwi} dwi_s
# rm dwi_s_slice_0000.nii.gz 
# fslmerge -z sDWI dwi_s_slice_0*.nii*
# 
# wait ${!} && rm -rf dwi_s_slice*.nii*
# 
# b0=${comp}/sB0.nii.gz
# dwi=${comp}/sDWI.nii.gz

#
# Denoise Diffusion Weighted Image (DWI)
#=====================================================

## Resample B0 image to match DWI dimensions

dwidenoise -noise noise_map.nii.gz ${dwi} denoised_DWI.nii.gz 	# Outputs noise map, denoised DWIs and B0s
dwi=denoised_DWI.nii.gz

#
# Create Additional Preprocessing 
# Files: .acqp (parameter acquisition) and 
# idx (index) files
#=====================================================

## Create .acqp file

paramTemp=${scriptsDir}/templateParam2.txt

python ${scriptsDir}/parameterDWI2.py ${paramTemp} ${readOutTime} DWI

param=DWI.acqp

## Create .idx file (probably should create manually)

### File is created manually depending on the number of directions and number of times PE gradients are switched

#
# Perform Eddy Current correction
#=====================================================

# eddy=eddy_openmp
eddy=eddy_cuda

dwi=${comp}/denoised_DWI.nii.gz
outDWI=${comp}/eddy_Corr_DWI

bet ${dwi} ${comp}/hifti_brain -m -R 		# Create brain mask

$eddy --imain=${dwi} --mask=${comp}/hifti_brain_mask --acqp=${param} --index=${idx} --bvecs=${bvec} --bvals=${bval} --out=${outDWI} --residuals --repol --mporder=6 --s2v_niter=5 --s2v_lambda=1 --s2v_interp=trilinear --verbose		# Replace outliers, perform intra-volume motion correction, and rotate bvecs (if necessary)

#
# Make QC Directory and Place Corrected DWIs in 
# Main Patient Directory
#=====================================================

# cp ${outDWI}.nii.gz ${dir}
# cp *rotated_bvecs* ${dir}/rotated_bvecs.bvec
# cp *.bval ${dir}/DWI.bval

qc=${dir}/QC

if [ ! -d ${qc} ]; then
	printStatus "Making temporary directory ${qc} " 
	mkdir -p ${qc} 	
fi

cp ${outDWI}.nii.gz ${qc}
cp *rotated_bvecs* ${qc}/rotated_bvecs.bvec
cp *.bval ${qc}/DWI.bval
cp hifti_brain_mask.nii.gz ${qc}

#
# Make QC Images 
#=====================================================

cd ${qc}

dtifit -k ${outDWI}.nii.gz -o DTI -m hifti_brain_mask.nii.gz -r rotated_bvecs.bvec -b DWI.bval --save_tensor

## Image Generation for QC to be performed locally

# fsleyes render --scene=ortho -of=FA_QC1.png DTI_FA.nii.gz DTI_V1.nii.gz -ot rgbvector
# fsleyes render --scene=lightbox -of=FA_QC2.png DTI_FA.nii.gz DTI_V1.nii.gz -ot rgbvector
rm -rf *_mask* 


