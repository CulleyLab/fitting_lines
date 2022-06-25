macro "Add Straight [6]"{
	storeRoiType("straight");
}

macro "Add Curved [7]"{
	storeRoiType("curved");
}

macro "Add Intersecting [8]"{
	storeRoiType("intersecting");
}

macro "Separate into types"{
	nFrames = nSlices;
	
	if(nFrames!=roiManager("count")){
		exit("Number of ROIs does not match number of frames! :-(");
	}
	
	title = getTitle();
	
	posStraight = "";
	posCurved = "";
	posIntersecting = "";
	
	//TODO: add any other classes that we want to curate e.g. 'unclear', 'multiple'...
	
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
	
	// delete trailing comma
	posStraight = substring(posStraight, 0, posStraight.length-1);
	posCurved = substring(posCurved, 0, posCurved.length-1);
	posIntersecting = substring(posIntersecting, 0, posIntersecting.length-1);
	
	selectImage(title);
	run("Make Substack...", "slices="+posStraight);
	rename(title+"-straight");	
	
	selectImage(title);
	run("Make Substack...", "slices="+posCurved);
	rename(title+"-curved");	
	
	selectImage(title);
	run("Make Substack...", "slices="+posIntersecting);
	rename(title+"-intersecting");
}

// Installation instructions!!
// https://imagej.nih.gov/ij/developer/macro/macros.html#:~:text=it%20starts%20up.-,Keyboard%20Shortcuts,-A%20macro%20in

function storeRoiType(arg){
	roiCount = roiManager("count"); // count how many rois are currently in manager
	run("Select All"); // add a roi that is size of image to this slice
	roiManager("Add"); // add roi to roi manager
	roiManager("select", roiCount); // select just-added roi
	roiManager("rename", Roi.getName+"-"+arg); // append string stored in 'arg' to end of roi name
}


