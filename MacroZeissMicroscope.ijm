//////////////////////////////////////////////////////////////
// M I S C E L L A N E O U S
//
// Macro name: Build methods paragraph based on metadata of an image
// Required files: not at the start
//
// 
//
// Copyright (c) 2022 by Richard De Mets, adapted from MethodsJ2 developed by Ryan J. et al (Nature Methods 2021, https://github.com/ABIF-McGill/MethodsJ2) 
// The goal is to have the macro to work on Zeiss acquired images without the need of Micro-Meta App software.
// version 0.0.1
// Permission is granted to use, modify and distribute this code,
// as long as this copyright notice remains part of the code.
//
//
//
// To Do : Gain and binning ?
//
//
//////////////////////////////////////////////////////////////


print("\\Clear");
microscopeName = Property.get("Information|Instrument|Microscope|Name");
microscopeType = Property.get("Information|Instrument|Microscope|Type");
contrastType = Property.get("Information|Image|Channel|ContrastMethod");
detectorType = Property.get("Information|Instrument|Detector|Type");	

if (microscopeName=="") {
	infoMicroscope = Property.get("Information|Instrument|Microscope|System");
	infoTab = split(infoMicroscope,",");
	microscopeName = infoTab[1];
	microscopeType = infoTab[0];
}

acquisitionMode = Property.get("Information|Image|Channel|AcquisitionMode");
if (acquisitionMode=="") {
	acquisitionMode = Property.get("Information|Image|Channel|AcquisitionMode #1");
}

if (contrastType=="") {
	contrastType = Property.get("Information|Image|Channel|ContrastMethod #1");
}

if (detectorType=="") {
	detectorType = Property.get("Information|Instrument|Detector|Type #1");
}

cameraName = Property.get("Scaling|AutoScaling|CameraName");
applicationName = Property.get("Information|Application|Name");
objectiveName = Property.get("Information|Instrument|Objective|Manufacturer|Model");

sizeX = Property.get("SizeX");
sizeY = Property.get("SizeY");
sizeZ = Property.get("SizeZ");
sizeC = Property.get("SizeC");
sizeT = Property.get("SizeT");
dimensionOrder = Property.get("DimensionOrder");
getVoxelSize(width, height, depth, unit);
resolution = Property.get("Resolution");



desc_ch = "\r\r";



if (startsWith(acquisitionMode, "Laser")) {
	acqMode = "laser scanning confocal";
	zStep = Property.get("Information|Image|Z|Interval|Increment");
	if (sizeZ==1) {
		voxels = String.format("%.3f", width)+"x"+String.format("%.3f", height);
	}
	else {
		
		voxels = String.format("%.3f", width)+"x"+String.format("%.3f", height)+"x"+String.format("%.3f", depth);
	}

	desc_microscope = contrastType+" images were acquired on a "+microscopeName+" "+cameraName+" "+microscopeType+" microscope with a "+detectorType+" detector, configured for "+acqMode+" microscopy, controlled with "+applicationName+" software, equipped with a "+objectiveName+" objective (Zeiss)."; 
	
	for (i = 1; i <= sizeC; i++) {
	
		channelFluo = Property.get("Information|Image|Channel|Fluor #"+i);
		laserFluo = Property.get("Information|Image|Channel|ExcitationWavelength #"+i);
		rangeFilter = Property.get("Information|Image|Channel|DetectionWavelength|Ranges #"+i);
		pixelTime = Property.get("Information|Image|Channel|LaserScanInfo|PixelTime #"+i);
		time = String.format("%.2f", parseFloat(pixelTime)*1000000);
		desc_ch = desc_ch + channelFluo + " channel was imaged using "+ parseInt(laserFluo) +" nm laser for excitation with "+rangeFilter+" nm emission filter. Pixel dwell time was set at "+time+" µs/px. \r";

		desc_image = "Images had a dimension of "+sizeX+" x "+sizeY+" pixels with "+sizeZ+" plane(s), "+sizeC+" channel(s) and "+sizeT+" timepoint(s). Voxels have a size of "+voxels+" "+unit+".";
	}	

}

if (startsWith(acquisitionMode, "Wide")) {
	
	acqMode = "widefield microscopy";
	desc_microscope = contrastType+" images were acquired on a "+microscopeName+" "+toLowerCase(microscopeType)+" microscope with "+cameraName+" detector, controlled with "+applicationName+" software, equipped with a "+objectiveName+" objective (Zeiss)."; 
	pixelTime = Property.get("Information|Image|Channel|ExposureTime");
	tileTime = parseInt(pixelTime)/1000;
	tileOverlap = Property.get("Experiment|AcquisitionBlock|RegionsSetup|SampleHolder|Overlap");
	tileOverlap = parseFloat(tileOverlap)*100;
	tileX = Property.get("Experiment|AcquisitionBlock|RegionsSetup|SampleHolder|TileDimension|Width");
	tileY = Property.get("Experiment|AcquisitionBlock|RegionsSetup|SampleHolder|TileDimension|Height");

	desc_ch = "Tiles of "+tileX+" x "+tileY+" pixels with "+tileOverlap+"% overlap were used to reconstruct the final image. Single tile exposure was set at "+tileTime+" ms per image. \r";
	desc_image = "Images had a dimension of "+sizeX+" x "+sizeY+" pixels with "+sizeZ+" plane(s), "+sizeC+" channel(s) and "+sizeT+" timepoint(s). Pixels have a size of "+String.format("%.3f", width)+"x"+String.format("%.3f", height)+" "+unit+".";
}





//dyeName = Property.get("Information|Instrument|Microscope|Name")Information|Image|Channel|Name #1
//desc_image = "Images had a dimension of "+sizeX+" x "+sizeY+" pixels with "+sizeZ+" plane(s), "+sizeC+" channel(s) and "+sizeT+" timepoint(s). Voxels had a size of "+String.format("%.3f", width)+"x"+String.format("%.3f", height)+"x"+String.format("%.3f", depth)+" "+unit+".";






ack = "\r\rAcknowledgements: \rImages were collected and/or image processing and analysis for this manuscript was performed in the Core Facilities of Integrated Microscopy (CFIM) at University of Copenhagen."; 



print(desc_microscope);
print(desc_image);
print(desc_ch);
print("\r\r"+ack);

