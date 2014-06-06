//**********************************************************************************//
// Generates random floating point numbers				   							//
//														   							//
// Options: -DNUM_INPUTS=x, define number of random number per line (default=2)		//
// 			-DNUMLINES=x, define number of lines in datapak (default=20)	   		//
//			-DGEN_NEG=x, generate negative numbers (default=0)						//
//			-DGEN_BIN=x, generate numbers in binary IEEE 754 format (default=1)		//
//			-DDENORM_PROB=x, percentage of denormals, between 1 and 0 (default=0)	//
//			-DINF_PROB=x, percentage of +/- infinity, between 1 and 0 (default=0)	//
//			-DNAN_PROB=x, percentage of NaNs, between 1 and 0 (default=0)			//
//			-DZEROS_PROB=x, percentage of zeros, between 1 and 0 (default=0)		//
//			-DPRINT_OPTIONS=x, print declared options (default=1)																		//
// To compile: g++ -o datapak_gen.exe datapak_gen.cpp datapak_config.h <options>	//
//																					//
// author: Weng Lio										   							//
// last modified: 27/05/2014														// 
//**********************************************************************************//

#include <ctime>
#include <cstdlib>
#include <iostream>
#include <fstream>
#include <sstream>
#include <limits>
#include <bitset>
#include "datapak_config.h"		//default configurations
using namespace std;

// FUNCTION PROTOTYPES
float pack(short, int, long);
float generate_random_fp();

// MAIN FUNCTION
int main(){
	ofstream f(OUTFILE_NAME);

	float num[NUM_INPUTS];
	int inum[NUM_INPUTS];
	int i, j;

	if(PRINT_OPTIONS){
		cout << "num_inputs = " << NUM_INPUTS << endl;
		cout << "numlines = " << NUMLINES << endl;
		cout << "gen_neg = " << GEN_NEG << endl;
		cout << "denorm_prob = " << DENORM_PROB << endl;
		cout << "inf_prob = " << INF_PROB << endl;
		cout << "nan_prob = " << NAN_PROB << endl;
		cout << "zeros_prob = " << ZEROS_PROB << endl;
	}
	if(f.is_open()){
		srand(static_cast<unsigned>(time(0)));	//generate random seed

		// generate first line of random number
		for(i=0; i<NUM_INPUTS; i++){			
			num[i] = generate_random_fp();
			if(GEN_BIN){
				inum[i] = *(int*)&num[i];		
				f << (bitset<32>)inum[i] << " ";
			}
			else{
				f.precision(std::numeric_limits<float>::digits10);
				f << num[i] << " ";
			}
		}		
		
		//generate rest of the lines
		for(j = 0; j<NUMLINES-1; j++){
			f << "\n";
			for(i=0; i<NUM_INPUTS; i++){			
				num[i] = generate_random_fp();
				if(GEN_BIN){
					inum[i] = *(int*)&num[i];		
					f << (bitset<32>)inum[i] << " ";
				}
				else{
					f.precision(std::numeric_limits<float>::digits10);
					f << num[i] << " ";
				}
			}
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