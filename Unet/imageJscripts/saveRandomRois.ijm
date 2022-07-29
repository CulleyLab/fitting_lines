/* 
 * 	Running this script with an open image 
 * 	saves the individual ROI frames as separate images.  
 * 	(Run with open image and set of ROIs). 
 */

setBatchMode(true);

// image info 
title = getTitle;
imTitle = replace(title, ".tif", "");

currPath = File.directory;
currPath = replace(currPath, "\\", "/");

// duplicate and save ROI images as stacks or as frames  
nRois = roiManager("count");

for (i=0; i<nRois; i++){
	selectWindow(title);
	roiManager("Select", i);
	run("Duplicate...", "title=roiCopy duplicate");
	nFrames = nSlices;
	//save(currPath+"../../Unet/rawData/"+imTitle+" - "+i+".tif");
	for (j=0; j<nFrames; j++){
		selectWindow("roiCopy");
		setSlice(j+1);
		run("Duplicate...", "use");
		save(currPath+"../../Unet/rawData/"+imTitle+" - "+i+"-"+j+".tif");
		run("Close");
	}
	selectWindow("roiCopy");
	run("Close");
}

print("Done!");
