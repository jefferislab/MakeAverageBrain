# A script to take the shape averge brains produced by makeAverageBrain.sh
# and center them around the YZ ie saggital plane

# Steps
# 1. Duplicate and flip the original image
# 2. Calculate an affine registration of the brain against flipped itself
# 3. Read in that registration
# 4. Halve the affine transformation 
# 5. Apply that registration to the raw average brain to generate the nicely
#    centred brain
argPath=commandArgs(trailingOnly = TRUE)

NEWREFPATH = argPath[1]
SYMREFPATH = argPath[2]
GJROOT     = argPath[3]

source(file.path(GJROOT,"/projects/AnalysisSuite/R/Code/Startup.R")) # for Jlab functions

MakeFlippedImage<-function(infile,outfile,axis="x"){
	if(missing(outfile))
		outfile=sub("\\.[^.]+$","-flip.nrrd",infile)
	cmd=paste("convertx --flip-",axis,sep=""," ",shQuote(infile)," ",shQuote(outfile))
	result=RunCmdForNewerInput(cmd,infile,outfile)
	return(outfile)
}

CalculateRegistration<-function(template,floating,outfolder,threads=8){
	Sys.setenv(CMTK_NUM_THREADS=threads)
	# nb translate and rotate only, no scale or shear
	cmd=paste("registration -i -v --dofs 6 --outlist",shQuote(outfolder),shQuote(template),shQuote(floating))
	# nb the output file will be called registration and sit inside outfolder
	outfile=file.path(outfolder,"registration")
	result=RunCmdForNewerInput(cmd,c(template,floating),outfile)
	return(outfolder)
}

MakeHalvedAffineRegistration<-function(infolder,outfolder){
	if(missing(outfolder))
		outfolder=sub("\\.list","-halved.list",infolder)
	
	reg=ReadIGSRegistration(infolder,ReturnRegistrationOnly=FALSE)
	reg$registration$affine_xform$xlate=reg$registration$affine_xform$xlate/2
	reg$registration$affine_xform$rotate=reg$registration$affine_xform$rotate/2
	WriteIGSRegistrationFolder(reg,outfolder)
	return(outfolder)
}

# debug(MakeHalvedAffineRegistration)
MakeSymmetricStandardBrain<-function(rawimage,symmetricimage){
	flippedimage= MakeFlippedImage(rawimage)
	
	imagestem=sub("\\.[^.]+$","",basename(rawimage))
	flippedimagestem=sub("\\.[^.]+$","",basename(flippedimage))
	regfolder=file.path(dirname(dirname(rawimage)),"Registration",
		paste(flippedimagestem,"_",imagestem,".list",sep=""))
	regfolder=CalculateRegistration(flippedimage,rawimage,regfolder)

	halvedregfolder=MakeHalvedAffineRegistration(regfolder)

	# ReformatImage(floating=rawimage,target=flippedimage,halvedregfolder,symmetricimage,dryrun=T)
	ReformatImage(floating=rawimage,target=rawimage,halvedregfolder,symmetricimage)
	# ReformatImage(floating=rawimage,target=rawimage,halvedregfolder,symmetricimage,
	# 	reformatxPath="/Users/jefferis/Downloads/CMTK-1.4.3-Darwin-i386/bin/reformatx")
}

MakeSymmetricStandardBrain(NEWREFPATH,SYMREFPATH)
