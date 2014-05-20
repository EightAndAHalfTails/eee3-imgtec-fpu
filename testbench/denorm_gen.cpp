//**********************************************************************************//
// Generates random floating point denormal numbers				   					//
//														   							//
// Options: -DNUMINPUTS=x, define number of random number per line (default=2)		//
// 			-DNUMLINES=x, define number of lines in datapak (default=20)	   		//
//			-DGEN_NEG=x, generate negative numbers (default=0)						//
//			-DNO_ZEROES=x, generate zeroes if 0 (default=0)							//
//			-DGEN_BIN=x, generate numbers in binary IEEE 754 format (default=1)		//
//																					//
// To compile: g++ -o denorm_gen.exe denorm_gen.cpp datapak_config.h <options>	//
//																					//
// author: Weng Lio										   							//
// last modified: 20/05/2014							   							//
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
float random_denormal();

// MAIN FUNCTION
int main(){
	ofstream f(OUTFILE_NAME);

	float num[NUM_INPUTS];
	int inum[NUM_INPUTS];
	int i, j;

	if(f.is_open()){
		srand(static_cast<unsigned>(time(0)));	//generate random seed

		for(i=0; i<NUM_INPUTS; i++){
			
			num[i] = random_denormal();
			if(GEN_BIN){
				inum[i] = *(int*)&num[i];		
				f << (bitset<32>)inum[i] << " ";
			}
			else{
				f.precision(std::numeric_limits<float>::digits10);
				f << num[i] << " ";
			}
		}		
		
		for(j = 0; j<NUMLINES-1; j++){
			f << "\n";
			for(i=0; i<NUM_INPUTS; i++){			
				num[i] = random_denormal();
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
	
	if(GEN_NEG)
		s = rand()%2;
	else		//only generates positive fp numbers
		s = 0;
	
	e = rand()%255;
	if(NO_DENORMALS){
		while(e == 0)
			e = rand()%255;
	}
	
	m = 0;
	for (int j = 0; j < 23 ; j++){
		m += (rand()%2) << j;
	}

	num = pack(s, e, m);

	return num;
}

float random_denormal(){
	short s;
	int e;
	long m;
	float num;
	
	if(GEN_NEG)
		s = rand()%2;
	else		//only generates positive fp numbers
		s = 0;
	
	e = 0;
	
	m = 0;
	if(NO_ZEROES){
		while(m==0){
			for (int j = 0; j < 23 ; j++){
				m += (rand()%2) << j;
			}
		}
	}
	else{
		for (int j = 0; j < 23 ; j++){
			m += (rand()%2) << j;
		}
	
	}

	num = pack(s, e, m);

	return num;
}