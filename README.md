########
#README#
########

This git repo contains the files and folders sufficient to generate a template brain given
a set of images to be registered and reference brain on which to register them.

Images
======

Sample images should be put in the images directory, and the reference brain should be put in
the refbrain directory.


Sample Images
-------------
These should be in nrrd format (use Fiji) and named in the following style:

myimage1_01.nrrd
myimage2_01.nrrd
myimage3_01.nrrd
anotherimage_01.nrrd

i.e. the first part of the filename should not contain any underscores and this should be followed by the channel number of the image (01) in all cases and then ".nrrd". Be careful to use lowercase for nrrd as this can cause problems later.

Reference Image
---------------
Your reference brain should consist of a short name without any punctuation (letters/numbers only) and should end in -1.nrrd eg

FCWB-1.nrrd
Dwf-1.nrrd

The reason for the -1 is explained below, basically it is used as a counter for the iterative registration/averaging process.

Code
====

The commands directory contains three shell scripts that are used to submit jobs to the
Sun GridEngine system used by the LMB's computational cluster.

makeAverageBrain-sync.sh successively calls warpcmdIteration.sh and avgcmdIterationPadOut.sh
to generated registrations and uses those registration parameters to generate shape and
intensity averaged brains.

To use these scripts, change directory to the top of your registration folder (ie the folder
that contains this git repo) and run the command

	sh commands/makeAverageBrain-sync.sh 
	
to get instructions on how to use these scripts. In general you will need to pass the script
the name of your reference brain (eg if your initial template brain is templateBrain-1,
you will want to pass the script "templateBrain-" without the quotes), and the number of iterations
over which to average the brains.

A complete command will look something like this:

	sh commands/makeAverageBrain-sync.sh templateBrain- 5 > & jobs/mylogfile.txt &

The script will generate jobs, Registration, reformatted, and average directories as needed.
