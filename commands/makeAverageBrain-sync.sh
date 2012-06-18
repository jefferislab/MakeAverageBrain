#!/bin/bash
# The name of the reference brain has to end in 1 but the argument must not have the 1, eg SAGV28_Avg1 should be passed as SAGV28_Avg

# make sure that any ouput is rw for flybrain group members
umask 002

REFBRAIN=$1
NOITERATIONS=$2
REGROOT=$3

PROGNAME=`basename $0`

if [ -z "$1" -o -z "$2" ]; then 
	echo "usage: $PROGNAME <REFBRAIN> <numiterations> [REGROOT]\n"
	echo "If REGROOT is missing, will use current directory\n"
	echo "Normally called something like this:"
	echo "sh commands/$PROGNAME <REFBRAIN> <numiterations> >& jobs/mylogfile.txt &\n"
	echo "Directory structure should look like this:"
	echo "REGROOT - images    (where your input images (*.nrrd) live)"
	echo "        - refbrain  (where your nrrd reference brain lives)"
	echo "        - commands  (location of script files)"
	exit
fi

if [ -z "$REGROOT" ]; then 
	echo "NB: Using current directory as registration root"
	REGROOT=`pwd`
else 
	if [ ! -d "$REGROOT" ]; then
	    echo "REGROOT directory $REGROOT does not exist!"
		exit
	fi
	# Make sure REGROOT is an absolute path
	$REGROOT=`cd $REGROOT; pwd`
fi

echo "Registration root directory is $REGROOT"

NOIMAGES=`ls -l ${REGROOT}/images/*.nrrd | wc -l`

# It will make:
#         - jobs      (where SGE will write job output, must make this)
#         - average   (where avg_adm will make output, will be empty)
#         - Registration
#         - reformatted

# You shouldn't need to change these
GJROOT="/lmb/home/jefferis"
MUNGERDIR="$GJROOT/bin"
export REGBINDIR="$GJROOT/dev/neuroanat/cmtk/core/build/bin"

# make output directories that we'll need later
mkdir -p "$REGROOT/jobs"
mkdir -p "$REGROOT/average"

LMBUSER=`whoami`

i=1
while [ $i -le $NOITERATIONS ]; do
	# Starts a round of registrations using the template corresponding to the present iteration
	# note the use of -t to make $NUMJOBS separate array jobs
	# this will be fine so long as there is no problem with lock files
	# which there shouldn't be because of nfs safe locking ...
	# AND the use of -sync yes
	# which waits until (all?) array jobs are finished
	CURREFBRAIN=${REFBRAIN}${i}
	# passed REFBRAIN REGROOT REGBINDIR and MUNGERDIR variables
	qsub -wd "$REGROOT/jobs" -sync yes -t 1-${NOIMAGES} -S /bin/bash -m eas -M ${LMBUSER}@lmb.internal -pe smp 4 "$REGROOT"/commands/warpcmdIteration.sh ${CURREFBRAIN} ${REGROOT} ${REGBINDIR} ${MUNGERDIR}
	
	# add one to $i and therefore the number of the refbrain e.g. IS2-1 goes to IS2-2
	i=`echo "1 + $i" | bc`
	NEWREFBRAIN=${REFBRAIN}${i}

	if [ ! -f "${REGROOT}/refbrain/${NEWREFBRAIN}.nrrd" ] ; then
		# if average brain doesn't exist (eg if a run was interrupted then make it)
		qsub -sync yes -wd "$REGROOT/jobs" -S /bin/bash -m eas -M ${LMBUSER}@lmb.internal -pe smp 8 "$REGROOT/commands/avgcmdIterationPadOut.sh" ${CURREFBRAIN} ${NEWREFBRAIN} ${REGROOT} ${REGBINDIR}
	fi
	if [ ! -f "${REGROOT}/refbrain/${NEWREFBRAIN}.nrrd" ] ; then
		echo Exiting $PROGNAME since avg_adm failed to make $NEWREFBRAIN
		exit
	fi
	
done
