// user defined params 
nRoisToGenerate = 10;	// number of desired ROIs
RoiWH = 128; 			// desired ROI width/height (assuming NxN input images) 
// threshold = mean + 1sd 

title = getTitle;
imTitle = replace(title, ".tif", "");
width = getWidth;
height = getHeight;
//depth = nSlices;

currPath = File.directory;
currPath = replace(currPath, "\\", "/");


// initialise arrays
nPoints = nRoisToGenerate * RoiWH * RoiWH;
totalXPoints = newArray();//newArray(nPoints);
totalYPoints = newArray(nPoints);

// process image
run("Duplicate...", "title=meanFilter duplicate");
run("Mean...", "radius=64 stack");

// get summary stats 
selectWindow("meanFilter");
run("Set Measurements...", "mean standard modal min median display redirect=meanFilter decimal=3");
run("Measure");
maxVal = getResult("Min", 0);
maxVal = getResult("Max", 0);
meanVal = getResult("Mean", 0);
stdVal = getResult("StdDev", 0);

threshold = round(meanVal+stdVal/2);
print("threshold ="+threshold);

// some functions
function generateInd(imWidth, imHeight, RoiWH){
	xInd = round(random()*width);
	yInd = round(random()*height);
	// can't have index too close to edges
	if (xInd < RoiWH/2) xInd = RoiWH/2; 
	if (yInd < RoiWH/2) yInd = RoiWH/2; 
	if (xInd > width-RoiWH/2) xInd = width-RoiWH/2;
	if (yInd > width-RoiWH/2) yInd = width-RoiWH/2;
	return newArray(xInd, yInd);
}

// first ROI
do { 
	inds = generateInd(width, height, RoiWH);
	xInd = inds[0];
	yInd = inds[1];
	pixIntensity = getValue(xInd, yInd);
	if (pixIntensity > threshold){
		// make and add ROI
		makeRectangle(xInd-RoiWH/2, yInd-RoiWH/2, RoiWH, RoiWH);
		roiManager("add");
		Roi.getContainedPoints(xpoints, ypoints);
		// transfer points to another array 
		totalXPoints = Array.concat(totalXPoints, xpoints);
		totalYPoints = Array.concat(totalYPoints, ypoints);	
	}
} while (roiManager("count") == 0);

// n-1 remaining ROIs
do {
	setBatchMode(true);
	selectWindow("meanFilter");
	inds = generateInd(width, height, RoiWH);
	xInd = inds[0];
	yInd = inds[1];
	pixIntensity = getValue(xInd, yInd);

	// make ROI; get contained points
	makeRectangle(xInd-RoiWH/2, yInd-RoiWH/2, RoiWH, RoiWH);
	Roi.getContainedPoints(xpoints, ypoints);

	overlapFlag = false;
	// check for overlap, looping over all ROIs
	if (pixIntensity > threshold){
		for (r=0; r<roiManager("count"); r++){
		roiManager("select", r);
			for (i=0; i<RoiWH*RoiWH; i++){
				x = xpoints[i];
				y = ypoints[i];
				if(Roi.contains(x, y)){
					overlapFlag = true;
					break;
					}
				}
		}

	}
	if (overlapFlag == false && pixIntensity > threshold){
		// make ROI; get contained points
		makeRectangle(xInd-RoiWH/2, yInd-RoiWH/2, RoiWH, RoiWH);
		Roi.getContainedPoints(xpoints, ypoints);
		roiManager("add");
		// transfer points to another array 
		totalXPoints = Array.concat(totalXPoints, xpoints);
		totalYPoints = Array.concat(totalYPoints, ypoints);
	}
	roiManager("deselect");
} while (roiManager("count") < nRoisToGenerate);

// close results 
selectWindow("Results"); 
run("Close" );
// sanity check that the nRois 
print("  nROIs = "+roiManager("count"));
print("  arrayMults = "+totalXPoints.length/(128*128));



// save ROIs
roiManager("save", currPath+"../../Unet/data/"+imTitle+"-ROIs"+".zip");

// duplicate and save ROI images as stacks  
nRois = roiManager("count");

for (i=0; i<nRois; i++){
	selectWindow(title);
	roiManager("Select", i);
	run("Duplicate...", "duplicate");
	save(currPath + "../../Unet/data/" + imTitle + " - " + i + ".tif");	
}



/* TODO:
 * convert image to 32 bit 
 * seinsibly set a threshold depending on pixel intensities
 * save images using title+nRoi+nSlice convention
 * save ROIs
 */



/* NOTES 
 * duplicate image  
 * mean filter, rad 64
 * select random ROIs, duplicate images, unstack, save
 * 		have a script which checks that ROIs don't overlap 
 * 		also threshold and select ROIs centered around p_intensity > threshold 
 * 	try to train CNN to perform skeletonisation 
 */