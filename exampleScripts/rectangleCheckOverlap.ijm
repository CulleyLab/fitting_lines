nPoints = 3*128*128;
totalXPoints = newArray(nPoints);
totalYPoints = newArray(nPoints);

x1 = 100;
y1 = 100;
makeRectangle(x1-64, y1-64, 128, 128);
roiManager("add");
Roi.getContainedPoints(xpoints, ypoints);
for(i=0; i<128*128; i++){
	totalXPoints[i] = xpoints[i];
	totalYPoints[i] = ypoints[i];
}

x2 = 400;
y2 = 400;
makeRectangle(x2-64, y2-64, 128, 128);
Roi.getContainedPoints(xpoints, ypoints);
overlapFlag = false;
for(r=0; r<roiManager("count")-1; r++){
	roiManager("select", r);
	for(i=0; i<128*128; i++){
		x = xpoints[i];
		y = ypoints[i];
		if(Roi.contains(x, y);){
			print("There is overlap!!");
			overlapFlag = true;
		}
	}
}
if(overlapFlag==false){
	roiManager("add");
	for(i=0; i<128*128; i++){
	totalXPoints[2*i] = xpoints[i];
	totalYPoints[2*i] = ypoints[i];
	}
}

x3 = 150;
y3 = 150;
makeRectangle(x3-64, y3-64, 128, 128);
Roi.getContainedPoints(xpoints, ypoints);
overlapFlag = false;
for(r=0; r<roiManager("count")-1; r++){
	roiManager("select", r);
	for(i=0; i<128*128; i++){
		x = xpoints[i];
		y = ypoints[i];
		if(Roi.contains(x, y)){
			print("There is overlap!!");
			overlapFlag = true;
			break;
		}
	}
}
if(overlapFlag==false){
	roiManager("add");
	for(i=0; i<128*128; i++){
	totalXPoints[3*i] = xpoints[i];
	totalYPoints[3*i] = ypoints[i];
	}
}