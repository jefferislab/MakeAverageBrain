# Introduction

This git repo contains the files and folders sufficient to generate a template
brain given a set of images to be registered and reference brain on which to
register them.

# Usage
# Setup

The general idea is that you clone this repository for each new template brain project. e.g.

    git clone git@github.com:jefferis/MakeAverageBrain.git <NameOfNewTemplate>

then fill the directories as described below, and finally run the code. If you do not have git
you can just [download the zip](https://github.com/jefferislab/MakeAverageBrain/archive/feature/average-on-hex.zip)
file, expand and rename the resultant folder to <NameOfNewTemplate>.

## Images

Sample images should be put in the **images** directory, and the reference brain should be put in
the **refbrain** directory.


### Sample Images

These should be in nrrd format (use Fiji) and named in the following style:

    myimage1_01.nrrd
    myimage2_01.nrrd
    myimage3_01.nrrd
    anotherimage_01.nrrd

i.e. the first part of the filename should not contain any underscores and this 
should be followed by the channel number of the image (01) in all cases and then 
".nrrd". Be careful to use lowercase for nrrd as this can cause problems later.

### Reference Image

Your reference brain should consist of a short name without any punctuation 
(letters/numbers only) and should end in -1.nrrd eg

    FCWB-1.nrrd
    Dwf-1.nrrd

The reason for the -1 is explained below, basically it is used as a counter for 
the iterative registration/averaging process.

## Code

The commands directory contains three shell scripts that are used to submit jobs to the
Sun GridEngine system used by the LMB's computational cluster.

`makeAverageBrain-sync.sh` successively calls `warpcmdIteration.sh` and `avgcmdIterationPadOut.sh`
to generated registrations and uses those registration parameters to generate shape and
intensity averaged brains.

To use these scripts, change directory to the top of your registration folder (ie the folder
that contains this git repo) and run the command

    sh commands/makeAverageBrain-sync.sh 

to get instructions on how to use these scripts. In general you will need to pass the script
the name of your reference brain (e.g. if your initial template brain is `templateBrain-1`,
you will want to pass the script `templateBrain-` without the quotes), and the number of iterations
over which to average the brains.

A complete command will look something like this:

    sh commands/makeAverageBrain-sync.sh templateBrain- 5 >& jobs/mylogfile.txt &

The script will generate `jobs`, `Registration`, `reformatted`, and `average` directories as needed.

### Symmetrisation step
If you want to run the symmetrisation step alone (i.e. placing the final brain in an affine symmetric location)
then you can do that like this:

    cd /path/to/my/project/root
    export REGROOT=`pwd` && commands/symmetricOutput.sh $REGROOT/refbrain/terkavg-5.nrrd $REGROOT/refbrain/terkavg-5-symmetric.nrrd y

where `terkavg-5.nrrd` was the final average brain for this project and we wanted to flip along the y axis (rather than x).

# Installation

These scripts have been specifically designed and tested for the MRC LMB's 
compute cluster. Unfortunately (precisely because these are largely job control 
scripts) it has not been possible to remove these location specific issues from 
the code. Nevertheless they should at a minimum provide inspiration for anyone 
with some experience of computing in a cluster environment.

## Dependencies
With that said the dependencies are

1. [CMTK](http://www.nitrc.org/projects/cmtk)
2. [Sun/Oracle Grid Engine](http://gridscheduler.sourceforge.net)
3. [R](http://www.r-project.org/)
4. [R package nat](http://cran.r-project.org/web/packages/nat/index.html)

Grid engine is the job control system that we use. It should be possible to use 
something different by replacing all cases of qsub.

R/nat is used for a final step of placing the newly created average brain so 
that its plane of symmetry is located at the central YZ plane of the image.

## Configuration

Search for "LMB" and "GJ" (case insensitive) to see what you need to change.

# TODO

1. Extract all local configuration details into a single config file (see [Issue #3](https://github.com/jefferislab/MakeAverageBrain/issues/3))
2. Rewrite the whole thing to cope with a more generic environment
3. Remove the specific Grid Engine dependency

(2 and 3 could perhaps be done by converting to R and using the BatchJobs package)
