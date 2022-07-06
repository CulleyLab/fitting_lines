close("*");
files = getFileList("C:/Users/sedar/OneDrive/Desktop/trying things wtihout ruining the data/batch");
SIGMA = newArray(0.75, 1, 1.25);
bestSigma = newArray(files.length);

// Testing multiple sigma values
	// In the pop-up window enter the number of the best frame (starting from 1)
	// 0 none are great; 4 all are great; 5 can't see very well due to large number of panes

// WORKFLOW: Duplicate > Gaussian blur [SIGMA] > Threshold [Triangle?] > Erode > Skeletonise
// In the end, see Gaussian + skeletonised image

for (i=0; i<files.length; i++){
	
	open(files[i]);
	currTitle = getTitle();
	selectWindow(currTitle);
	rename("original"+"-"+i);
	nStacks = nSlices;
	
	for (j=0; j<SIGMA.length; j++){
		// Gaussian blur
		selectWindow("original"+"-"+i);
		run("Duplicate...", "title=gaussian duplicate");
		selectWindow("gaussian");
		rename("gaussian"+"-"+SIGMA[j]+"-"+j);
		run("Gaussian Blur...", "sigma="+SIGMA[j]+" stack");

		// thresholding 
		run("Duplicate...", "title=thresholding duplicate");
		selectWindow("thresholding");
		rename("thresholding"+"-"+SIGMA[j]+"-"+j);
		run("Auto Threshold", "method=Triangle white stack");
		
		// erode  
		run("Duplicate...", "title=erode duplicate");
		selectWindow("erode");
		rename("erode"+"-"+SIGMA[j]+"-"+j);
		setOption("BlackBackground", true);
		run("Erode", "stack");
		
		// skeletonise
		run("Duplicate...", "title=skeletonise duplicate");
		close("erode");
		selectWindow("skeletonise");
		rename("skeletonise"+"-"+SIGMA[j]+"-"+j);
		run("Skeletonize", "stack");

		//close("original"+"-"+i);
		//selectWindow("gaussian"+"-"+SIGMA[j]+"-"+j);
		close("thresholding"+"-"+SIGMA[j]+"-"+j);
		close("erode"+"-"+SIGMA[j]+"-"+j);
		//selectWindow("skeletonise"+"-"+SIGMA[j]+"-"+j);
		if (nStacks>1) {
			selectWindow("gaussian"+"-"+SIGMA[j]+"-"+j);
			run("Make Montage...", "columns=1 rows="+nStacks+" scale=1");
			close("gaussian"+"-"+SIGMA[j]+"-"+j);
	
			selectWindow("skeletonise"+"-"+SIGMA[j]+"-"+j);
			run("Make Montage...", "columns=1 rows="+nStacks+" scale=1 labels");
			close("skeletonise"+"-"+SIGMA[j]+"-"+j); 
		} 
	}
	close("original"+"-"+i);
	run("Tile");
	bestSigma[i] = getNumber("Best sigma:", 0);
	close("*");
}

Array.print(bestSigma);

/*  According to my neat little experiment (below)
 *  MaxEntropy, RenyEntropy, Otsu, Moments, and Triangle 
 *  perform best (in somewhat ascending order)
 */


 /*
for (i=0; i<files.length; i++){
	open(files[i]);
	currTitle = getTitle();
	print(currTitle);
	selectWindow(currTitle);
	rename("original");
	
	run("Duplicate...", "title=gaussian duplicate");
	selectWindow("gaussian");
	run("Gaussian Blur...", "sigma="+SIGMA+" stack");
	
	run("Duplicate...", "title=thresholding duplicate");
	selectWindow("thresholding");
	run("Auto Threshold", "method=[Try all] white show stack");
	
	close("gaussian"); 
	close("thresholding");
}
*/
