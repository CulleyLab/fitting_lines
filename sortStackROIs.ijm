macro "Add Straight [6]"{
	storeRoiType("straight");
}

macro "Add Curved [7]"{
	storeRoiType("curved");
}

macro "Add Intersecting [8]"{
	storeRoiType("intersecting");
}

//TODO: add any other classes that we want to curate e.g. 'unclear' (queer?), 'multiple'...

macro "Separate into types"{

	title = getTitle();
	titleClean = replace(title, ".tif", "");
	
	currPath = File.directory;
	currPath = replace(currPath, "\\", "/");
	// this replaces straightLineStacks but images could be in other dir...
	subStackPath = replace(currPath, "straightLineStacks/", "subStacks/");
	
	posStraight = "";
	posCurved = "";
	posIntersecting = "";

	// check if nSlices == nROIs in manager
	if (nSlices != roiManager("count")) {
		exit("Stack slices != nROIs in manager");
		
	} else {
		// save ROIs
		roiManager("save", subStackPath+"ROIs/"+titleClean+".zip");
		
		// assign slice positions to categories
		for(i=0; i<roiManager("count"); i++){
			roiManager("select", i);
			roiName = Roi.getName;
			position = getSliceNumber();
		
			if(endsWith(roiName, "straight")){
				posStraight = posStraight+position+",";
			} 
			else if(endsWith(roiName, "curved")){
				posCurved = posCurved+position+",";
			} 
			else if(endsWith(roiName, "intersecting")){
				posIntersecting = posIntersecting+position+",";
			}
		}
	}
	
	// delete trailing comma
	posStraight = substring(posStraight, 0, posStraight.length-1);
	posCurved = substring(posCurved, 0, posCurved.length-1);
	posIntersecting = substring(posIntersecting, 0, posIntersecting.length-1);

	// move slices to respective folders
	selectImage(title);
	run("Make Substack...", "slices="+posStraight);
	rename(titleClean+"-straight");	
	save(subStackPath+"straight/"+titleClean+"-straightSubstack.tif");	
		
	selectImage(title);
	run("Make Substack...", "slices="+posCurved);
	rename(titleClean+"-curved");	
	save(subStackPath+"curved/"+titleClean+"-curvedSubstack.tif");	
		
	selectImage(title);
	run("Make Substack...", "slices="+posIntersecting);
	rename(titleClean+"-intersecting");
	save(subStackPath+"intersecting/"+titleClean+"-intersectingSubstack.tif");		
}



function storeRoiType(arg){
	roiCount = roiManager("count"); // count how many rois are currently in manager
	run("Select All"); // add a roi that is size of image to this slice
	roiManager("Add"); // add roi to roi manager
	roiManager("select", roiCount); // select just-added roi
	roiManager("rename", Roi.getName+"-"+arg); // append string stored in 'arg' to end of roi name
}


