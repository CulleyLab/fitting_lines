close("*");
parent = "C:/Users/sedar/Documents/Seda_Radoykova/OneDrive - University College London/UCL/Culley_lab/fitting_lines/detectingLines/straightLinesSubset/";
destination = "C:/Users/sedar/Documents/Seda_Radoykova/OneDrive - University College London/UCL/Culley_lab/fitting_lines/detectingLines/skeletons/";
files = getFileList(parent);
SIGMA = 0.75;


// WORKFLOW: Duplicate > Gaussian blur [SIGMA] > Threshold [Triangle?] > Erode > Skeletonise

for (i=0; i<files.length; i++){
//for (i=10; i<11; i++){
	open(parent+files[i]);
	currTitle = getTitle();
	selectWindow(currTitle);
	rename("original"+"-"+i);
	nFrames = nSlices;
	
	// Gaussian blur
	selectWindow("original"+"-"+i);
	run("Duplicate...", "title=gaussian duplicate");
	selectWindow("gaussian");
	rename("gaussian"+"-sigma"+SIGMA+"-"+i);
	run("Gaussian Blur...", "sigma="+SIGMA+" stack");

	// thresholding 
	run("Duplicate...", "title=thresholding duplicate");
	selectWindow("thresholding");
	rename("thresholding"+"-sigma"+SIGMA+"-"+i);
	run("Auto Threshold", "method=Triangle white stack");
		
	// erode  
	run("Duplicate...", "title=erode duplicate");
	selectWindow("erode");
	rename("erode"+"-sigma"+SIGMA+"-"+i);
	setOption("BlackBackground", true);
	run("Erode", "stack");
		
	// skeletonise
	run("Duplicate...", "title=skeletonise duplicate");
	close("erode");
	selectWindow("skeletonise");
	rename("skeletonise"+"-sigma"+SIGMA+"-"+i);
	run("Skeletonize", "stack");
	save(destination+replace(currTitle,".tif","-skeletonised.tiff"));

	// all windows 
	//close("original"+"-"+i);
	//selectWindow("gaussian"+"-"+SIGMA[j]+"-"+j);
	close("thresholding"+"-sigma"+SIGMA+"-"+i);
	close("erode"+"-sigma"+SIGMA+"-"+i);
	//selectWindow("skeletonise"+"-"+SIGMA[j]+"-"+j);
	
	if (nFrames>1) {    // if stack, make montage with slice labels 
		
		labels = Array.getSequence(nFrames+1);
		
		selectWindow("gaussian"+"-sigma"+SIGMA+"-"+i);
		for (k = 0; k<nFrames; k++) {
			setSlice(k+1);
			label = labels[k+1];
			run("Set Label...", "label=&label");
			}
		run("Make Montage...", "columns="+nFrames+" rows=1 scale=1 label use");
		close("gaussian"+"-sigma"+SIGMA+"-"+i);
		
		selectWindow("skeletonise"+"-sigma"+SIGMA+"-"+i);
		for (k = 0; k<nFrames; k++) {
			setSlice(k+1);
			label = labels[k+1];
			run("Set Label...", "label=&label");
			}
		run("Make Montage...", "columns="+nFrames+" rows=1 scale=1 label use");
		close("skeletonise"+"-sigma"+SIGMA+"-"+i); 
	} 
	
	close("original"+"-"+i);
	run("Tile");
	//waitForUser("n-"+i+1, currTitle);
	close("*");
}
