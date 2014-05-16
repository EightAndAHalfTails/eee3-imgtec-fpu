//**********************************************************************************//
// Generates random floating point numbers				   							//
//														   							//
// Options: -DNUMINPUTS, define number of random number per line (default=2)		//
// 			-DNUMLINES, define number of lines in datapak (default=20)	   			//
//			-DGEN_NEG, generate negative numbers (default=0)						//
//			-DGEN_BIN, generate numbers in binary IEEE 754 format (default=1)		//
//																					//
// To compile: g++ -o datapak_gen.exe datapak_gen.cpp datapak_config.h <options>	//
//																					//
// author: Weng Lio										   							//
// last modified: 16/05/2014							   							//
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

	if(f.is_open()){
		srand(static_cast<unsigned>(time(0)));	//generate random seed

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
	
	if(GEN_NEG)
		s = rand()%2;
	else		//only generates positive fp numbers
		s = 0;
	
	e = rand()%255;
	
	m = 0;
	for (int j = 0; j < 23 ; j++){
		m += (rand()%2) << j;
	}

	num = pack(s, e, m);

	return num;
}