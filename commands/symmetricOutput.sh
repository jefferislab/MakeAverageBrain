#!/usr/bin/env bash

#$ -l h_vmem=6G

REGBINDIR="/lmb/home/jefferis/dev/neuroanat/cmtk/core/build/bin/"

export PATH="/lmb/home/jefferis/local/bin:$REGBINDIR:$PATH"


NEWREFPATH=$1
SYMREFPATH=$2
GJROOT=$3
REGROOT=$4

cd "$REGROOT/commands"

R --no-save --interactive --args ${NEWREFPATH} ${SYMREFPATH} ${GJROOT} < MakeSymmetricStandardBrain.R
