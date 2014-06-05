#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <cmath>
#include <fstream>
#include <string>

#include <bitset>

using namespace std;

////////////global variables/////////////////////////////////
//the test file names are changed manually for all the test files
string testfile = "test1.txt";
//this is for addition, we use tests: 1 - 11
string testfile_add_output = "test1_add_output.txt";

//this is for multiplication, we use tests: 1 - 8
string testfile_mul_output = "test1_mul_output.txt";

//this is for division, we use tests: 1 - 8
string testfile_div_output = "test1_gold_div_output.txt";
string testfile_div_output2 = "test1_newton_div_output2.txt";
string testfile_div_output3 = "test1_newton_div_output3.txt";
string testfile_div_output4 = "test1_newton_div_output4.txt";

//testing of functions with 1 input
string testfile_oneInput = "test1_oneInput.txt";
string testfile_sqrt_output = "test1_sqrt_output.txt";
string testfile_sqrt_output2 = "test1_sqrt_output2.txt";

string testfile_invSqrt_output = "test1_invSqrt_output.txt";
string testfile_invSqrt_output2 = "test1_invSqrt2_output.txt";

string testfile_dual_rooter = "test1_dual_rooter_output.txt";

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

int extractBits(int, int, int);
void round_norm(fp_t &z, int, int);

fp_t adder(fp_t, fp_t, bool);
fp_t multiplier(fp_t, fp_t);
fp_t gold_divider(fp_t, fp_t);
fp_t gold2_divider(fp_t, fp_t);
fp_t newton_divider(fp_t, fp_t);
fp_t newton_divider_by_parts(fp_t, fp_t);

fp_t fractioning_rooter(fp_t);
fp_t newton_rooter(fp_t);

fp_t newton_reciprocal_rooter(fp_t);
fp_t quake_reciprocal_rooter(fp_t);

fp_t dual_rooter(fp_t, bool);

//functions for testing
void testAddition(string name, string name2);
void testMultiplication(string testfile, string testfile_mul_output);

//void testDivision1_gold(string testfile, string testfile_div_output);
//void testDivision2_gold(string testfile, string testfile_div_output2);
//void testDivision3_newton(string testfile, string testfile_div_output3);
//void testDivision4_newton(string testfile, string testfile_div_output4);
//void testSqrt1_fractioning(string testfile, string testfile_sqrt_output);
//void testSqrt2_newton(string testfile, string testfile_sqrt_output2);
//void test1_iSqrt_newton(string testfile, string testfile_invSqrt_output);
//void test2_iSqrt_quake(string testfile, string testfile_invSqrt_output2);
//void test_dual_rooter(string testfile, string testfile_dual_rooter);







//////////////////////main function//////////////////////////
int main(){
	//test addition/subtraction unit
	testAddition(testfile, testfile_add_output);
	
	//test multiplication
	//testMultiplication(testfile, testfile_mul_output);

	//test division
	//testDivision1_gold(testfile, testfile_div_output);

	//test division
	//testDivision2_gold(testfile, testfile_div_output2);

	//test division
	//testDivision3_newton(testfile, testfile_div_output3);

	//test division
	//testDivision4_newton(testfile, testfile_div_output4);

	//test square root
	//testSqrt1_fractioning(testfile, testfile_sqrt_output);

	//test square root
	//testSqrt2_newton(testfile, testfile_sqrt_output2);

	//test inverse square root
	//test1_iSqrt_newton(testfile, testfile_invSqrt_output);

	//test inverse square root
	//test2_iSqrt_quake(testfile, testfile_invSqrt_output2);

	//test dual rooter
	//test_dual_rooter(testfile, testfile_dual_rooter);












	return 0;
}

///////////////////// auxiliary functions////////////////////////////
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
cout<<"Result: "<<a_fp.s<<"-"<<dec<<a_fp.e<<"-"<<hex<<a_fp.m<<endl;	

// Convert to float
a_i = (a_fp.s << 31)+((a_fp.e<<23)&0x7F800000)+(a_fp.m&0x007FFFFF);
a_f = *(float*)&a_i;
return a_f;
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


///////////////////// arithmetic functions////////////////////////////
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

fp_t gold2_divider(fp_t x, fp_t y){
fp_t z;

z.s = 0; z.m = 0; z.e = 0;

// Full number (with significand)
//cout<<"x: "<<dec<<x.s<<"-"<<x.e<<"-"<<hex<<x.m<<endl
// <<"y: "<<dec<<y.s<<"-"<<y.e<<"-"<<hex<<y.m<<endl<<endl;

// Divide by power of 2, base case
if(y.m == 0x800000){
z.m = x.m;
return z;
}else{
z.e--;
}

// Calculate sign
if(x.s != y.s){
z.s = 1;
}

// New exponent
z.e = x.e - y.e + 127;
//cout<<"New exponent: "<<dec<<z.e<<endl;

// Goldschmidt's Algorithm
int firstbits = 0;
long long d = 0, f = 0, n = 0;

d = y.m;
n = x.m;
f = 0x1000000 - d; f <<= 1;

cout<<endl<<"f: "<<f<<" "
<<"n: "<<n<<" "
<<"d: "<<d<<" "<<endl;

int i = 0;
while( i < 5 ){

d = d*f*2; d >>= 24;	// calculate new value for denominator
n = n*f*2; n >>= 24;	// calculate new value for numerator
f = 0x1000000 - d; f <<= 1;	// calculate "error"

cout<<endl<<"f: "<<f<<" "
<<"n: "<<n<<" "
<<"d: "<<d<<" "<<endl;

i++;
}

z.m = n>>39;

// Full number (with significand)
cout<<"z: "<<dec<<z.s<<"-"<<z.e<<"-"<<hex<<z.m<<endl<<endl;

return z;
}

fp_t newton_divider(fp_t x, fp_t y){
fp_t z;

z.s = 0; z.m = 0; z.e = 0;

// Full number (with significand)
//cout<<"y: "<<dec<<y.s<<"-"<<y.e<<"-"<<hex<<y.m<<endl<<endl;

// Divide by power of 2, base case
if(y.m == 0x800000){
z.e = x.e - y.e + 0x7F;
z.m = x.m;
return z;
}

// Calculate sign
if(x.s != y.s){
z.s = 1;
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


fp_t fractioning_rooter(fp_t x){
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

// Fractioning Method

/* f(0) = 1
g(0) = 1
f(i+1) = f(i) + g(i)*S
g(i+1) = f(i)+g(i)
sqrt(S) = f(x)/g(x)
*/

fp_t f,g,h;
f.s = 0; f.e = 127; f.m = 0x800000;
g = f;

int i = 0;
while( i < 5 ){

h = multiplier(f,g);	round_norm(z,0,0);
z = multiplier(g,x);	round_norm(z,0,0);
f = adder(f,z,false);
g = h;

i++;
}

z = newton_divider(f,g); round_norm(z,0,0);

// Full number (with significand)
cout<<"z: "<<dec<<z.s<<"-"<<z.e<<"-"<<hex<<z.m<<endl<<endl;

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

// initial guess is the root of the highest rootable power of 2 below radicand
x0.s = 0; x0.e = 127 + x.e; x0.e >>= 1; x0.m = 0x800000;

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

fp_t newton_reciprocal_rooter(fp_t x){
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

fp_t quake_reciprocal_rooter(fp_t x){
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
quake_const.s = 0; quake_const.e = 190; quake_const.m = 0xB759DF; // Quake constant used to find reciprocal root quickly

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

fp_t dual_rooter(fp_t x, bool IsReciprocal){
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

// If we are looking for the normal square root,
// we multiply the reciprocal root we just calculated
// by the original number
if(!IsReciprocal){
z = multiplier(x,z);	round_norm(z,0,0);
}

// Full number (with significand)
//cout<<"z: "<<dec<<z.s<<"-"<<z.e<<"-"<<hex<<z.m<<endl<<endl;

return z;
}
//------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------

//test addition
void testAddition(string name, string name2){
	//declare the variables needed to read a line from the text file
	string line, reline;
	int size;
	
	//declare variables for the inputs
	fp_t a_fp, b_fp; 

	//declare the input file
	ifstream myfile(name);
		
	//declare the name of the output file
	ofstream outFile;
	outFile.open(name2);

	//declare variables for the output value
	float test_float;
	int itest_float;
	
	//declare variables for the output
	fp_t out;
	//initialize the output variables
	out.s=0; out.m=0; out.e=0;

	if (myfile.is_open()){
		while (myfile.good()){
			//initialize the input variables
			a_fp.s=0; a_fp.m=0; a_fp.e=0;
			b_fp.s=0; b_fp.m=0; b_fp.e=0;

			//read the line from the text file
			getline (myfile,line);
			
			//first number
			//convert the sign bit from string to integer
			a_fp.s = atoi(line.substr(0,1).c_str());

			//convert the exponent bits from string to integer
			reline = line.substr(1,8);
			for(int i = 0; i<8; i++){
				a_fp.e <<= 1;
				a_fp.e += atoi(reline.substr(i,1).c_str());
			}

			//convert the mantissa bits from string to integer
			reline = line.substr(9,23);
			for(int i = 0; i<23; i++){
				a_fp.m <<= 1;
				a_fp.m += atoi(reline.substr(i,1).c_str());
			}

			//second number
			//convert the sign bit from string to integer
			b_fp.s = atoi(line.substr(33,1).c_str());

			//convert the exponent bits from string to integer
			reline = line.substr(34,8);
			for(int i = 0; i<8; i++){
				b_fp.e <<= 1;
				b_fp.e += atoi(reline.substr(i,1).c_str());
			}

			//convert the mantissa bits from string to integer
			reline = line.substr(42,23);
			for(int i = 0; i<23; i++){
				b_fp.m <<= 1;
				b_fp.m += atoi(reline.substr(i,1).c_str());
			}

		//denormal mantissa manipulations			
		if(a_fp.e != 0){
			a_fp.m |= 0x00800000;
		}
		if(b_fp.e != 0){
			b_fp.m |= 0x00800000;
		}
	
		//do the addition
		out = adder(a_fp, b_fp, 0);

		//use the "pack_f" function, the result is now in a float data type
		test_float = pack_f(out);
		//convert to 32 bits
		itest_float = *(int*)&test_float;	
	
		//write the output to the text file
		outFile << (bitset<32>)itest_float << "\n";
		}

		//close the output file
		outFile.close();
		//close the input file
		myfile.close();
	}
	else{
		cout<<"Unable to open file";
	}
}


//test multiplication
void testMultiplication(string name, string name2){
	//declare the variables needed to read a line from the text file
	string line, reline;
	int size;
	
	//declare variables for the inputs
	fp_t a_fp, b_fp; 

	//declare the input file
	ifstream myfile(name);
		
	//declare the name of the output file
	ofstream outFile;
	outFile.open(name2);

	//declare variables for the output value
	float test_float;
	int itest_float;
	
	//declare variables for the output
	fp_t out;
	//initialize the output variables
	out.s=0; out.m=0; out.e=0;

	if (myfile.is_open()){
		while (myfile.good()){
			//initialize the input variables
			a_fp.s=0; a_fp.m=0; a_fp.e=0;
			b_fp.s=0; b_fp.m=0; b_fp.e=0;

			//read the line from the text file
			getline (myfile,line);
			
			//first number
			//convert the sign bit from string to integer
			a_fp.s = atoi(line.substr(0,1).c_str());

			//convert the exponent bits from string to integer
			reline = line.substr(1,8);
			for(int i = 0; i<8; i++){
				a_fp.e <<= 1;
				a_fp.e += atoi(reline.substr(i,1).c_str());
			}

			//convert the mantissa bits from string to integer
			reline = line.substr(9,23);
			for(int i = 0; i<23; i++){
				a_fp.m <<= 1;
				a_fp.m += atoi(reline.substr(i,1).c_str());
			}

			//second number
			//convert the sign bit from string to integer
			b_fp.s = atoi(line.substr(33,1).c_str());

			//convert the exponent bits from string to integer
			reline = line.substr(34,8);
			for(int i = 0; i<8; i++){
				b_fp.e <<= 1;
				b_fp.e += atoi(reline.substr(i,1).c_str());
			}

			//convert the mantissa bits from string to integer
			reline = line.substr(42,23);
			for(int i = 0; i<23; i++){
				b_fp.m <<= 1;
				b_fp.m += atoi(reline.substr(i,1).c_str());
			}

			//denormal mantissa manipulations			
			if(a_fp.e != 0){
				a_fp.m |= 0x00800000;
			}
			if(b_fp.e != 0){
				b_fp.m |= 0x00800000;
			}
	
			//do the multiplication
			out = multiplier(a_fp, b_fp);

			//use the "pack_f" function, the result is now in a float data type
			test_float = pack_f(out);
			//convert to 32 bits
			itest_float = *(int*)&test_float;	
	
			//write the output to the text file
			outFile << (bitset<32>)itest_float << "\n";
		}

		//close the output file
		outFile.close();
		//close the input file
		myfile.close();
	}
	else{
		cout<<"Unable to open file";
	}

}
