#include <iostream>
#include <fstream>
#include <string>
#include <bitset>
#include <sstream>
#include <bitset>		/* used to read/write from/to the text files */
#include <stdio.h>		/* printf */
#include <assert.h>		/* assert */
#include <stdlib.h>		/* std */
#include <cmath>
using namespace std;

////////////global variables/////////////////////////////////
//the test file names are changed manually for all the test files
string testfile = "test1.txt";
string testfile_add_output = "test1_add_output.txt";
string testfile_mul_output = "test1_mul_output.txt";

string testfile_div_output = "test1_gold_div_output.txt";
string testfile_div_output2 = "test1_newton_div_output.txt";

//testing of functions with 1 input
string testfile_oneInput = "test1_oneInput.txt";
string testfile_sqrt_output = "test1_sqrt_output.txt";

string testfile_invSqrt_output = "test1_invSqrt_output.txt";
string testfile_invSqrt_output2 = "test1_invSqrt2_output.txt";

//testing of function with 3 inputs
string testfile_threeInputs = "test1_threeInputs.txt";
string testfile_fma_output = "test1_fma_output.txt";

//////////////////floating point struct//////////////////////
struct fp_t{
	int s;	//sign
	int e;	//exponent
	int m;	//mantissa
};

//////////////////////function prototypes////////////////////
fp_t unpack_f(float a_f);
fp_t header(float a_f);
float pack_f(fp_t a_fp);
float footer(fp_t a_fp);
int footer_i(fp_t a_fp);
int extractBits(int, int, int);
void round_norm(fp_t &z, int, int);

fp_t adder(fp_t, fp_t, bool);	//takes in 32-bit floating point numbers and return sum
fp_t multiplier(fp_t, fp_t);

fp_t fma(float, float, float);

fp_t gold_divider(fp_t, fp_t);
fp_t newton_divider(fp_t, fp_t);

fp_t newton_rooter(fp_t);

fp_t newton_inverse_rooter(fp_t);
fp_t quake_inverse_rooter(fp_t);

//functions for testing
int testCodeAddition();
int testCodeMultiplication();

int testCodeDivision();				//gold
int testCodeDivision2();			//newton
int testCodeSquareRoot();			//newton square root
int testCodeInverseSquareRoot();	//newton inverse square root
int testCodeInverseSquareRoot2();	//quake inverse square root

int testFMA();						//test the FMA

//////////////////////main function//////////////////////////
int main(){
	//call the function for testing addition
	int add_test = testCodeAddition();
	
	//call function for testing multiplication
	int mul_test = testCodeMultiplication();

	//call function for testing division
	int div_test = testCodeDivision();
	int div_test2 = testCodeDivision2();

	//call function for testing the square root 
	int sqrt_test = testCodeSquareRoot();

	//call function for testing the inverse square root
	int invSqrt_test = testCodeInverseSquareRoot();
	int invSqrt2_test = testCodeInverseSquareRoot2();

	//check the return value of the functions
	if (add_test != 0 || mul_test != 0 || div_test != 0 || div_test2 != 0 || sqrt_test != 0 || invSqrt_test != 0 || invSqrt2_test != 0)
		cout << "error";
	return 0;
}

/////////////////////functions////////////////////////////
fp_t unpack_f(float a_f){
fp_t a_fp;
int index;
float rem;
float place;

if(a_f == 0.0){
a_fp.s = 0;
a_fp.e = 0;
a_fp.m = 0;
return a_fp;
}
if(a_f == -0.0){
a_fp.s = 1;
a_fp.e = 0;
a_fp.m = 0;
return a_fp;
}
if(a_f > 3.4e38){
a_fp.s = 0;
a_fp.e = 0xFF;
a_fp.m = 0;
return a_fp;
}
if(a_f < -3.4e38){
a_fp.s = 1;
a_fp.e = 0xFF;
a_fp.m = 0;
return a_fp;
}

if(a_f < 0){
a_fp.s = 1;
}else{
a_fp.s = 0;
}

index = floor(logf(fabs(a_f))/logf(2.0));
a_fp.e = 0x7F+index;

rem = (abs(a_f)/pow(2.0,index))-1;

a_fp.m = 0x0;
for(int i = 1; i <= 22; i++){
place = pow(2.0,-i);
if((rem - place) >= 0){
a_fp.m <<= 1;
a_fp.m++;
rem = rem - place;
}else{
a_fp.m <<= 1;
}
}

a_fp.m <<= 1;

return a_fp;
}

fp_t header(float a_f){
fp_t a_fp;
int index;
float rem;
float place;

// Convert to struct
if(a_f == 0.0){
a_fp.s = 0;
a_fp.e = 0;
a_fp.m = 0;
return a_fp;
}
if(a_f == -0.0){
a_fp.s = 1;
a_fp.e = 0;
a_fp.m = 0;
return a_fp;
}
if(a_f > 3.4e38){
a_fp.s = 0;
a_fp.e = 0xFF;
a_fp.m = 0;
return a_fp;
}
if(a_f < -3.4e38){
a_fp.s = 1;
a_fp.e = 0xFF;
a_fp.m = 0;
return a_fp;
}

if(a_f < 0){
a_fp.s = 1;
}else{
a_fp.s = 0;
}

index = floor(logf(fabs(a_f))/logf(2.0));
a_fp.e = 0x7F+index;

rem = (abs(a_f)/pow(2.0,index))-1;

a_fp.m = 0x0;
for(int i = 1; i <= 22; i++){
place = pow(2.0,-i);
if((rem - place) >= 0){
a_fp.m <<= 1;
a_fp.m++;
rem = rem - place;
}else{
a_fp.m <<= 1;
}
}

a_fp.m <<= 1;

cout<<a_f<<": "<<dec<<a_fp.s<<"-"<<a_fp.e<<"-"<<hex<<a_fp.m<<endl;

// Create significand
if(a_fp.e != 0){
a_fp.m |= 0x00800000;
}

return a_fp;
}

float pack_f(fp_t a_fp){
int a_i;
float a_f;
a_i = (a_fp.s << 31)+((a_fp.e<<23)&0x7F800000)+(a_fp.m&0x007FFFFF);
a_f = *(float*)&a_i;
return a_f;
}

float footer(fp_t a_fp){
int a_i;
float a_f;

// Rounding and normalisation
if(a_fp.m != 0){
int lzd = 25;
int found = 0;
int err;
while(!found){
err = extractBits(lzd,lzd,a_fp.m);
//cout<<"lzd: "<<dec<<lzd<<endl;
//cout<<"err: "<<dec<<err<<endl;
if(err == 1){
found = 1;
}else{
lzd--;
}
}

lzd = lzd - 23;
if(lzd > 0){
a_fp.m >>= lzd;
}else{
a_fp.m <<= -lzd;
}
a_fp.e += lzd;

// Remove significand's leading 1 bit
a_fp.m &= 0x007FFFFF;
}
//cout<<"Result: "<<a_fp.s<<"-"<<dec<<a_fp.e<<"-"<<hex<<a_fp.m<<endl;

// Convert to float
a_i = (a_fp.s << 31)+((a_fp.e<<23)&0x7F800000)+(a_fp.m&0x007FFFFF);
a_f = *(float*)&a_i;
return a_f;
}

int footer_i(fp_t a_fp){
int a_i;

// Remove significand's leading 1 bit
a_fp.m &= 0x007FFFFF;
cout<<"Result: "<<dec<<a_fp.s<<"-"<<a_fp.e<<"-"<<hex<<a_fp.m<<endl;	

// Convert to int
a_i = (a_fp.s << 31)+((a_fp.e<<23)&0x7F800000)+(a_fp.m&0x007FFFFF);
return a_i;
}

int extractBits(int a, int b, int z){
z = z>>a;
//cout<<hex<<z<<endl;

int n = 0x1;
for(int i=a; i<b; i++){
n <<=1;
//cout<<hex<<n<<" ";
n++;
//cout<<hex<<n<<endl;
}

int m = n&z;
/*cout<<dec<<a<<" "<<b<<endl;
cout<<hex<<n<<endl
<<hex<<z<<endl<<endl;*/
//cout<<"m: "<<hex<<m<<endl;
return m;
}

void round_norm(fp_t &z, int lostbit_high, int lostbit_low){
int LSB;

// Normalisation
if(z.m != 0){
int lzd = 25;
int found = 0;
int err;
while(!found){
err = extractBits(lzd,lzd,z.m);
//cout<<"lzd: "<<dec<<lzd<<endl;
//cout<<"err: "<<dec<<err<<endl;
if(err == 1){
found = 1;
}else{
lzd--;
}
}

lzd = lzd - 23;
if(lzd > 0){
if(lostbit_low == 0){
lostbit_low = lostbit_high;
}
lostbit_high = extractBits(0,1,z.m);
z.m >>= lzd;
}else{
z.m <<= -lzd;
}
z.e += lzd;
}

// Rounding
LSB = extractBits(0,0,z.m);
//cout<<LSB<<" "<<lostbit_high<<" "<<lostbit_low<<endl;
if(lostbit_high == 1 & (LSB | lostbit_low)){
z.m += 1;
}
}

fp_t adder(fp_t x, fp_t y, bool IsSub){
fp_t z;
int lostbit_high = 0, lostbit_low = 0;

z.s = 0; z.m = 0; z.e = 0;

// Full numbers (with significands)
//cout<<"x: "<<dec<<x.s<<"-"<<x.e<<"-"<<hex<<x.m<<endl
// <<"y: "<<dec<<y.s<<"-"<<y.e<<"-"<<hex<<y.m<<endl<<endl;

// Difference of exponents
int d;
d = x.e-y.e;
//cout<<"Difference of exponents: "<<dec<<d<<endl;

// Align significands
if(d>0){
for(int j = 0; j<d; j++){

if(lostbit_low == 0){
lostbit_low = lostbit_high;
}
lostbit_high = extractBits(0,0,y.m);

y.m >>= 1;
}
z.e = x.e;
}else if(d<0){
for(int j = 0; j>d; j--){

if(lostbit_low == 0){
lostbit_low = lostbit_high;
}
lostbit_high = extractBits(0,0,x.m);

x.m >>= 1;
}
z.e = y.e;
}else{
z.e = x.e;
}

//cout<<"x: "<<dec<<x.s<<"-"<<x.e<<"-"<<hex<<x.m<<endl
// <<"y: "<<dec<<y.s<<"-"<<y.e<<"-"<<hex<<y.m<<endl<<endl;

// decision: add or subtract?
if(x.m >= y.m){
z.s = x.s;
if ((x.s == 1)^(y.s == 1)^IsSub){
y.m = ~y.m;
z.m = 1;
}
}else if(x.m < y.m){
if((y.s == 1)^IsSub){
z.s = 1;
}
if ((x.s == 1)^(y.s == 1)^IsSub){
x.m = ~x.m;
z.m = 1;
}
}

// add
z.m += x.m + y.m;
//cout<<"Significand Sum: "<<hex<<z.m<<endl;

// Rounding and normalisation
round_norm(z, lostbit_high, lostbit_low);
//cout<<"z: "<<dec<<z.s<<"-"<<z.e<<"-"<<hex<<z.m<<endl<<endl;

if(z.m == 0){
z.e = x.e - y.e;
}

return z;
}

fp_t multiplier(fp_t x, fp_t y){
fp_t z;

z.s = 0; z.m = 0; z.e = 0;

// Full numbers (with significands)
//cout<<"x: "<<dec<<x.s<<"-"<<x.e<<"-"<<hex<<x.m<<endl
// <<"y: "<<dec<<y.s<<"-"<<y.e<<"-"<<hex<<y.m<<endl<<endl;

// Calculate sign
if(x.s != y.s){
z.s = 1;
}

// New exponent
if(x.e != 0 & y.e != 0){
z.e = x.e + y.e - 0x7F;
}
//cout<<"New exponent: "<<dec<<z.e<<endl;


// Booth encode
int beys; // booth encoded y significand
y.m = y.m<<1;

int negxm = ~x.m;
negxm++;
int twoxm = x.m<<1;
int negtwoxm = negxm<<1;	

//cout<<hex<<"x: "<<x.m<<endl
// <<"-x: "<<negxm<<endl
// <<"2x: "<<twoxm<<endl
// <<"-2x: "<<negtwoxm<<endl<<endl;

// Multiply via Booth additions
int lostone = 0; int lostbits = 0;
for(int i = 0; i<=11; i++){
beys = extractBits(2*i,(2*i)+2,y.m);
//cout<<dec<<2*i<<" to "<<(2*i)+2<<" is "<<hex<<beys<<endl;
//cout<<hex<<z.m<<" ";
if(lostone == 0){
lostbits = extractBits(0,1,z.m);
if(lostbits != 0){
lostone = 1;
}
}
z.m = z.m>>2;
if(z.m>>30 == 1){
z.m |= 0x60000000;
}
//cout<<hex<<z.m<<" ";
switch(beys){
case 0: NULL; break;
case 1: z.m += x.m; break;
case 2: z.m += x.m; break;
case 3: z.m += twoxm; break;
case 4: z.m += negtwoxm; break;
case 5: z.m += negxm; break;
case 6: z.m += negxm; break;
case 7: NULL; break;
}
//cout<<"New estimate: "<<hex<<beys<<" "<<z.m<<endl;
}

if(y.e != 0){
if(lostone == 0){
lostbits = extractBits(0,1,z.m);
if(lostbits != 0){
lostone = 1;
}
}
z.m = z.m>>2;
z.m += x.m; // this takes account of the leading 1
}

z.m <<= 1;

// Full number (with significand)
//cout<<"z: "<<dec<<z.s<<"-"<<z.e<<"-"<<hex<<z.m<<endl<<endl;

return z;
}

fp_t fma(fp_t x, fp_t y, fp_t w){
fp_t z;

z.s = 0; z.m = 0; z.e = 0;

// Full numbers (with significands)
//cout<<"x: "<<dec<<x.s<<"-"<<x.e<<"-"<<hex<<x.m<<endl
// <<"y: "<<dec<<y.s<<"-"<<y.e<<"-"<<hex<<y.m<<endl<<endl;

// Calculate sign
if(x.s != y.s){
z.s = 1;
}

// New exponent
if(x.e != 0 & y.e != 0){
z.e = x.e + y.e - 0x7F;
}
//cout<<"New exponent: "<<dec<<z.e<<endl;

return z;
}

fp_t gold_divider(fp_t x, fp_t y){
fp_t z;

z.s = 0; z.m = 0; z.e = 0;

// Full number (with significand)
//cout<<"y: "<<dec<<y.s<<"-"<<y.e<<"-"<<hex<<y.m<<endl<<endl;

// Calculate sign
if(x.s != y.s){
z.s = 1;
}

// Divide by power of 2, base case
if(y.m == 0x800000){
z.e = x.e - y.e + 0x7F;
z.m = x.m;
return z;
}

// Goldschmidt's Algorithm
int sign;
fp_t f, n, two;

sign = z.s; // preserves sign bit, to be reused later
x.s = 0; y.s = 0; // Goldschmidt's Algorithm works with positive numbers
two.s = 0; two.e = 128; two.m = 0x800000; // define 2.0 in floating point to used in subtraction
f.s = 0; f.e = 254 - y.e; f.m = 0x800000; // initial guess is highest power of 2 below divisor

z = x;

int i = 0;
while( i < 5 ){

if(z.m == 0){	// if the exact answer is found, break, otherwise iterate
break;
}else{
i++;
}

y = multiplier(f,y);	round_norm(y,0,0);	// calculate new value for denominator
z = multiplier(f,z);	round_norm(z,0,0);	// calculate new value for numerator
f = adder(two,y,true);
}

z.s = sign;

// Full number (with significand)
//cout<<"z: "<<dec<<z.s<<"-"<<z.e<<"-"<<hex<<z.m<<endl<<endl;

return z;
}

fp_t newton_divider(fp_t x, fp_t y){
fp_t z;

z.s = 0; z.m = 0; z.e = 0;

// Full number (with significand)
//cout<<"y: "<<dec<<y.s<<"-"<<y.e<<"-"<<hex<<y.m<<endl<<endl;

// Calculate sign
if(x.s != y.s){
z.s = 1;
}

// Divide by power of 2, base case
if(y.m == 0x800000){
z.e = x.e - y.e + 0x7F;
z.m = x.m;
return z;
}

// Newton-Raphson Method
int sign;
fp_t two, x0;

sign = z.s; // preserves sign bit, to be reused later
x.s = 0; y.s = 0; // Use algorithm with positive numbers
two.s = 0; two.e = 128; two.m = 0x800000; // define 2.0 in floating point to be used in subtraction
z.s = 0; z.e = 254 - y.e; z.m = 0x800000; // initial guess is the reciprocal of the highest power of 2 below divisor

int i = 0;
while( i < 5 ){

x0 = z;
z = multiplier(y,x0);	round_norm(z,0,0);
z = adder(two,z,true);
z = multiplier(z,x0);	round_norm(z,0,0);

i++;

}

z = multiplier(z,x);	round_norm(z,0,0);
z.s = sign;

// Full number (with significand)
//cout<<"z: "<<dec<<z.s<<"-"<<z.e<<"-"<<hex<<z.m<<endl<<endl;

return z;
}

fp_t newton_rooter(fp_t x){
fp_t z;

z.s = 0; z.m = 0; z.e = 0;

// Full number (with significand)
//cout<<"y: "<<dec<<y.s<<"-"<<y.e<<"-"<<hex<<y.m<<endl<<endl;

// Check if positive
if(x.s != 0){
if(x.e == 0 & x.m == 0){
return x;	// if the input is -0, return -0
}else{
z.e = 0xFF;
z.m = 0x1;
return z;	// otherwise return a NaN
}
}else if(x.e == 0 & x.m == 0){
return x;
}

// Newton-Raphson Method
fp_t x0;
float x0_f, z_f, x_f;

// initial guess is the root of the highest rootable power of 2 below radicand
z.s = 0; z.e = 0x7F + x.e; z.e >>= 1; z.m = 0x800000;
x0 = z;

int i = 0;
while( i < 5 ){

z = newton_divider(x,x0);	round_norm(z,0,0);
z = adder(z,x0,false);	round_norm(z,0,0);
z.e--;

i++;

x0 = z;
}

// Full number (with significand)
//cout<<"z: "<<dec<<z.s<<"-"<<z.e<<"-"<<hex<<z.m<<endl<<endl;

return z;
}

fp_t newton_inverse_rooter(fp_t x){
fp_t z;

z.s = 0; z.m = 0; z.e = 0;

// Full number (with significand)
//cout<<"y: "<<dec<<y.s<<"-"<<y.e<<"-"<<hex<<y.m<<endl<<endl;

// Check if positive
if(x.s != 0){
if(x.e == 0 & x.m == 0){
return x;	// if the input is -0, return -0
}else{
z.e = 0xFF;
z.m = 0x1;
return z;	// otherwise return a NaN
}
}

// Newton-Raphson Method
fp_t three, x0;

three.s = 0; three.e = 128; three.m = 0xC00000; // define 3.0 in floating point to be used in subtraction
// initial guess is the reciprocal of the root of the highest rootable power of 2 below radicand
z.s = 0; z.e = 381 - x.e; z.e >>= 1; z.m = 0x800000;

int i = 0;
while( i < 5 ){

x0 = z;
z = multiplier(x0,x0);	round_norm(z,0,0);
z = multiplier(x,z);	round_norm(z,0,0);
z = adder(three,z,true);
z = multiplier(x0,z);	round_norm(z,0,0);
z.e--;

i++;

}

// Full number (with significand)
//cout<<"z: "<<dec<<z.s<<"-"<<z.e<<"-"<<hex<<z.m<<endl<<endl;

return z;
}

fp_t quake_inverse_rooter(fp_t x){
fp_t z;

z.s = 0; z.m = 0; z.e = 0;

// Full number (with significand)
//cout<<"y: "<<dec<<y.s<<"-"<<y.e<<"-"<<hex<<y.m<<endl<<endl;

// Check if positive
if(x.s != 0){
if(x.e == 0 & x.m == 0){
return x;	// if the input is -0, return -0
}else{
z.e = 0xFF;
z.m = 0x1;
return z;	// otherwise return a NaN
}
}

// Quake Algorithm
fp_t halfno, threehalves, y, quake_const;

threehalves.s = 0; threehalves.e = 0x7F; threehalves.m = 0xC00000; // define 1.5 in floating point to be used in subtraction
quake_const.s = 0; quake_const.e = 190; quake_const.m = 0xB759DF; // Quake constant used to find inverse root quickly

halfno = x;
halfno.e--;
z = halfno;
z = adder(quake_const,z,true);	// subtract the fp_t equivalent of 0x5f3759df
y = z;
z = multiplier(z,z);	round_norm(z,0,0);
z = multiplier(halfno,z);	round_norm(z,0,0);
z = adder(threehalves,z,true);
z = multiplier(y,z);	round_norm(z,0,0);

// Full number (with significand)
//cout<<"z: "<<dec<<z.s<<"-"<<z.e<<"-"<<hex<<z.m<<endl<<endl;

return z;
}
//-------------------------------------------------------------------------------------------------------------------

//test for the addition function
int testCodeAddition () {
	//declare the data types for the 2 numbers that will be added
	bitset<32> b1, b2;		//read from the text file
	float float1, float2;	//built in c++ float type
	fp_t add_test1A_fp, add_test1B_fp;

	//declare the name of the input text file	
	ifstream inFile (testfile);
    
	//declare the name of the output file
	ofstream outFile;
	outFile.open (testfile_add_output);
	
	//declare variable for the output value
	fp_t test1_add_fp;
	//initialize the output variable
	test1_add_fp.s=0; test1_add_fp.e=0; test1_add_fp.m=0;

	//declare variables for the output	
	float test1_add_float;
	int itest1_add_float;
		
	while (!inFile.eof()) {
		//read the 2 numbers from the text file
		inFile >> b1 >> b2;

		//changing the int to float
		float1 = *(float*)&b1;	
		float2 = *(float*)&b2;

		//unpack into fp_t type
		add_test1A_fp = unpack_f(float1);	
		add_test1B_fp = unpack_f(float2);
		
		//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
		//addition function: use add_test1A and add_test1B
		//the result is test1_add_fp, the result is in fp_t
		test1_add_fp = adder((add_test1A_fp), (add_test1B_fp), 0);


		//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
		//use the "pack_f" function, the result is now in a float data type
		test1_add_float = pack_f(test1_add_fp);
		
		//convert to 32 bits
		itest1_add_float = *(int*)&test1_add_float;	

		//write the output to the text file
		outFile << (bitset<32>)itest1_add_float << "\n";
	}

	//close the input file
	inFile.close();
	//close the output file	
	outFile.close();

	//return 0 if no errors
	return 0;
}
//-------------------------------------------------------------------------------------------------------------------

//test for the multiplication function
int testCodeMultiplication () {
	//declare the data types for the 2 numbers that will be multiplied
	bitset<32> b1, b2;		//read from the text file
	float float1, float2;	//built in c++ float type
	fp_t mul_test1A_fp, mul_test1B_fp;

	//declare the name of the input text file	
	ifstream inFile (testfile);
    
	//declare the name of the output file
	ofstream outFile;
	outFile.open (testfile_mul_output);
	
	//declare variable for the output value
	fp_t test1_mul_fp;
	//initialize the output variable
	test1_mul_fp.s=0; test1_mul_fp.e=0; test1_mul_fp.m=0;

	//declare variables for the output	
	float test1_mul_float;
	int itest1_mul_float;
		
	while (!inFile.eof()) {
		//read the 2 numbers from the text file
		inFile >> b1 >> b2;

		//changing the int to float
		float1 = *(float*)&b1;	
		float2 = *(float*)&b2;

		//unpack into fp_t type
		mul_test1A_fp = unpack_f(float1);	
		mul_test1B_fp = unpack_f(float2);
		
		//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
		//multiplication function
		//the result is test1_mul_fp, the result is in fp_t
		test1_mul_fp = multiplier((mul_test1A_fp), (mul_test1B_fp));


		//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
		//use the "pack_f" function, the result is now in a float data type
		test1_mul_float = pack_f(test1_mul_fp);
		
		//convert to 32 bits
		itest1_mul_float = *(int*)&test1_mul_float;	

		//write the output to the text file
		outFile << (bitset<32>)itest1_mul_float << "\n";
	}

	//close the input file
	inFile.close();
	//close the output file	
	outFile.close();

	//return 0 if no errors
	return 0;
}
//-------------------------------------------------------------------------------------------------------------------

//test division, Goldschmidt's algorithm 
int testCodeDivision(){
	//declare the data types for the 2 numbers that will be divided
	bitset<32> b1, b2;		//read from the text file
	float float1, float2;	//built in c++ float type
	fp_t div_test1A_fp, div_test1B_fp;

	//declare the name of the input text file	
	ifstream inFile (testfile);
    
	//declare the name of the output file
	ofstream outFile;
	outFile.open (testfile_div_output);
	
	//declare variable for the output value
	fp_t test1_div_fp;
	//initialize the output variable
	test1_div_fp.s=0; test1_div_fp.e=0; test1_div_fp.m=0;

	//declare variables for the output	
	float test1_div_float;
	int itest1_div_float;
		
	while (!inFile.eof()) {
		//read the 2 numbers from the text file
		inFile >> b1 >> b2;

		//changing the int to float
		float1 = *(float*)&b1;	
		float2 = *(float*)&b2;

		//unpack into fp_t type
		div_test1A_fp = unpack_f(float1);	
		div_test1B_fp = unpack_f(float2);
		
		//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
		//division function
		//the result is test1_div_fp, the result is in fp_t
		test1_div_fp = gold_divider((div_test1A_fp), (div_test1B_fp));
		
		//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
		//use the "pack_f" function, the result is now in a float data type
		test1_div_float = pack_f(test1_div_fp);
		
		//convert to 32 bits
		itest1_div_float = *(int*)&test1_div_float;	

		//write the output to the text file
		outFile << (bitset<32>)itest1_div_float << "\n";
	}
	//close the input file
	inFile.close();
	//close the output file	
	outFile.close();

	//return 0 if no errors
	return 0;
}
//-------------------------------------------------------------------------------------------------------------------

//test division, Newton-Raphson algorithm 
int testCodeDivision2(){
	//declare the data types for the 2 numbers that will be divided
	bitset<32> b1, b2;		//read from the text file
	float float1, float2;	//built in c++ float type
	fp_t div_test1A_fp, div_test1B_fp;

	//declare the name of the input text file	
	ifstream inFile (testfile);
    
	//declare the name of the output file
	ofstream outFile;
	outFile.open (testfile_div_output2);
	
	//declare variable for the output value
	fp_t test1_div_fp;
	//initialize the output variable
	test1_div_fp.s=0; test1_div_fp.e=0; test1_div_fp.m=0;

	//declare variables for the output	
	float test1_div_float;
	int itest1_div_float;
		
	while (!inFile.eof()) {
		//read the 2 numbers from the text file
		inFile >> b1 >> b2;

		//changing the int to float
		float1 = *(float*)&b1;	
		float2 = *(float*)&b2;

		//unpack into fp_t type
		div_test1A_fp = unpack_f(float1);	
		div_test1B_fp = unpack_f(float2);
		
		//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
		//division function
		//the result is test1_div_fp, the result is in fp_t
		test1_div_fp = newton_divider((div_test1A_fp), (div_test1B_fp));
		
		//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
		//use the "pack_f" function, the result is now in a float data type
		test1_div_float = pack_f(test1_div_fp);
		
		//convert to 32 bits
		itest1_div_float = *(int*)&test1_div_float;	

		//write the output to the text file
		outFile << (bitset<32>)itest1_div_float << "\n";
	}
	//close the input file
	inFile.close();
	//close the output file	
	outFile.close();

	//return 0 if no errors
	return 0;
}
//-------------------------------------------------------------------------------------------------------------------

//test square root, use of Newton method
int testCodeSquareRoot(){
	//declare the data type for the 1 number that will be used as input
	bitset<32> b1;			//read from the text file
	float float1;			//built in c++ float type
	fp_t sqrt_test1A_fp;

	//declare the name of the input text file	
	ifstream inFile (testfile_oneInput);
    
	//declare the name of the output file
	ofstream outFile;
	outFile.open (testfile_sqrt_output);
	
	//declare variable for the output value
	fp_t test1_sqrt_fp;
	//initialize the output variable
	test1_sqrt_fp.s=0; test1_sqrt_fp.e=0; test1_sqrt_fp.m=0;

	//declare variables for the output	
	float test1_sqrt_float;
	int itest1_sqrt_float;
		
	while (!inFile.eof()) {
		//read the 2 numbers from the text file
		inFile >> b1;
		//changing the int to float
		float1 = *(float*)&b1;	

		//unpack into fp_t type
		sqrt_test1A_fp = unpack_f(float1);	
		
		//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
		//square root function
		//the result is test1_sqrt_fp, the result is in fp_t
		test1_sqrt_fp = newton_rooter(sqrt_test1A_fp);
		
		//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
		//use the "pack_f" function, the result is now in a float data type
		test1_sqrt_float = pack_f(test1_sqrt_fp);
		
		//convert to 32 bits
		itest1_sqrt_float = *(int*)&test1_sqrt_float;	

		//write the output to the text file
		outFile << (bitset<32>)itest1_sqrt_float << "\n";
	}

	//close the input file
	inFile.close();
	//close the output file	
	outFile.close();

	//return 0 if no errors
	return 0;
}
//-------------------------------------------------------------------------------------------------------------------

//test the inverse square root, Newton method
int testCodeInverseSquareRoot(){
	//declare the data type for the 1 number that will be used as input
	bitset<32> b1;			//read from the text file
	float float1;			//built in c++ float type
	fp_t invSqrt_test1A_fp;

	//declare the name of the input text file	
	ifstream inFile (testfile_oneInput);
    
	//declare the name of the output file
	ofstream outFile;
	outFile.open (testfile_invSqrt_output);
	
	//declare variable for the output value
	fp_t test1_invSqrt_fp;
	//initialize the output variable
	test1_invSqrt_fp.s=0; test1_invSqrt_fp.e=0; test1_invSqrt_fp.m=0;

	//declare variables for the output	
	float test1_invSqrt_float;
	int itest1_invSqrt_float;
		
	while (!inFile.eof()) {
		//read the 2 numbers from the text file
		inFile >> b1;
		//changing the int to float
		float1 = *(float*)&b1;	

		//unpack into fp_t type
		invSqrt_test1A_fp = unpack_f(float1);	
		
		//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
		//inverse square root function
		//the result is test1_sqrt_fp, the result is in fp_t
		test1_invSqrt_fp = newton_inverse_rooter(invSqrt_test1A_fp);
		
		//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
		//use the "pack_f" function, the result is now in a float data type
		test1_invSqrt_float = pack_f(test1_invSqrt_fp);
		
		//convert to 32 bits
		itest1_invSqrt_float = *(int*)&test1_invSqrt_float;	

		//write the output to the text file
		outFile << (bitset<32>)itest1_invSqrt_float << "\n";
	}

	//close the input file
	inFile.close();
	//close the output file	
	outFile.close();

	//return 0 if no errors
	return 0;
}
//-------------------------------------------------------------------------------------------------------------------

//test the inverse square root, Quake method
int testCodeInverseSquareRoot2(){
	//declare the data type for the 1 number that will be used as input
	bitset<32> b1;			//read from the text file
	float float1;			//built in c++ float type
	fp_t invSqrt_test1A_fp;

	//declare the name of the input text file	
	ifstream inFile (testfile_oneInput);
    
	//declare the name of the output file
	ofstream outFile;
	outFile.open (testfile_invSqrt_output2);
	
	//declare variable for the output value
	fp_t test1_invSqrt_fp;
	//initialize the output variable
	test1_invSqrt_fp.s=0; test1_invSqrt_fp.e=0; test1_invSqrt_fp.m=0;

	//declare variables for the output	
	float test1_invSqrt_float;
	int itest1_invSqrt_float;
		
	while (!inFile.eof()) {
		//read the 2 numbers from the text file
		inFile >> b1;
		//changing the int to float
		float1 = *(float*)&b1;	

		//unpack into fp_t type
		invSqrt_test1A_fp = unpack_f(float1);	
		
		//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
		//inverse square root function
		//the result is test1_sqrt_fp, the result is in fp_t
		test1_invSqrt_fp = quake_inverse_rooter(invSqrt_test1A_fp);
		
		//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
		//use the "pack_f" function, the result is now in a float data type
		test1_invSqrt_float = pack_f(test1_invSqrt_fp);
		
		//convert to 32 bits
		itest1_invSqrt_float = *(int*)&test1_invSqrt_float;	

		//write the output to the text file
		outFile << (bitset<32>)itest1_invSqrt_float << "\n";
	}

	//close the input file
	inFile.close();
	//close the output file	
	outFile.close();

	//return 0 if no errors
	return 0;
}
//-------------------------------------------------------------------------------------------------------------------

//test the FMA, use of 3 inputs
int testFMA(){
	//declare the data types for the 3 input numbers
	bitset<32> b1, b2, b3;		//read from the text file
	float float1, float2, float3;	//built in c++ float type

	//declare the name of the input text file	
	ifstream inFile (testfile_threeInputs);
    
	//declare the name of the output file
	ofstream outFile;
	outFile.open (testfile_fma_output);
	
	//declare variable for the output value
	fp_t test1_fma_fp;
	//initialize the output variable
	test1_fma_fp.s=0; test1_fma_fp.e=0; test1_fma_fp.m=0;

	//declare variables for the output	
	float test1_fma_float;
	int itest1_fma_float;
		
	while (!inFile.eof()) {
		//read the 2 numbers from the text file
		inFile >> b1 >> b2 >> b3;

		//changing the int to float
		float1 = *(float*)&b1;	
		float2 = *(float*)&b2;
		float3 = *(float*)&b3;
		//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

		//FMA function
		//the result is test1_fma_fp, the result is in float
		//test1_fma_fp = fma(float1, float2, float3);
		//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
		
		//use the "pack_f" function, the result is now in a float data type
		test1_fma_float = pack_f(test1_fma_fp);
		
		//convert to 32 bits
		itest1_fma_float = *(int*)&test1_fma_float;	

		//write the output to the text file
		outFile << (bitset<32>)itest1_fma_float << "\n";
	}
	//close the input file
	inFile.close();
	//close the output file	
	outFile.close();

	//return 0 if no errors
	return 0;
}


