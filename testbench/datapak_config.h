//datapak_config.h

//number of lines in datapak
#ifndef NUMLINES
	#define NUMLINES 20
#endif

//generate negative numbers
#ifndef GEN_NEG
	#define GEN_NEG 0
#endif

//generate denormal numbers if 0
#ifndef NO_DENORMALS
	#define NO_DENORMALS 1
#endif

//generate numbers in binary ieee754 format
#ifndef GEN_BIN
	#define GEN_BIN 1
#endif

//number of random numbers generated per line, default
#ifdef NUM_INPUTS
	#if NUM_INPUTS==1
		#define OUTFILE_NAME "oneInput_datapak.txt"		
	#elif NUM_INPUTS==3
		#define OUTFILE_NAME "threeInput_datapak.txt"
	#elif NUM_INPUT==4
		#define OUTFILE_NAME "fourInput_datapak.txt"
	#elif NUM_INPUT==6
		#define OUTFILE_NAME "fiveInput_datapak.txt"
	#else
		#undef NUM_INPUTS
		#define NUM_INPUTS 2
		#define OUTFILE_NAME "twoInput_datapak.txt"
	#endif
#else
	#define NUM_INPUTS 2
	#define OUTFILE_NAME "twoInput_datapak.txt"
#endif