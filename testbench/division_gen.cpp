//**********************************************************************************//
// Generates bounded random floating point numbers for non-zero bounded quotient	//
//														   							//
// Options: -DNUMINPUTS=x, define number of random number per line (default=2)		//
// 			-DNUMLINES=x, define number of lines in datapak (default=20)	   		//
//			-DGEN_NEG=x, generate negative numbers (default=0)						//
//			-DDENORM_PROB=x, percentage of denormals, between 1 and 0 (default=0)	//
//			-DINF_PROB=x, percentage of +/- infinity, between 1 and 0 (default=0)	//
//			-DNAN_PROB=x, percentage of NaNs, between 1 and 0 (default=0)			//
//			-DZEROS_PROB=x, percentage of zeros, between 1 and 0 (default=0)		//
//																					//
// To compile: g++ -o datapak_gen.exe datapak_gen.cpp datapak_config.h <options>	//
//																					//
// author: Weng Lio										   							//
// last modified: 29/05/2014														// 
//**********************************************************************************//

#include <ctime>
#include <cstdlib>
#include <iostream>
#include <fstream>
#include <sstream>
#include <limits>
#include <math.h> 
#include <bitset>
#include "datapak_config.h"		//default configurations
using namespace std;

// FUNCTION PROTOTYPES
float pack(short, int, long);
float generate_random_fp();

// MAIN FUNCTION
int main(){
	ofstream f("division_bounded.txt");

	float num[NUM_INPUTS];
	float quotient;
	int iquotient, q_exp;
	int inum[NUM_INPUTS];
	int i, j;

	if(f.is_open()){
		srand(static_cast<unsigned>(time(0)));	//generate random seed

		// generate first line of random number
		// repeats until output are non-zero, non-infinity normal numbers
		do{
			//generate two random fp numbers and get quotient
			num[0] = generate_random_fp();
			num[1] = generate_random_fp();
			quotient = num[0]/num[1];
			
			//map to 32-bit integer and get exponent bits
			iquotient = *(int*)&quotient;
			q_exp = ((iquotient>>23) & 0x000000FF);
			
		}while(q_exp == 0 || q_exp == 0x000000FF);
		
		inum[0] = *(int*)&num[0];
		inum[1] = *(int*)&num[1];
		f << (bitset<32>)inum[0] << " " << (bitset<32>)inum[1];

		//generate rest of the lines
		for(j = 0; j<NUMLINES-1; j++){

			do{
				num[0] = generate_random_fp();
				num[1] = generate_random_fp();	
				quotient = num[0]/num[1];
				iquotient = *(int*)&quotient;
				q_exp = ((iquotient>>23) & 0x000000FF);
				
			}while(q_exp == 0 || q_exp == 0x000000FF);
			
			f << "\n";
			inum[0] = *(int*)&num[0];
			inum[1] = *(int*)&num[1];
			f << (bitset<32>)inum[0] << " " << (bitset<32>)inum[1];

		}
		f.close();
	}
	else
		cout << "Unable to open file" << endl;
		
	return 0;
}

// FUNCTION DECLARATION
float pack(short s, int e, long m){
	int num;
	float num_f;
	
	num = (s << 31)+((e<<23)&0x7F800000)+(m&0x007FFFFF);
	num_f = *(float*)&num;
	return num_f;
}

float generate_random_fp(){
	short s;
	int e;
	long m;
	float num;
	double r; //random number for exponent generation
	bool zeromantissa = false;
	
	// sign generation
	if(GEN_NEG)
		s = rand()%2;
	else		//only generates positive fp numbers
		s = 0;
	
	
	// exponent generation
	
	// -- r is a uniform random number, where it lies between 0 and 1 
	// -- determine the number generated	
	r = (double)rand()/RAND_MAX;
	
	if(r < INF_PROB){
		e = 255;
		zeromantissa = true;
	}
	else if (r < (INF_PROB+NAN_PROB))
		e = 255;
	else if (r < (INF_PROB+NAN_PROB+ZEROS_PROB)){
		e = 0;
		zeromantissa = true;
	}
	else if (r < (INF_PROB+NAN_PROB+ZEROS_PROB+DENORM_PROB))
		e = 0;
	else{
		e = rand()%254+1;		// e between 1 and 254 inclusive
	}
	
	// mantissa generation
	m = 0;
	if(!zeromantissa){
		for (int j = 0; j < 23 ; j++){
			m += (rand()%2) << j;
		}
	}
	
	
	num = pack(s, e, m);

	return num;
}