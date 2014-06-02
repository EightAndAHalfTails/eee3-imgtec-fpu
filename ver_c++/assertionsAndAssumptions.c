#include <iostream>
#include <fstream>
#include <string>
#include <sstream>
#include <bitset>
#include <stdio.h> /* printf */
#include <assert.h> /* assert */
using namespace std;


////////////global variables/////////////////////////////////
string testfile = "test1.txt";
string testfile_output = "test1_output.txt";

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
void round_norm(fp_t &z);
fp_t adder(fp_t, fp_t, bool);	//takes in 32-bit floating point numbers and return sum
fp_t multiplier(fp_t, fp_t);
float fma(float, float, float);
fp_t good_ol_adder(fp_t x, fp_t y, bool IsSub);

//functions for testing
int testCodeAddition();
int testCodeMultiplication();

//////////////////////main function//////////////////////////
int main ()
{
	//call the function for testing addition
	int add_test = testCodeAddition();
	
	//call function for testing multiplication
	int mul_test = testCodeMultiplication();

	//check the return value of the functions
	if (add_test != 0 || mul_test != 0)
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
a_fp.e = 127+index;

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
a_fp.e = 127+index;

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
int lza = 25;
int found = 0;
int err;
while(!found){
err = extractBits(lza,lza,a_fp.m);
//cout<<"lza: "<<dec<<lza<<endl;
//cout<<"err: "<<dec<<err<<endl;
if(err == 1){
found = 1;
}else{
lza--;
}
}

lza = lza - 23;
a_fp.m >>= lza;
a_fp.e += lza;
}

// Remove significand's leading 1 bit
a_fp.m &= 0x007FFFFF;
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

void round_norm(fp_t &z){
// Rounding and normalisation
if(z.m != 0){
int lza = 25;
int found = 0;
int err;
while(!found){
err = extractBits(lza,lza,z.m);
//cout<<"lza: "<<dec<<lza<<endl;
//cout<<"err: "<<dec<<err<<endl;
if(err == 1){
found = 1;
}else{
lza--;
}
}

lza = lza - 23;
z.m >>= lza;
z.e += lza;
}
}

fp_t adder(fp_t x, fp_t y, bool IsSub){
fp_t z, w;
int i = 0;

z.s = 0; z.m = 0; z.e = 0;

// Full numbers (with significands)
//cout<<"x: "<<dec<<x.s<<"-"<<x.e<<"-"<<hex<<x.m<<endl
// <<"y: "<<dec<<y.s<<"-"<<y.e<<"-"<<hex<<y.m<<endl<<endl;

// Put the bigger number in x
if((x.e < y.e)|((x.e == y.e)&(x.m < y.m))){
w = x;
x = y;
y = w;
}	

// Difference of exponents
int d;
d = x.e-y.e;
//cout<<"Difference of exponents: "<<dec<<d<<endl;

// Align significands
for(i = 0; i<d; i++){
y.m >>= 1;
}
z.e = x.e;

// decision: add or subtract?
z.s = x.s;
if ((x.s == 1)^(y.s == 1)^IsSub){
y.m = ~y.m;
z.m = 1;
}

//cout<<dec<<x.s<<"-"<<z.e<<"-"<<hex<<x.m<<endl
// <<dec<<y.s<<"-"<<z.e<<"-"<<hex<<y.m<<endl
// <<dec<<z.s<<"-"<<z.e<<"-"<<hex<<z.m<<endl;

// add
z.m += x.m + y.m;
//cout<<"Significand Sum: "<<hex<<z.m<<endl;
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
z.e = x.e + y.e - 127;
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
int round = 0; int lostbits = 0;
for(int i = 0; i<=11; i++){
beys = extractBits(2*i,(2*i)+2,y.m);
//cout<<dec<<2*i<<" to "<<(2*i)+2<<" is "<<hex<<beys<<endl;
//cout<<hex<<z.m<<" ";
if(round == 0){
lostbits = extractBits(0,1,z.m);
if(lostbits != 0){
round = 1;
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
if(round == 0){
lostbits = extractBits(0,1,z.m);
if(lostbits != 0){
round = 1;
}
}
z.m = z.m>>2;
z.m += x.m; // this takes account of the leading 1
}

z.m <<= 1;

return z;
}

float fma(float a_f, float b_f, float c_f){
fp_t x, y, z;
float d_f;

//unpack
x = unpack_f(a_f);
y = unpack_f(b_f);
z.s = 0; z.m = 0; z.e = 0;

// Calculate sign
if(x.s != y.s){
z.s = 1;
}

cout<<endl;
cout<<a_f<<": "<<dec<<x.s<<"-"<<x.e<<"-"<<hex<<x.m<<endl
<<b_f<<": "<<dec<<y.s<<"-"<<y.e<<"-"<<hex<<y.m<<endl<<endl;

//Create significand
x.m |= 0x00800000;
y.m |= 0x00800000;

//cout<<a_f<<": "<<dec<<x.s<<"-"<<x.e<<"-"<<hex<<x.m<<endl
// <<b_f<<": "<<dec<<y.s<<"-"<<y.e<<"-"<<hex<<y.m<<endl<<endl;

//calculate new exponent
z.e = x.e + y.e - 127;

//cout<<"New exponent: "<<dec<<z.e<<endl;

//Booth encode
int beys; // booth encoded y.m segment
y.m = y.m<<1;

int negxm = ~x.m;
negxm++;
int twoxm = x.m<<1;
int negtwoxm = negxm<<1;	

//cout<<hex<<"x: "<<x.m<<endl
// <<"-x: "<<negxm<<endl
// <<"2x: "<<twoxm<<endl
// <<"-2x: "<<negtwoxm<<endl<<endl;

for(int i = 0; i<=11; i++){
beys = extractBits(2*i,(2*i)+2,y.m);
//cout<<dec<<2*i<<" to "<<(2*i)+2<<" is "<<hex<<beys<<endl;
//cout<<hex<<z.m<<" ";
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

z.m = z.m>>2;
z.m += x.m; // this takes account of the leading 1

//Rounding and normalisation
int err = extractBits(23,31,z.m);
z.m = z.m<<1;
z.m = z.m>>err;
z.e += err;
//cout<<z.m<<endl;

//unpack
x = z;
y = unpack_f(c_f);
z.s = 0; z.m = 0; z.e = 0;

//Create significand
y.m |= 0x00800000;

//difference of exponents
int d;
d = x.e-y.e;

//cout<<"Difference in exponents: "<<dec<<d<<endl;

//align significand
if(d>0){
y.m >>= d;
z.e = x.e;
}	
else if(d<0){
x.m >>= -d;
z.e = y.e;
}
else z.e = x.e;

//cout<<dec<<x.s<<"-"<<z.e<<"-"<<hex<<x.m<<endl
// <<dec<<y.s<<"-"<<z.e<<"-"<<hex<<y.m<<endl<<endl;


//decision: add or subtract?
if(x.m > y.m){
z.s = x.s;
if ((x.s == 1)^(y.s == 1)){
y.m = ~y.m;
z.m = 1;
}
}else if(x.m < y.m){
z.s = y.s;
if ((x.s == 1)^(y.s == 1)){
x.m = ~x.m;
z.m = 1;
}
}

//cout<<dec<<x.s<<"-"<<z.e<<"-"<<hex<<x.m<<endl
// <<dec<<y.s<<"-"<<z.e<<"-"<<hex<<y.m<<endl
// <<dec<<z.s<<"-"<<z.e<<"-"<<hex<<z.m<<endl;

// add
z.m += x.m + y.m;
//cout<<"Significand Sum: "<<hex<<z.m<<endl;

//Rounding and normalisation
err = extractBits(24,31,z.m);
z.m = z.m>>err;
z.e += err;
//cout<<z.m<<endl;

//Turn significand into mantissa
z.m &= 0x7FFFFF;
cout<<"Result: "<<z.s<<"-"<<dec<<z.e<<"-"<<hex<<z.m<<endl;

d_f = pack_f(z);
//cout<<dec<<c_f<<endl<<endl;

return d_f;

}

float reciprocal(float b_f){
fp_t x, y, z;
float c_f;

//unpack
y = unpack_f(b_f);
z.s = 0; z.m = 0; z.e = 0;

// Calculate sign
z.s = y.s;

cout<<endl;
cout<<b_f<<": "<<dec<<y.s<<"-"<<y.e<<"-"<<hex<<y.m<<endl<<endl;

//Create significand
y.m |= 0x00800000;

//calculate new exponent
//z.e = x.e + y.e - 127; <-------------- ????????????????????????????????????????????

// Reciprocate
int x0 = 0.0000001;


int beys; // booth encoded y.m segment
y.m = y.m<<1;

int negxm = ~x.m;
negxm++;
int twoxm = x.m<<1;
int negtwoxm = negxm<<1;	

//cout<<hex<<"x: "<<x.m<<endl
// <<"-x: "<<negxm<<endl
// <<"2x: "<<twoxm<<endl
// <<"-2x: "<<negtwoxm<<endl<<endl;

for(int i = 0; i<=11; i++){
beys = extractBits(2*i,(2*i)+2,y.m);
//cout<<dec<<2*i<<" to "<<(2*i)+2<<" is "<<hex<<beys<<endl;
//cout<<hex<<z.m<<" ";
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

z.m = z.m>>2;
z.m += x.m; // this takes account of the leading 1

//Rounding and normalisation
int err = extractBits(23,31,z.m);
z.m = z.m<<1;
z.m = z.m>>err;
z.e += err;
//cout<<z.m<<endl;

z.m &= 0x7FFFFF;
cout<<"Result: "<<z.s<<"-"<<dec<<z.e<<"-"<<hex<<z.m<<endl;

c_f = pack_f(z);
//cout<<dec<<c_f<<endl<<endl;

return c_f;
}
//-------------------------------------------------------------------------------------------------------------------




//test for the addition function
int testCodeAddition () {
	//declare the name of the input text file	
	ifstream inFile (testfile);
    //declare the name of the output file
    ofstream outFile;
	outFile.open (testfile_output);

	//declare string to read one line from the text file
	string line;
	//divide line to 2 strings
	string line1, line2;
	int line1_int, line2_int;

	//declare char arrays for the 2 input numbers
	//from 0 to 64
	char add_test_inputs[65];
	//from 0 to 31
	char add_test1A[32], add_test1B[32];

	//declare intermediate variables
	fp_t add_test1A_fp, add_test1B_fp;
	fp_t test1_add_fp;

	//declare a stringstream so as to write the data to a text file
	stringstream ss_s_test1_add_fp, ss_e_test1_add_fp, ss_m_test1_add_fp;
	
	//declare string variables for the output	
	string str_s_test1_add_fp, str_e_test1_add_fp, str_m_test1_add_fp;
	int int_test1_add_fp;
	float test1_add_float;
	int itest1_add_float;

	//declare a string to write to the txt file
	string final_test1_add_fp;
	
	while (!inFile.eof()) {
		//read the line to the string "line"
		getline(inFile,line);
		//separate the string line to line1 and line2
		istringstream iss(line);
		do {
			iss >> line1 >> line2;
		} while (iss);

		//find the 2 numbers
		for(int i=0; i<32; i++){
			add_test1A[i] = line1[i];
		}
		for(int i=0; i<32; i++){
			add_test1B[i] = line2[i];
		}
	
		//integer conversion
//		line1_int = stoi(line1, nullptr, 2);
//		line2_int = stoi(line2, nullptr, 2);
		
		//find the sign of the first number
		if (add_test1A[0] == '1'){
			add_test1A_fp.s = 1;
		}
		else {
			add_test1A_fp.s = 0;
		}
		//add_test1A_fp.s = extractBits(30,31, line1_int);

		//find the exponent of the first number
		//the variable "exponent" is a string
		char exponent[] = {add_test1A[8], add_test1A[7], add_test1A[6], add_test1A[5], add_test1A[4], add_test1A[3], add_test1A[2], add_test1A[1], '\0'};
//		add_test1A_fp.e = atoi(exponent.c_str());
		add_test1A_fp.e = stoi(exponent, nullptr, 2);
//		add_test1A_fp.e = extractBits(23,30, (int)atoi(line1.c_str()));
//		add_test1A_fp.e = extractBits(23,30, line1_int);

		//find the mantissa of the first number
		//the variable "mantissa" is a string
		char mantissa[] = {add_test1A[31], add_test1A[30], add_test1A[29], add_test1A[28], add_test1A[27], add_test1A[26], add_test1A[25], add_test1A[24], add_test1A[23], add_test1A[22], add_test1A[21], add_test1A[20], add_test1A[19], add_test1A[18], add_test1A[17], add_test1A[16], add_test1A[15], add_test1A[14], add_test1A[13], add_test1A[12], add_test1A[11], add_test1A[10], add_test1A[9], '\0'};
		//add_test1A_fp.m = atoi(mantissa.c_str());
		add_test1A_fp.m = stoi(mantissa, nullptr, 2);
//		add_test1A_fp.m = extractBits(0,22, (int)atoi(line1.c_str()));
//		add_test1A_fp.m = extractBits(0,22, line1_int);


		//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
		//find the sign of the second number
		if (add_test1B[0] == 1){
			add_test1B_fp.s = 1;
		}
		else {
			add_test1B_fp.s = 0;
		}
//		add_test1B_fp.s = extractBits(30,31, line2_int);

		//find the exponent of the second number
		//the variable "exponent" is a string
		char exponent2[] = {add_test1B[8], add_test1B[7], add_test1B[6], add_test1B[5], add_test1B[4], add_test1B[3], add_test1B[2], add_test1B[1], '\0'};
		//add_test1B_fp.e = atoi(exponent.c_str());
		add_test1B_fp.e = stoi(exponent, nullptr, 2);
//		add_test1B_fp.e = extractBits(23,30, (int)atoi(line2.c_str()));
//		add_test1B_fp.e = extractBits(23,30, line2_int);

		//find the mantissa of the second number
		char mantissa2[] = {add_test1B[31], add_test1B[30], add_test1B[29], add_test1B[28], add_test1B[27], add_test1B[26], add_test1B[25], add_test1B[24], add_test1B[23], add_test1B[22], add_test1B[21], add_test1B[20], add_test1B[19], add_test1B[18], add_test1B[17], add_test1B[16], add_test1B[15], add_test1B[14], add_test1B[13], add_test1B[12], add_test1B[11], add_test1B[10], add_test1B[9], '\0'};
		//add_test1B_fp.m = atoi(mantissa.c_str());
		add_test1B_fp.m = stoi(mantissa, nullptr, 2);
//		add_test1B_fp.m = extractBits(0,22, (int)atoi(line2.c_str()));
//		add_test1B_fp.m = extractBits(0,22, line2_int);
		

		//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
		//addition function: use add_test1A and add_test1B
		//the result is test1_add_fp, the result is in fp_t
		test1_add_fp = adder((add_test1A_fp), (add_test1B_fp), 0);


		//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
		//int_test1_add_fp = (test1_add_fp.s << 31)+((test1_add_fp.e<<23)&0x7F800000)+(test1_add_fp.m&0x007FFFFF);

		//use the "pack_f" function, the result is now in a float data type
		test1_add_float = pack_f(test1_add_fp);
		
		//convert to 32 bits
		itest1_add_float = *(int*)&test1_add_float;	

		//use the stringstream for the sign of the output
		//if (test1_add_fp.s == 0){
		//	str_s_test1_add_fp = '0';
		//}
		//else {
		//	str_s_test1_add_fp = '1';
		//}
		

		//use the stringstream for the exponent of the output
		//ss_e_test1_add_fp << test1_add_fp.e;
		//str_e_test1_add_fp = ss_e_test1_add_fp.str();

		//use the stringstream for the mantissa of the output
		//ss_m_test1_add_fp << test1_add_fp.m;
		//str_m_test1_add_fp = ss_m_test1_add_fp.str();

		//find the final output number
		//final_test1_add_fp = str_s_test1_add_fp + str_e_test1_add_fp + str_m_test1_add_fp;
//		stringstream ss_final;
//		ss_final << int_test1_add_fp;
//		final_test1_add_fp = ss_final.str();
//		final_test1_add_fp = final_test1_add_fp + "\n";

		//write the output to the text file
		//outFile <<std::hex<< final_test1_add_fp;
		outFile << (bitset<32>)itest1_add_float << "\n";
	}

	//close the input file
	inFile.close();


	//outFile << line2;

	//close the output file	
	outFile.close();
  
	//return 0 if no errors
	return 0;
}


//test for the multiplication function
int testCodeMultiplication () {


	return 0;
}
