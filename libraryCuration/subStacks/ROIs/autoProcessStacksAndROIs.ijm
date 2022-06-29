// Fixing the nightmare of duplicating file names.... 
// has been run for straight and curved lines on extant ROIs

stackPath ="C:/Users/sedar/Documents/Seda_Radoykova/OneDrive - University College London/UCL/Culley_lab/fitting_lines/libraryCuration/";
roiPath ="C:/Users/sedar/Documents/Seda_Radoykova/OneDrive - University College London/UCL/Culley_lab/fitting_lines/libraryCuration/subStacks/ROIs/";

lineType = getString("which line type?", "straight");

stackList = getFileList(stackPath+lineType+"LineStacks/");
stackList = Array.slice(stackList, 0, stackList.length-1);
roiList = getFileList(roiPath+lineType+"LineStacks/");

//print("nStacks = "+stackList.length+"    nROIs = "+roiList.length); 

for (i=0; i<stackList.length; i++){
	open(stackPath+lineType+"LineStacks/"+stackList[i]);
	roiManager("open", roiPath+lineType+"LineStacks/"+roiList[i]);
	selectWindow(stackList[i]);
	run("Separate into types");
	close("*");
	roiManager("reset");
}