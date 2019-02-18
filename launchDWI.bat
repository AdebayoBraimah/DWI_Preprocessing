#BSUB -L/bin/bash
#BSUB -o /users/brac4g/Desktop/log/%J.out
#BSUB -e /users/brac4g/Desktop/log/%J.err

neoDWI=/scratch/brac4g/IRC317H/DWI_NIFTI
scriptsDir=/scratch/brac4g/IRC317H/Scripts_317/DWI_scripts

cd ${scriptsDir}

bsub -J LaunchDWI -n 1 -W 1000 -M 8000 -o /users/brac4g/Desktop/log/%J.out -e /users/brac4g/Desktop/log/%J.err ${scriptsDir}/batchDWI.sh ${neoDWI} ${scriptsDir}

