//makeRectangle(600, 600, 128, 128);

//roiManager("save", "C:\\Users\\sedar\\Documents\\Seda_Radoykova\\OneDrive - University College London\\UCL\\SUMMER_Sian\\fitting_lines\\library_attempt\\straight_line_ROIs.zip");

/*
currPath = File.directory;
currPath = replace(currPath, "\\", "/");
print(currPath);
*/

// open file
open("C:\\Users\\sedar\\Documents\\Seda_Radoykova\\OneDrive - University College London\\UCL\\SUMMER_Sian\\fitting_lines\\data_copy\\141\\20190124-141-maxproj.sld - 30s-intervals - 1.Project Maximum Z-2.tif");

// format file name 
fileNameTiff = getTitle();
fileName = replace(fileNameTiff, ".tif", "");

selectWindow(fileNameTiff);

// make a results directory for given image
currPathR = File.directory;
print(currPathR);
currPath = replace(currPathR, "\\", "/");
print(currPath);
fullPath = replace(currPath, "data_copy/141/", "library_attempt/straight_lines/"); 
print(fullPath);