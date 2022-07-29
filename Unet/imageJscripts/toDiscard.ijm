// open frames as stack and run script to delete ugly frames 
// which were added to ROI manager 
// 		note that both raw/skeletonised stack and the ROI manager must be open  

nRois = roiManager("count");
slices = newArray(nRois);
dir = getDirectory("current");

setBatchMode(true);

// get slice indecies 
for (i=0; i<nRois; i++){
	roiManager("select", i);
	slices[i] = getSliceNumber();
}
print("total slices "+slices.length);

// check initial no. frames 
selectWindow("rawData");
nTotalSlices = nSlices;
print("start "+nTotalSlices);
roiManager("deselect");


// Get a stack of the frames to be deleted   
//for (i=nRois-1; i>=0; i--){
//	roiManager("deselect");
//	ind = slices[i];
//	selectWindow("skeletonisedData");
//	setSlice(ind);
//	run("Duplicate...", "title=slice-"+ind);
//}
//imTitle = "aergrth-"
//run("Images to Stack", "name="+imTitle+" title=[] use");
//print("done");

// loop over raw and binary data to delete frames
for (j=nRois-1; j>=0; j--){
	roiManager("deselect");
	ind = slices[j];
	selectWindow("rawData");
	setSlice(ind);
	run("Delete Slice");
	selectWindow("skeletonisedData");
	setSlice(ind);
	run("Delete Slice");
	roiManager("deselect");
}

// check final no. frames 
selectWindow("rawData");
nTotalSlices = nSlices;
print("end "+nTotalSlices);

// save stacks as individual images 
selectWindow("rawData");
path = dir+"rawCurated/"
run("Image Sequence... ", "format=TIFF name=rawData- save="+path+"rawData-0000.tif");

selectWindow("skeletonisedData");
path = dir+"skeletonisedCurated/"
run("Image Sequence... ", "format=TIFF name=skeletonisedData- save="+path+"skeletonisedData-0000.tif");

print("files saved");