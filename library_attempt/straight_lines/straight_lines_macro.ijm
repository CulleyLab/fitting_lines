
// reset ROI manager
//roiManager("reset");

// open file
open("C:\\Users\\sedar\\Documents\\Seda_Radoykova\\OneDrive - University College London\\UCL\\SUMMER_Sian\\fitting_lines\\data_copy\\141\\20190124-141-maxproj.sld - 30s-intervals - 1.Project Maximum Z-2.tif");

// format file name 
fileNameTiff = getTitle();
fileName = replace(fileNameTiff, ".tif", "");

selectWindow(fileNameTiff);

// make a results directory for given image
currPath = File.directory;
currPath = replace(currPath, "\\", "/");
fullPath = replace(currPath, "data_copy/141/", "library_attempt/straight_lines/"); 
//File.makeDirectory(fullPath);
print(fullPath);

// duplicating and saving ROIs 
nRois = roiManager("count");
//nRois = 2; // for debugging 

for (i=0; i<nRois; i++){
	selectWindow(fileName + ".tif");
	roiManager("Select", i);
	run("Duplicate...", "duplicate");
	save(fullPath + fileName + " - " + i + ".tif");	
}