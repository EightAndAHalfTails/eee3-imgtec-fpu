#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <cmath>
#include <fstream>
#include <string>

using namespace std;

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
int footer_i(fp_t a_fp);

int extractBits(int, int, int);
void round_norm(fp_t &z, int, int);

fp_t adder(fp_t, fp_t, bool);	//takes in 32-bit floating point numbers and return sum
fp_t multiplier(fp_t, fp_t);
float fma(float, float, float);
fp_t gold_divider(fp_t, fp_t);
fp_t newton_divider(fp_t, fp_t);
fp_t newton_rooter(fp_t);
fp_t newton_inverse_rooter(fp_t);
fp_t quake_inverse_rooter(fp_t);

//////////////////////main function//////////////////////////
int main(){
	float a, b, c, d, e, f;
	fp_t a_fp, b_fp, c_fp, d_fp, e_fp, f_fp;
	float z;
	fp_t z_fp;
	int a_i, b_i, z_i;
	int opcode;
	
	while(1){
		cout << "Input operation code, as a decimal:" << endl;
		cin>>opcode;	

		z = 169.703125;
	
		switch(opcode){
		case 0: cout<<"Null operation"; exit(0); break;

		case 1: cout << "Input two numbers to be multiplied" << endl;
				cin>>a; a_fp = header(a);
				cin>>b;	b_fp = header(b);
				//z = a*b;
				z_fp = multiplier(a_fp,b_fp);
				z = footer(z_fp);
				cout<<a<<"*"<<b<<"="<<z; break;
		
		case 2: cout << "Input two numbers to be added" << endl;
				cin>>a;	a_fp = header(a);
				cin>>b;	b_fp = header(b);
				//z = a+b;
				z_fp = adder(a_fp,b_fp, false);
				z = footer(z_fp);
				cout<<a<<"+"<<b<<"="<<z; break;

				/*a_fp.s = 0; a_fp.e = 137; a_fp.m = 0xf4da9b; //a607;
				b_fp.s = 0; b_fp.e = 113; b_fp.m = 0xa45a49;//fc56ed;
				z_fp = adder(a_fp,b_fp, false);
				z = footer(z_fp);
				break;*/
		
		case 3: cout << "Input two numbers to be subtracted" << endl;
				cin>>a; a_fp = header(a);
				cin>>b;	b_fp = header(b);
				//z = a-b;
				z_fp = adder(a_fp,b_fp, true);
				z = footer(z_fp);
				cout<<a<<"-"<<b<<"="<<z; break;
		
		case 4: cout << "Input three numbers to be MACed" << endl;
				cin>>a; a_fp = header(a);
				cin>>b;	b_fp = header(b);
				cin>>c;	c_fp = header(c);
				//z = (a*b)+c;
				z_fp = multiplier(a_fp,b_fp);
				z_fp = adder(z_fp,c_fp, false);
				z = footer(z_fp);
				cout<<"("<<a<<"*"<<b<<")+"<<c<<"="<<z; break;
		
		case 5: cout << "Input two numbers to be divided" << endl;
				cin>>a; a_fp = header(a);
				cin>>b;	b_fp = header(b);
				//z = a/b;
				//z_fp = gold_divider(a_fp, b_fp);
				z_fp = newton_divider(a_fp, b_fp);
				z = footer(z_fp);
				cout<<a<<"/"<<b<<"="<<z; break;

		case 6: cout << "Input two 2-vectors to be dotted" << endl;
				cin>>a; a_fp = header(a);
				cin>>b;	b_fp = header(b);
				cin>>c;	c_fp = header(c);
				cin>>d;	d_fp = header(d);
				z = (a*c)+(b*d);
				// y_fp = multiplier(a_fp,c_fp);
				// z_fp = multiplier(b_fp,d_fp);
				// z_fp = adder(y_fp,z_fp, false);
				//z = footer(z_fp);
				cout<<"("<<a<<","<<b<<").("<<c<<","<<d<<")="<<z; break;

		case 7: cout << "Input two 3-vectors to be dotted" << endl;
				cin>>a; a_fp = header(a);
				cin>>b;	b_fp = header(b);
				cin>>c;	c_fp = header(c);
				cin>>d;	d_fp = header(d);
				cin>>e;	e_fp = header(e);
				cin>>f;	f_fp = header(f);
				z = (a*d)+(b*e)+(c*f);
				// x_fp = multiplier(a_fp,d_fp);
				// y_fp = multiplier(b_fp,e_fp);
				// z_fp = multiplier(c_fp,f_fp);
				// z_fp = adder(y_fp,z_fp, false);
				// z_fp = adder(x_fp,z_fp, false);
				//z = footer(z_fp);
				cout<<"("<<a<<","<<b<<","<<c<<").("<<d<<","<<e<<","<<f<<")="<<z; break;

		case 8: cout << "Input number to be square-rooted" << endl;
				cin>>a; a_fp = header(a);
				//z = sqrt(a);
				z_fp = newton_rooter(a_fp);
				z = footer(z_fp);
				cout<<a<<"^0.5"<<"="<<z; break;

		case 9: cout << "Input number to be inverse square-rooted" << endl;
				cin>>a; a_fp = header(a);
				//z = 1/(sqrt(a));
				//z_fp = newton_inverse_rooter(a_fp);
				z_fp = quake_inverse_rooter(a_fp);
				z = footer(z_fp);
				cout<<a<<"^-0.5"<<"="<<z; break;

		case 10: cout << "Input two points for the Euclidean distance" << endl;
				cin>>a; a_fp = header(a);
				cin>>b;	b_fp = header(b);
				z = sqrt((a*a) + (b*b));
				cout<<"|"<<a<<","<<b<<"|="<<z; break;

		case 11: cout << "Input three points for the Euclidean distance" << endl;
				cin>>a; a_fp = header(a);
				cin>>b;	b_fp = header(b);
				cin>>c;	c_fp = header(c);
				z = sqrt((a*a) + (b*b) + (c*c));
				cout<<"|"<<a<<","<<b<<","<<c<<"|="<<z; break;

		case 12: cout << "Input 3-vector to be normalised" << endl;
				cin>>a; a_fp = header(a);
				cin>>b;	b_fp = header(b);
				cin>>c;	c_fp = header(c);
				z = a/(sqrt((a*a) + (b*b) + (c*c)));
				cout<<a<<"/ |"<<a<<","<<b<<","<<c<<"| ) ="<<z;

		case 13: cout<<"No op"; break;
		case 14: cout<<"No op"; break;
		case 15: cout<<"No op"; break;
		default: cout<<"No op"; break;
		}

		cout<<endl<<endl;
	}
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
	a_fp.e = 0x7F+index;

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
	a_fp.e = 0x7F+index;

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
		int lzd = 25;
		int found = 0;
		int err;
		while(!found){
			err = extractBits(lzd,lzd,a_fp.m);
			//cout<<"lzd: "<<dec<<lzd<<endl;
			//cout<<"err: "<<dec<<err<<endl;
			if(err == 1){
				found = 1;
			}else{
				lzd--;
			}
		}
		
		lzd = lzd - 23;
		if(lzd > 0){
			a_fp.m >>= lzd;
		}else{
			a_fp.m <<= -lzd;
		}
		a_fp.e += lzd;
	
	// Remove significand's leading 1 bit
	a_fp.m &= 0x007FFFFF;
	}
	//cout<<"Result: "<<a_fp.s<<"-"<<dec<<a_fp.e<<"-"<<hex<<a_fp.m<<endl;	
	
	// Convert to float
	a_i = (a_fp.s << 31)+((a_fp.e<<23)&0x7F800000)+(a_fp.m&0x007FFFFF);
	a_f = *(float*)&a_i;
	return a_f;
}

int footer_i(fp_t a_fp){
	int a_i;

	// Remove significand's leading 1 bit
	a_fp.m &= 0x007FFFFF;
	cout<<"Result: "<<dec<<a_fp.s<<"-"<<a_fp.e<<"-"<<hex<<a_fp.m<<endl;	
	
	// Convert to int
	a_i = (a_fp.s << 31)+((a_fp.e<<23)&0x7F800000)+(a_fp.m&0x007FFFFF);
	return a_i;
}

int extractBits(int a, int b, int z){
	z = z>>a;
	//cout<<hex<<z<<endl;

	int n = 0x1;
	for(int i=a; i<b; i++){
		n <<=1;
		//cout<<hex<<n<<"	";
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

void round_norm(fp_t &z, int lostbit_high, int lostbit_low){
	int LSB;
	
	// Normalisation
	if(z.m != 0){
		int lzd = 25;
		int found = 0;
		int err;
		while(!found){
			err = extractBits(lzd,lzd,z.m);
			//cout<<"lzd: "<<dec<<lzd<<endl;
			//cout<<"err: "<<dec<<err<<endl;
			if(err == 1){
				found = 1;
			}else{
				lzd--;
			}
		}
		
		lzd = lzd - 23;
		if(lzd > 0){
			if(lostbit_low == 0){
				lostbit_low = lostbit_high;
			}
			lostbit_high = extractBits(0,1,z.m);
			z.m >>= lzd;
		}else{
			z.m <<= -lzd;
		}
		z.e += lzd;
	}
	
	// Rounding
	LSB = extractBits(0,0,z.m);
	//cout<<LSB<<"	"<<lostbit_high<<"	"<<lostbit_low<<endl;
	if(lostbit_high == 1 & (LSB | lostbit_low)){
		z.m += 1;
	}
}

fp_t adder(fp_t x, fp_t y, bool IsSub){
	fp_t z;
	int lostbit_high = 0, lostbit_low = 0;
	
	z.s = 0; z.m = 0; z.e = 0;

	// Full numbers (with significands)
	//cout<<"x: "<<dec<<x.s<<"-"<<x.e<<"-"<<hex<<x.m<<endl
	//	<<"y: "<<dec<<y.s<<"-"<<y.e<<"-"<<hex<<y.m<<endl<<endl;

	// Difference of exponents
	int d;
	d = x.e-y.e;
	//cout<<"Difference of exponents: "<<dec<<d<<endl;

	// Align significands
	if(d>0){
		for(int j = 0; j<d; j++){
			
			if(lostbit_low == 0){
				lostbit_low = lostbit_high;
			}
			lostbit_high = extractBits(0,0,y.m);
			
			y.m >>= 1;
		}
		z.e = x.e;
	}else if(d<0){
		for(int j = 0; j>d; j--){
			
			if(lostbit_low == 0){
				lostbit_low = lostbit_high;
			}
			lostbit_high = extractBits(0,0,x.m);
			
			x.m >>= 1;
		}
		z.e = y.e;
	}else{
		z.e = x.e;
	}
	
	//cout<<"x: "<<dec<<x.s<<"-"<<x.e<<"-"<<hex<<x.m<<endl
	//	<<"y: "<<dec<<y.s<<"-"<<y.e<<"-"<<hex<<y.m<<endl<<endl;
	
	// decision: add or subtract?
	if(x.m >= y.m){
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

	// add
	z.m += x.m + y.m;
	//cout<<"Significand Sum: "<<hex<<z.m<<endl;
	
	// Rounding and normalisation
	round_norm(z, lostbit_high, lostbit_low);
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
	//	<<"y: "<<dec<<y.s<<"-"<<y.e<<"-"<<hex<<y.m<<endl<<endl;
	
	// Calculate sign
	if(x.s != y.s){
		z.s = 1;
	}

	// New exponent
	if(x.e != 0 & y.e != 0){
		z.e = x.e + y.e - 0x7F;
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
	//	<<"-x: "<<negxm<<endl
	//	<<"2x: "<<twoxm<<endl
	//	<<"-2x: "<<negtwoxm<<endl<<endl;
	
	// Multiply via Booth additions
	int lostone = 0; int lostbits = 0;
	for(int i = 0; i<=11; i++){
		beys = extractBits(2*i,(2*i)+2,y.m);
		//cout<<dec<<2*i<<" to "<<(2*i)+2<<" is "<<hex<<beys<<endl;
		//cout<<hex<<z.m<<"	";
		if(lostone == 0){
			lostbits = extractBits(0,1,z.m);
			if(lostbits != 0){
				lostone = 1;
			}
		}
		z.m = z.m>>2;
		if(z.m>>30 == 1){
			z.m |= 0x60000000;
		}
		//cout<<hex<<z.m<<"	";
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
		//cout<<"New estimate: "<<hex<<beys<<"	"<<z.m<<endl;
	}

	if(y.e != 0){
		if(lostone == 0){
			lostbits = extractBits(0,1,z.m);
			if(lostbits != 0){
				lostone = 1;
			}
		}
		z.m = z.m>>2;
		z.m += x.m; // this takes account of the leading 1
	}
	
	z.m <<= 1;

	// Full number (with significand)
	//cout<<"z: "<<dec<<z.s<<"-"<<z.e<<"-"<<hex<<z.m<<endl<<endl;
	
	return z;
}

fp_t fma(fp_t x, fp_t y, fp_t w){
	fp_t z;
	
	z.s = 0; z.m = 0; z.e = 0;
	
	// Full numbers (with significands)
	//cout<<"x: "<<dec<<x.s<<"-"<<x.e<<"-"<<hex<<x.m<<endl
	//	<<"y: "<<dec<<y.s<<"-"<<y.e<<"-"<<hex<<y.m<<endl<<endl;
	
	// Calculate sign
	if(x.s != y.s){
		z.s = 1;
	}

	// New exponent
	if(x.e != 0 & y.e != 0){
		z.e = x.e + y.e - 0x7F;
	}
	//cout<<"New exponent: "<<dec<<z.e<<endl;
	
	return z;
}

fp_t gold_divider(fp_t x, fp_t y){
	fp_t z;
	
	z.s = 0; z.m = 0; z.e = 0;
	
	// Full number (with significand)
	//cout<<"y: "<<dec<<y.s<<"-"<<y.e<<"-"<<hex<<y.m<<endl<<endl;
	
	// Calculate sign
	if(x.s != y.s){
		z.s = 1;
	}

	// Divide by power of 2, base case
	if(y.m == 0x800000){
		z.e = x.e - y.e + 0x7F;
		z.m = x.m;
		return z;
	}

	// Goldschmidt's Algorithm
	int sign;
	fp_t f, n, two;

	sign = z.s; // preserves sign bit, to be reused later
	x.s = 0; y.s = 0; // Goldschmidt's Algorithm works with positive numbers
	two.s = 0; two.e = 128; two.m = 0x800000; // define 2.0 in floating point to used in subtraction
	f.s = 0; f.e = 254 - y.e; f.m = 0x800000; // initial guess is highest power of 2 below divisor

	z = x;
	
	int i = 0;
	while( i < 5 ){

		if(z.m == 0){		// if the exact answer is found, break, otherwise iterate
			break;
		}else{
			i++;
		}
		
		y = multiplier(f,y);	round_norm(y,0,0);	// calculate new value for denominator
		z = multiplier(f,z);	round_norm(z,0,0);	// calculate new value for numerator
		f = adder(two,y,true);
	}
	
	z.s = sign;
	
	// Full number (with significand)
	//cout<<"z: "<<dec<<z.s<<"-"<<z.e<<"-"<<hex<<z.m<<endl<<endl;
	
	return z;
}

fp_t newton_divider(fp_t x, fp_t y){
	fp_t z;
	
	z.s = 0; z.m = 0; z.e = 0;
	
	// Full number (with significand)
	//cout<<"y: "<<dec<<y.s<<"-"<<y.e<<"-"<<hex<<y.m<<endl<<endl;
	
	// Calculate sign
	if(x.s != y.s){
		z.s = 1;
	}

	// Divide by power of 2, base case
	if(y.m == 0x800000){
		z.e = x.e - y.e + 0x7F;
		z.m = x.m;
		return z;
	}

	// Newton-Raphson Method
	int sign;
	fp_t two, x0;

	sign = z.s; // preserves sign bit, to be reused later
	x.s = 0; y.s = 0; // Use algorithm with positive numbers
	two.s = 0; two.e = 128; two.m = 0x800000; // define 2.0 in floating point to be used in subtraction
	z.s = 0; z.e = 254 - y.e; z.m = 0x800000; // initial guess is the reciprocal of the highest power of 2 below divisor
	
	int i = 0;
	while( i < 5 ){
		
		x0 = z;
		z = multiplier(y,x0);	round_norm(z,0,0);
		z = adder(two,z,true);
		z = multiplier(z,x0);	round_norm(z,0,0);

		i++;

	}
		
	z = multiplier(z,x);	round_norm(z,0,0);
	z.s = sign;
	
	// Full number (with significand)
	//cout<<"z: "<<dec<<z.s<<"-"<<z.e<<"-"<<hex<<z.m<<endl<<endl;
	
	return z;
}

fp_t newton_rooter(fp_t x){
	fp_t z;
	
	z.s = 0; z.m = 0; z.e = 0;
	
	// Full number (with significand)
	//cout<<"y: "<<dec<<y.s<<"-"<<y.e<<"-"<<hex<<y.m<<endl<<endl;
	
	// Check if positive
	if(x.s != 0){
		if(x.e == 0 & x.m == 0){
			return x;		// if the input is -0, return -0
		}else{
			z.e = 0xFF;
			z.m = 0x1;
			return z;		// otherwise return a NaN
			}
	}else if(x.e == 0 & x.m == 0){
		return x;
	}

	// Newton-Raphson Method
	fp_t x0;
	float x0_f, z_f, x_f;

	// initial guess is the root of the highest rootable power of 2 below radicand
	z.s = 0; z.e = 0x7F + x.e; z.e >>= 1; z.m = 0x800000;
	x0 = z;

	int i = 0;
	while( i < 5 ){
	
		z = newton_divider(x,x0);	round_norm(z,0,0);
		z = adder(z,x0,false);		round_norm(z,0,0);
		z.e--;

		i++;

		x0 = z;
	}
	
	// Full number (with significand)
	//cout<<"z: "<<dec<<z.s<<"-"<<z.e<<"-"<<hex<<z.m<<endl<<endl;
	
	return z;
}

fp_t newton_inverse_rooter(fp_t x){
	fp_t z;
	
	z.s = 0; z.m = 0; z.e = 0;
	
	// Full number (with significand)
	//cout<<"y: "<<dec<<y.s<<"-"<<y.e<<"-"<<hex<<y.m<<endl<<endl;
	
	// Check if positive
	if(x.s != 0){
		if(x.e == 0 & x.m == 0){
			return x;		// if the input is -0, return -0
		}else{
			z.e = 0xFF;
			z.m = 0x1;
			return z;		// otherwise return a NaN
			}
	}

	// Newton-Raphson Method
	fp_t three, x0;

	three.s = 0; three.e = 128; three.m = 0xC00000; // define 3.0 in floating point to be used in subtraction
	// initial guess is the reciprocal of the root of the highest rootable power of 2 below radicand
	z.s = 0; z.e = 381 - x.e; z.e >>= 1; z.m = 0x800000;
	
	int i = 0;
	while( i < 5 ){
		
		x0 = z;
		z = multiplier(x0,x0);	round_norm(z,0,0);
		z = multiplier(x,z);	round_norm(z,0,0);
		z = adder(three,z,true);
		z = multiplier(x0,z);	round_norm(z,0,0);
		z.e--;

		i++;

	}
	
	// Full number (with significand)
	//cout<<"z: "<<dec<<z.s<<"-"<<z.e<<"-"<<hex<<z.m<<endl<<endl;
	
	return z;
}

fp_t quake_inverse_rooter(fp_t x){
	fp_t z;
	
	z.s = 0; z.m = 0; z.e = 0;
	
	// Full number (with significand)
	//cout<<"y: "<<dec<<y.s<<"-"<<y.e<<"-"<<hex<<y.m<<endl<<endl;
	
	// Check if positive
	if(x.s != 0){
		if(x.e == 0 & x.m == 0){
			return x;		// if the input is -0, return -0
		}else{
			z.e = 0xFF;
			z.m = 0x1;
			return z;		// otherwise return a NaN
		}
	}

	// Quake Algorithm
	fp_t halfno, threehalves, y, quake_const;
	
	threehalves.s = 0; threehalves.e = 0x7F; threehalves.m = 0xC00000; // define 1.5 in floating point to be used in subtraction
	quake_const.s = 0; quake_const.e = 190; quake_const.m = 0xB759DF; // Quake constant used to find inverse root quickly
	
	halfno = x;
	halfno.e--;
	z = halfno;
	z = adder(quake_const,z,true);	// subtract the fp_t equivalent of 0x5f3759df
	y = z;
	z = multiplier(z,z);		round_norm(z,0,0);
	z = multiplier(halfno,z);	round_norm(z,0,0);
	z = adder(threehalves,z,true);
	z = multiplier(y,z);		round_norm(z,0,0);
	
	// Full number (with significand)
	//cout<<"z: "<<dec<<z.s<<"-"<<z.e<<"-"<<hex<<z.m<<endl<<endl;
	
	return z;
}