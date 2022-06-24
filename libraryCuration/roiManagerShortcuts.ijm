macro "Add Curved [7]"{
	storeRoiType("curved");
}

macro "Add Intersecting [8]"{
	storeRoiType("intersecting");
}

//macro "Separate into types"{
//	posStraight = "";
//	posCurved = "";
//	posIntersecting = "";
//	
//	for(i=0; i<roiManager("count"); i++){
//		roiManager("select", i);
//		roiName = Roi.getName;
//		position = getSliceNumber();
//		
//		if(endsWith(roiName, "curved")){
//			posCurved = posCurved+position+",";
//		}
//
//	}
//}

function storeRoiType(arg){
	roiCount = roiManager("count"); // count how many rois are currently in manager
	run("Select All"); // add a roi that is size of image to this slice
	roiManager("Add"); // add roi to roi manager
	roiManager("select", roiCount); // select just-added roi
	roiManager("rename", Roi.getName+"-"+arg); // append string stored in 'arg' to end of roi name
}


