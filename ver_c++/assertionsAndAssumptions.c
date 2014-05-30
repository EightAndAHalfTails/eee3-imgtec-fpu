#include <stdio.h>      /* printf */
#include <assert.h>     /* assert */
using namespace std;
#include <iostream>
#include <fstream>
#include <string>

//////////////////floating point struct//////////////////////
struct fp_t{
	int s;	//sign
	int e;	//exponent
	int m;	//mantissa
};

//////////////////////function prototypes////////////////////
fp_t unpack_f(float a_f);
float pack_f(fp_t a_fp);
void testCase(fp_t* floatingPointNumber);
//addition function
float adder(float, float, bool);	//takes in 32-bit floating point numbers and return sum
//multiplication function
float multiplier(float, float);
//function for testing
int testCode();

//////////////////////main function//////////////////////////
int main ()
{





	testCode();



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

	if(a_f < 0){
	a_fp.s = 1;
	}else{
	a_fp.s = 0;
	}

	index = floor(logf(fabs(a_f))/logf(2.0));
	//cout<<endl<<index;
	a_fp.e = 127+index;

	rem = (abs(a_f)/pow(2.0,index))-1;

	a_fp.m = 0x0;
	for(int i = 1; i <= 22; i++){
	place = pow(2.0,-i);
	//cout<<rem<<" "<<place;
	if((rem - place) >= 0){
	a_fp.m <<= 1;
	a_fp.m++;
	rem = rem - place;
	}else{
	a_fp.m <<= 1;
	}
	//cout<<" "<<hex<<a_fp.m<<endl;
	}

	a_fp.m <<= 1;
	//if(rem !=0) a_fp.m++;
	//cout<<" "<<hex<<a_fp.m<<endl;

	return a_fp;
}

float pack_f(fp_t a_fp){
	int a_i;
	float a_f;
	a_i = (a_fp.s << 31)+((a_fp.e<<23)&0x7F800000)+(a_fp.m&0x007FFFFF);
	a_f = *(float*)&a_i;
	return a_f;
}

float adder(float a_f, float b_f, bool IsSub){
	fp_t x, y, z;
	float c_f;

	// unpack
	x = unpack_f(a_f);
	y = unpack_f(b_f);
	z.s = 0; z.m = 0; z.e = 0;

	cout<<endl;
	cout<<a_f<<": "<<dec<<x.s<<"-"<<x.e<<"-"<<hex<<x.m<<endl
	<<b_f<<": "<<dec<<y.s<<"-"<<y.e<<"-"<<hex<<y.m<<endl<<endl;

	// Create significand
	x.m |= 0x00800000;
	y.m |= 0x00800000;

	//cout<<a_f<<": "<<dec<<x.s<<"-"<<x.e<<"-"<<hex<<x.m<<endl
	// <<b_f<<": "<<dec<<y.s<<"-"<<y.e<<"-"<<hex<<y.m<<endl<<endl;

	// difference of exponents
	int d;
	d = x.e-y.e;

	//cout<<"Difference in exponents: "<<dec<<d<<endl;

	// align significand
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


	// decision: add or subtract?
	if(x.m > y.m){
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

	//cout<<dec<<x.s<<"-"<<z.e<<"-"<<hex<<x.m<<endl
	// <<dec<<y.s<<"-"<<z.e<<"-"<<hex<<y.m<<endl
	// <<dec<<z.s<<"-"<<z.e<<"-"<<hex<<z.m<<endl;

	// add
	z.m += x.m + y.m;
	//cout<<"Significand Sum: "<<hex<<z.m<<endl;

	// Rounding and normalisation
	int err = extractBits(24,31,z.m);
	z.m = z.m>>err;
	z.e += err;
	//cout<<z.m<<endl;

	// Turn significand into mantissa
	z.m &= 0x7FFFFF;
	cout<<"Result: "<<z.s<<"-"<<dec<<z.e<<"-"<<hex<<z.m<<endl;

	c_f = pack_f(z);
	//cout<<dec<<c_f<<endl<<endl;

	return c_f;
}

float multiplier(float a_f, float b_f){
	fp_t x, y, z;
	float c_f;

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

	z.m &= 0x7FFFFF;
	cout<<"Result: "<<z.s<<"-"<<dec<<z.e<<"-"<<hex<<z.m<<endl;

	c_f = pack_f(z);
	//cout<<dec<<c_f<<endl<<endl;

	return c_f;
}

void testCase(float* floatingPointNumber, float* floatingPointNumber2) {

	//use assertions and assumptions
  	assert (floatingPointNumber != floatingPointNumber2);
		printf ("Error: %f\n",*floatingPointNumber);
}










//test for adder
int testCode () {
	
	ifstream inFile ("test2-positive_negative.txt");
    	
    	ofstream outFile;
	outFile.open ("test2_output.txt");

	//from 0 to 31
	char add_test1A[32], add_test1B[32];
	
	fp_t add_test1A_fp, add_test1B_fp;
	fp_t test1_add;
	
	String exponent, mantissa;
	
	
	
	
	if (inFile.is_open())
	{
		while ( getline (inFile,line) )
		{

			cout << add_test1A << add_test1B << '\n';


			if (add_test1A[0] == 1){
				add_test1A_fp.s = 1;
			}
			else {
				add_test1A_fp.s = 0; 	
			}

				
			exponent = add_test1A[1] + add_test1A[2] + add_test1A[3] + add_test1A[4] + add_test1A[5] + add_test1A[6] + add_test1A[7] + add_test1A[8];
			add_test1A_fp.e = atoi(exponent.c_str());
		
			
			mantissa = add_test1A[9] + add_test1A[10] + add_test1A[11] + add_test1A[12] + add_test1A[13] + add_test1A[14] + add_test1A[15] + add_test1A[16] + add_test1A[17] + add_test1A[18] + add_test1A[19] + add_test1A[20] + add_test1A[21] + add_test1A[22] + add_test1A[23] + add_test1A[24] + add_test1A[25] + add_test1A[26] + add_test1A[27] + add_test1A[28] + add_test1A[29] + add_test1A[30] + add_test1A[31];
			add_test1A_fp.m = atoi(mantissa.c_str());
			
			
			if (add_test1A[0] == 1){
				add_test1B_fp.s = 1;
			}
			else {
				add_test1B_fp.s = 0; 	
			}

				
			exponent = add_test1B[1] + add_test1B[2] + add_test1B[3] + add_test1B[4] + add_test1B[5] + add_test1B[6] + add_test1B[7] + add_test1B[8];
			add_test1A_fp.e = atoi(exponent.c_str());
		
			
			mantissa = add_test1B[9] + add_test1B[10] + add_test1B[11] + add_test1B[12] + add_test1B[13] + add_test1B[14] + add_test1B[15] + add_test1B[16] + add_test1B[17] + add_test1B[18] + add_test1B[19] + add_test1B[20] + add_test1B[21] + add_test1B[22] + add_test1B[23] + add_test1B[24] + add_test1B[25] + add_test1B[26] + add_test1B[27] + add_test1B[28] + add_test1B[29] + add_test1B[30] + add_test1B[31];
			add_test1B_fp.m = atoi(mantissa.c_str());
			
			
		
			//addition function: use add_test1A and add_test1B
			//the result is test1_add
			test1_add = adder(pack_f(add_test1A_fp), pack_f(add_test1B_fp), 0);
			outFile << unpack_f(test1_add);


			
		}
		inFile.close();
	}

	else cout << "Unable to open file"; 

	outFile.close();

  
  
  
  
  
	//return 0 if no errors	
	return 0;
}


