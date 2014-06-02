#include <iostream>
#include <fstream>
#include <string>
#include <sstream>
#include <bitset>
#include <stdio.h> /* printf */
#include <assert.h> /* assert */
#include <math.h>
#include <cmath>

using namespace std;

struct fp_t{
int s;	//sign
int e;	//exponent
int m;	//mantissa
};

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


int main(){

	ifstream f("inputfile.txt");
	ofstream fout("outputfile.txt");

	bitset<32> b1, b2;
	int int1, int2;				//built in 32bit int type
	float float1, float2;		//built in c++ float type
	fp_t fp1, fp2;				//self declared fp_t type


	//while not End of File 
	while(!f.eof()){
		f >> b1 >> b2;

		float1 = *(float*)&b1;	//changing the int to float
		float2 = *(float*)&b2;

		cout << float2 << "\n"; 
		
		fp1 = unpack_f(float1);		//unpack into fp_t type
		fp2 = unpack_f(float2);

		fout << (bitset<32>)int1 << "\n";
	}

}