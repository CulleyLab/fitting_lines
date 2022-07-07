// make new image with random line
newImage("Original line", "32-bit black", 25, 25, 1);
setBackgroundColor(0, 0, 0);
pointsInIm = 0;

while(pointsInIm<3){
	
	run("Select All");
	run("Clear");
	pointsInIm = 0;
	
	m = 5*(random-0.5);
	if(m>0) c = -10*random;
	else c = 10*random;
	x0 = round(random*15);
	length = 8;
	
	for(x=x0; x<x0+length; x++){
		if(x>=25) break;
		y = m*x + c;
		setPixel(x, round(y), 1);
	}
	pointsInIm = getNPointsInIm();
}
print("Target equation: y="+m+"*x +"+c);

xs = newArray(pointsInIm);
ys = newArray(pointsInIm);

counter = 0;
while(counter<pointsInIm){
	for(y=0; y<25; y++){
		for(x=0; x<25; x++){
			if(getPixel(x, y)==1){
				xs[counter] = x;
				ys[counter] = y;
				counter++;
			}
		}
	}
}

selectImage("Original line");
run("RGB Color");

maxD = round(sqrt(2*25*25));
minD = -maxD;
numDs = 2*maxD+1;
thetas = 180;

newImage("Individual Accumulators", "RGB color black", thetas, numDs, pointsInIm);
newImage("Sum Accumulator", "32-bit black", thetas, numDs, 1);

setBatchMode("hide");

for(i=0; i<pointsInIm; i++){
	x = xs[i];
	y = ys[i];
	hex = getRandomHex();
	
	selectImage("Original line");
	setPixel(x, y, parseInt(hex, 16));
	
	selectImage("Individual Accumulators");
	setSlice(i+1);

	for(t=0; t<thetas; t++){
		t_ = Math.toRadians(t);
		d = round(x*cos(t_) + y*sin(t_));
		selectImage("Individual Accumulators");
		setPixel(t, d+maxD, parseInt(hex, 16));
		selectImage("Sum Accumulator");
		setPixel(t, d+maxD, getPixel(t, d+maxD)+1);
	}
}

setBatchMode("exit and display");

selectImage("Individual Accumulators");
run("Z Project...", "projection=[Max Intensity]");

selectImage("Sum Accumulator");
run("Enhance Contrast", "saturated=0.35");
maxAcc = getIndOfMax();
theta = maxAcc[0];
d = maxAcc[1];
d -= maxD;
print("theta="+theta+", d="+d);

newImage("Found line", "32-bit black", 25, 25, 1);
x0 = d*cos(Math.toRadians(theta));
y0 = d*sin(Math.toRadians(theta));
//print("x0="+x0+", y0="+y0);
setPixel(x0, y0, 1);
m_ = -tan(Math.toRadians(90-theta));
c_ = y0 - m_*x0;
print("Found line: y = "+m_+"x + "+c_);

for(x=0; x<getWidth(); x++){
	setPixel(x, round(m_*x+c_), 1);
}

run("Tile");

function getNPointsInIm(){
	run("Select All");
	getStatistics(area, mean, min, max, std, histogram);
	return Math.ceil(mean*getWidth()*getHeight());
}

function getRandomHex(){
	r = round(random*255);
	g = round(random*255);
	b = round(random*255);
	
	R = toHex(r);
	G = toHex(g);
	B = toHex(b);

	if(lengthOf(R)<2) R = "0"+R;
	if(lengthOf(G)<2) G = "0"+G;
	if(lengthOf(B)<2) B = "0"+B;
	
	hex = R+B+G;
	return hex;
}

function getIndOfMax(){
	currMax = -100000;
	x_ = -1;
	y_ = -1;
	for(y=0; y<getHeight(); y++){
		for(x=0; x<getWidth(); x++){
			if(getPixel(x, y)>currMax){
				currMax = getPixel(x, y);
				x_ = x;
				y_ = y;
			}
		}
	}
	return newArray(x_, y_);
}
