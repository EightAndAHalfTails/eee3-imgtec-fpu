//**********************************************************************************//
// Generates random floating point numbers operations	   							//
// Test data for fpu entity								   							//
// Options:	-DNUMLINES=x, define number of lines in datapak (default=1000)	   		//
//																					//
// To compile: g++ -o datapak_gen.exe datapak_gen.cpp datapak_config.h <options>	//
//																					//
// author: Weng Lio										   							//
// last modified: 15/06/2014														// 
//**********************************************************************************//

#include <ctime>
#include <cstdlib>
#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <limits>
#include <bitset>
using namespace std;

// random numbers properties
#define GEN_NEG 1
#define DENORM_PROB 0.3
#define ZEROS_PROB 0.05
#define INF_PROB 0.03
#define NAN_PROB 0.02
#define PRINT_OPTIONS 1

#ifndef NUMLINES
	#define NUMLINES 1000
#endif

#define OUTFILE_NAME "fpu_input.txt"

const string cmdOptions[] = {	"nop_", "mul_", "add_", "sub_", 
								"fma_", "div_", "dot2", "dot3", 
								"sqrt", "isqr", "mag2", "mag3", 
								"norm"	};
const int numOperands[] = { 0, 2, 2, 2, 3, 2, 4, 6, 1, 1, 2, 3, 3 };
				
// FUNCTION PROTOTYPES
float pack(short, int, long);
float generate_random_fp();

// MAIN FUNCTION
int main(){
	ofstream f(OUTFILE_NAME);

	float num[6];
	int inum[6];
	int i, j;
	int opcode;

	if(PRINT_OPTIONS){
		cout << "numlines = " << NUMLINES << endl;
		cout << "gen_neg = " << GEN_NEG << endl;
		cout << "denorm_prob = " << DENORM_PROB << endl;
		cout << "inf_prob = " << INF_PROB << endl;
		cout << "nan_prob = " << NAN_PROB << endl;
		cout << "zeros_prob = " << ZEROS_PROB << endl;
	}
	if(f.is_open()){
		srand(static_cast<unsigned>(time(0)));	//generate random seed

		opcode = rand()%12+1; //generate random opcode of 1-12
		f << cmdOptions[opcode] << " ";
		// generate first line of random number
		for(i=0; i<numOperands[opcode]; i++){
			
			num[i] = generate_random_fp();
			inum[i] = *(int*)&num[i];		
			f << (bitset<32>)inum[i] << " ";
		}		
		
		//generate rest of the lines
		for(j = 0; j<NUMLINES-1; j++){
			f << "\n";
			opcode = rand()%12+1;
			f << cmdOptions[opcode] << " ";
			
			for(i=0; i<numOperands[opcode]; i++){			
				num[i] = generate_random_fp();
				inum[i] = *(int*)&num[i];		
				f << (bitset<32>)inum[i] << " ";
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
	
	// -- r is a random number that lies between 0 and 1 
	// -- determine the nature of the number generated	
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