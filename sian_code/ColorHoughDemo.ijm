Dialog.create("Quick linear Hough transform");
items = newArray("Run on simulation", "Run on skeleton", "Run on raw");
Dialog.addChoice("What do you want to do?", items);
Dialog.show();

toDo = Dialog.getChoice();

title = "";
w = 0; h = 0;

if(toDo==items[0]){

	showMessageWithCancel("Continue with macro?", "Pressing OK will clear all current images and log, otherwise cancel!");
	close("*");
	print("\\Clear");
	
	title = "Simulated line";

	w = 25; h = 25;
	newImage(title, "32-bit black", w, h, 1);
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
			if(x>=w) break;
			y = m*x + c;
			setPixel(x, round(y), 1);
		}
		pointsInIm = getNPointsInIm();
		if(isNaN(pointsInIm)) pointsInIm=0;
	}
	print("Target equation: y="+m+"*x +"+c);
	
	xs = newArray(pointsInIm);
	ys = newArray(pointsInIm);
	
	counter = 0;
	while(counter<pointsInIm){
		for(y=0; y<h; y++){
			for(x=0; x<w; x++){
				if(getPixel(x, y)==1){
					xs[counter] = x;
					ys[counter] = y;
					counter++;
				}
			}
		}
	}
}
else if(toDo==items[1]){
	title = getTitle();
	w = getWidth(); h = getHeight();

	if(is("Inverting LUT")) run("Invert LUT");

	pointsInIm = getNPointsInIm();

	xs = newArray(pointsInIm);
	ys = newArray(pointsInIm);
	
	counter = 0;
	while(counter<pointsInIm){
		for(y=0; y<getHeight(); y++){
			for(x=0; x<getWidth(); x++){
				if(getPixel(x, y)==255){
					xs[counter] = x;
					ys[counter] = y;
					counter++;
				}
			}
		}
	}
	
}
else{
	title = getTitle();
	w = getWidth();
	h = getHeight();

	pointsInIm = w*h;
	xs = newArray(pointsInIm);
	ys = newArray(pointsInIm);
	ws = newArray(pointsInIm);

	getRawStatistics(nPixels, mean, min, max, std, histogram);
	
	for(y=0; y<h; y++){
		for(x=0; x<w; x++){
			ind = y*w + x;
			xs[ind] = x;
			ys[ind] = y;
			ws[ind] = (getPixel(x, y)-min)/(max-min);
		}
	}
}

selectImage(title);
run("RGB Color");

maxD = round(sqrt(getWidth()*getWidth()+getHeight()*getHeight()));
minD = -maxD;
numDs = 2*maxD+1;
thetas = 180;

if(toDo!=items[2]) newImage("Individual Accumulators", "RGB color black", thetas, numDs, pointsInIm);
else newImage("Individual Accumulators", "RGB color black", thetas, numDs, 1);

newImage("Sum Accumulator", "32-bit black", thetas, numDs, 1);

setBatchMode("hide");

for(i=0; i<pointsInIm; i++){
	showProgress(i+1, pointsInIm);
	x = xs[i];
	y = ys[i];
	weight = 1;
	if(toDo==items[2]) weight = ws[i];
	
	if(toDo!=items[2]) hex = getRandomHex();
	else hex = getRandomHex(weight);
	
	selectImage(title);
	setPixel(x, y, parseInt(hex, 16));
	
	selectImage("Individual Accumulators");
	if(toDo!=items[2]) setSlice(i+1);

	for(t=0; t<thetas; t++){
		if(t==45||t==135) continue;
		t_ = Math.toRadians(t*(thetas/180));
		d = round(x*cos(t_) + y*sin(t_));
		selectImage("Individual Accumulators");
		setPixel(t, d+maxD, parseInt(hex, 16));
		selectImage("Sum Accumulator");
		setPixel(t, d+maxD, getPixel(t, d+maxD)+weight);
	}
}

setBatchMode("exit and display");

selectImage("Individual Accumulators");
if(toDo!=items[2]) run("Z Project...", "projection=[Max Intensity]");

selectImage("Sum Accumulator");
run("Enhance Contrast", "saturated=0.35");
nMax = 5;
minDist = 8;
maxAcc = getIndOfNBestMax(nMax, minDist);
setBatchMode("exit and display");
newImage("Found line", "32-bit black", w, h, 1);

for(n=0; n<nMax; n++){
	theta = maxAcc[n*2];
	d = maxAcc[n*2+1];
	d -= maxD;
	print("theta="+theta+", d="+d);
	
	x0 = d*cos(Math.toRadians(theta));
	y0 = d*sin(Math.toRadians(theta));
	//print("x0="+x0+", y0="+y0);
	setPixel(x0, y0, nMax-n);
	m_ = -tan(Math.toRadians(90-theta));
	c_ = y0 - m_*x0;
	print("Found line: y = "+m_+"x + "+c_);
	
	for(x=0; x<w; x++){
		setPixel(x, round(m_*x+c_), nMax-n);
	}
}

run("Tile");


function getNPointsInIm(){
	run("Select All");
	getStatistics(area, mean, min, max, std, histogram);
	return Math.ceil(mean*getWidth()*getHeight()/max);
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

function getRandomHex(weight){
	r = round(random*255*weight);
	g = round(random*255*weight);
	b = round(random*255*weight);
	
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

function getIndOfNBestMax(N, minDist){
	setBatchMode("hide");
	
	run("Duplicate...", "title=test");
	selectImage("test");
	result = newArray(2*N);
	
	for(n=0; n<N; n++){
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
		result[2*n]=x_;
		result[2*n+1]=y_;

		for(x=x_-minDist; x<=x_+minDist; x++){
			for(y=y_-minDist; y<=y_+minDist; y++){
				setPixel(x, y, 0);
			}
		}
	}
	close("test");
	return result;
}
