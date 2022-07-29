// script assumes there are no ROI.zip files in dir
close("*");
SIGMA = 0.75;

dataDir = getDirectory("current"); 
dataDir = replace(dataDir, "\\", "/");
files = getFileList(dataDir);
destinationDir = dataDir+"../skeletonisedData/";


setBatchMode(false);

// WORKFLOW: Duplicate > Gaussian blur [SIGMA] > Threshold [Triangle?] > Erode > Skeletonise

//for (i=0; i<5; i++){
for (i=0; i<files.length; i++){
	open(dataDir+files[i]);
	currTitle = getTitle();
	selectWindow(currTitle);
	rename("original"+"-"+i);
	
	// Gaussian blur
	selectWindow("original"+"-"+i);
	run("Duplicate...", "title=gaussian");
	selectWindow("gaussian");
	rename("gaussian"+"-sigma"+SIGMA+"-"+i);
	run("Gaussian Blur...", "sigma="+SIGMA+" stack");

	// thresholding 
	run("Duplicate...", "title=thresholding");
	selectWindow("thresholding");
	rename("thresholding"+"-sigma"+SIGMA+"-"+i);
	run("Auto Threshold", "method=Triangle white");
		
	// erode  
	run("Duplicate...", "title=erode");
	selectWindow("erode");
	rename("erode"+"-sigma"+SIGMA+"-"+i);
	setOption("BlackBackground", true);
	run("Erode", "stack");
		
	// skeletonise
	run("Duplicate...", "title=skeletonise");
	close("erode");
	selectWindow("skeletonise");
	rename("skeletonise"+"-sigma"+SIGMA+"-"+i);
	run("Skeletonize", "stack");
	save(destinationDir+replace(currTitle,".tif","-skeletonised-")+i+".tiff");

	// all windows 
	//close("original"+"-"+i);
	//selectWindow("gaussian"+"-"+SIGMA[j]+"-"+j);
	close("thresholding"+"-sigma"+SIGMA+"-"+i);
	close("erode"+"-sigma"+SIGMA+"-"+i);
	//selectWindow("skeletonise"+"-"+SIGMA[j]+"-"+j);
	
	
	close("original"+"-"+i);
	run("Tile");
	//waitForUser("n-"+i+1, currTitle);
	close("*");
}

print("done");