//*********************************************************//
// Generates random floating point numbers (2 per line)    //
// Choose to output in decimal or IEEE FP format		   //
//
// author: Weng Lio										   //
// last modified: 12/05/2014							   //
//*********************************************************//

#include <ctime>
#include <cstdlib>
#include <iostream>
#include <fstream>
#include <sstream>
#include <limits>
#include <bitset>
using namespace std;

#define NUMLINES 20					//  <-----------CHANGE NUMBER OF LINES GENERATED HERE
#define GENERATE_NEGATIVE_FP 0
#define GENERATE_BINARY_FP 0		//  <----------- 0 FOR NORMAL FP NUMBERS

// FUNCTION PROTOTYPES
float pack(short, int, long);
float generate_random_fp();

// MAIN FUNCTION
int main(){
	ofstream f("adder_datapak.txt");

	float num1, num2;
	int inum1, inum2;

	if(f.is_open()){
		srand(static_cast<unsigned>(time(0)));	//generate random seed

		num1 = generate_random_fp();
		num2 = generate_random_fp();
		
		if(GENERATE_BINARY_FP){
			inum1 = *(int*)&num1;
			inum2 = *(int*)&num2;			
			f << (bitset<32>)inum1 << " " << (bitset<32>)inum2;
		}
		else{
			f.precision(std::numeric_limits<float>::digits10);
			f << num1 << " " << num2;
		}
	
		for(int i = 0; i<NUMLINES-1; i++){		
			num1 = generate_random_fp();
			num2 = generate_random_fp();
			
			if(GENERATE_BINARY_FP){
				inum1 = *(int*)&num1;
				inum2 = *(int*)&num2;				
				f << "\n" << (bitset<32>)inum1 << " " << (bitset<32>)inum2;
			}
			else{
				f.precision(std::numeric_limits<float>::digits10);
				f << "\n" << num1 << " " << num2;
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
	
	if(GENERATE_NEGATIVE_FP)
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