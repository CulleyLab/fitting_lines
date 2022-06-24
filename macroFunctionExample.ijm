n1 = 4;
n2 = 5;
result = calculator(n1, n2);

IJ.log("Calculator ran on numbers "+n1+" and "+n2+" and the results were: sum="+result[0]+", diff="+result[1]+"..."+result[2]);

checkStillNumber = result[0] + 1;
IJ.log(checkStillNumber);



function addNumbers(num1, num2){
	sum = num1 + num2;
	return sum;
}

function calculator(num1, num2){
	sum = num1 + num2;
	diff = num1 - num2;
	randomString = "hello!";
	return newArray(sum, diff, randomString);
}
