macro "Add Straight [6]"{
	storeRoiType("straight");
}

macro "Add Curved [7]"{
	storeRoiType("curved");
}

macro "Add Intersecting [8]"{
	storeRoiType("intersecting");
}

macro "Add Other [9]"{
	storeRoiType("other");
}

//TODO: add any other classes that we want to curate e.g. 'unclear' (queer?), 'multiple'...

macro "Separate into types"{
	
	title = getTitle();
	titleClean = replace(title, ".tif", "");
	
	currPath = File.directory;
	parentPath = File.getParent(currPath);
	currPath = replace(currPath, "\\", "/");
	parentPath = replace(parentPath, "\\", "/");
	
	subStackPath = parentPath + "/subStacks/";

	originDir = split(currPath, "/");
	index = originDir.length-1;
	originDir = originDir[index];
	
	posStraight = "";
	posCurved = "";
	posIntersecting = "";
	posOther = "";

	// check if nSlices == nROIs in manager
	if (nSlices != roiManager("count")) {
		exit("Stack slices != nROIs in manager");
		
	} else {
		// save ROIs
		roiManager("save", subStackPath+"ROIs/"+titleClean+"-"+originDir+".zip");
		
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
			else if(endsWith(roiName, "other")){
				posOther = posOther+position+",";
			}
		}
	}

	// delete trailing comma
	posStraight = rmTrailingComma(posStraight);
	posCurved = rmTrailingComma(posCurved);
	posIntersecting = rmTrailingComma(posIntersecting);
	posOther = rmTrailingComma(posOther);
	
	// move slices to respective folders
	sortSliceToSubstack(title, titleClean, subStackPath, "straight", posStraight);
	sortSliceToSubstack(title, titleClean, subStackPath, "curved", posCurved);
	sortSliceToSubstack(title, titleClean, subStackPath, "intersecting", posIntersecting);
	sortSliceToSubstack(title, titleClean, subStackPath, "other", posOther);

}



function storeRoiType(arg){
	roiCount = roiManager("count"); // count how many rois are currently in manager
	run("Select All"); // add a roi that is size of image to this slice
	roiManager("Add"); // add roi to roi manager
	roiManager("select", roiCount); // select just-added roi
	roiManager("rename", Roi.getName+"-"+arg); // append string stored in 'arg' to end of roi name
}


//  del trailing comma
function rmTrailingComma(posString){
	if (posString.length > 0){
		posString = substring(posString, 0, posString.length-1);
	}
	return posString;
}



// move slices to respective folders
function sortSliceToSubstack(
	imgTitle, titleClean, subStackPath,
	lineType, posString
	){
		if (posString.length > 0){
			selectImage(imgTitle);
			run("Make Substack...", "slices="+posString);
			rename(titleClean+"-"+lineType);	
			save(subStackPath+lineType+"/"+titleClean+"-"+originDir+"-"+lineType+"Substack.tif");
			close("*");
			roiManager("reset");
		}
}

