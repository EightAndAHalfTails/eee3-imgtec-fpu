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

int extractBits(int, int, int);
void round_norm(fp_t &z, int, int, bool);

fp_t adder(fp_t, fp_t, bool);
fp_t multiplier(fp_t, fp_t);
fp_t gold_divider(fp_t, fp_t);
fp_t gold2_divider(fp_t, fp_t);
fp_t newton_divider(fp_t, fp_t);
fp_t newton_divider_by_parts(fp_t, fp_t);
fp_t fractioning_rooter(fp_t);
fp_t newton_rooter(fp_t);
fp_t newton_reciprocal_rooter(fp_t);
fp_t quake_reciprocal_rooter(fp_t);
fp_t dual_rooter(fp_t, bool);

void read_in(fp_t &a_fp, fp_t &b_fp);
void output(fp_t &a_fp);

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
				/*cin>>a;	a_fp = header(a);
				cin>>b;	b_fp = header(b);
				//z = a+b;
				z_fp = adder(a_fp,b_fp, false);
				z = footer(z_fp);
				cout<<a<<"+"<<b<<"="<<z; break;*/

				a_fp.s = 0; a_fp.e = 0; a_fp.m = 0; //a607;
				b_fp.s = 0; b_fp.e = 0; b_fp.m = 0;//fc56ed;
				read_in(a_fp, b_fp);
				cout<<dec<<a_fp.s<<"-"<<a_fp.e<<"-"<<hex<<a_fp.m<<endl;	cout<<dec<<b_fp.s<<"-"<<b_fp.e<<"-"<<hex<<b_fp.m<<endl;
				z_fp = adder(a_fp,b_fp, false);
				z = footer(z_fp);
				a_fp.s = 0; a_fp.e = 0; a_fp.m = 0;
				output(a_fp);
				cout<<endl<<dec<<"Result:	"<<a_fp.s<<"-"<<a_fp.e<<"-"<<hex<<a_fp.m<<endl;
				break;
		
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
				z_fp = gold2_divider(a_fp, b_fp);
				//z_fp = newton_divider(a_fp, b_fp);
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
				//z_fp = newton_rooter(a_fp);
				//z_fp = fractioning_rooter(a_fp);
				z_fp = dual_rooter(a_fp, false);
				z = footer(z_fp);
				cout<<a<<"^0.5"<<"="<<z; break;

		case 9: cout << "Input number to be reciprocal square-rooted" << endl;
				cin>>a;	a_fp = header(a);
				//z = 1/(sqrt(a));
				//z_fp = newton_reciprocal_rooter(a_fp);
				//z_fp = quake_reciprocal_rooter(a_fp);
				z_fp = dual_rooter(a_fp, true);
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

///////////////////// auxiliary functions////////////////////////////
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
	
	// Remove significand's leading 1 bit
	if(a_fp.e != 0){
		a_fp.m &= 0x007FFFFF;
	}
	cout<<"Result: "<<a_fp.s<<"-"<<dec<<a_fp.e<<"-"<<hex<<a_fp.m<<endl;	
	
	// Convert to float
	a_i = (a_fp.s << 31)+((a_fp.e<<23)&0x7F800000)+(a_fp.m&0x007FFFFF);
	a_f = *(float*)&a_i;
	return a_f;
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

void round_norm(fp_t &z, int lostbit_high, int lostbit_low, bool IsUp){
	int LSB;
	
	if(z.e == 0){		// denormals cannot be rounded normally as the exponent cannot be scaled down
		if(z.m > 0x7FFFFF){
			z.e++;
			z.m--;
		}
		return;
	}
	
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
			lostbit_high = extractBits(0,0,z.m);
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
		if(IsUp){
			z.m += 1;
		}else{
			z.m -= 1;
		}
	}
}


///////////////////// arithmetic functions////////////////////////////
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
	
	cout<<"x: "<<dec<<x.s<<"-"<<x.e<<"-"<<hex<<x.m<<endl
		<<"y: "<<dec<<y.s<<"-"<<y.e<<"-"<<hex<<y.m<<endl<<endl;
	
	// decision: add or subtract?
	if(x.m >= y.m){
		if(x.e != 0 | x.m != 0){			// temporary fix to get around -0 + +0 = +0 error
			z.s = x.s;
		}
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
	
	cout<<"x: "<<dec<<x.s<<"-"<<x.e<<"-"<<hex<<x.m<<endl
		<<"y: "<<dec<<y.s<<"-"<<y.e<<"-"<<hex<<y.m<<endl
		<<"z: "<<dec<<z.s<<"-"<<z.e<<"-"<<hex<<z.m<<endl<<endl;

	// add
	z.m += x.m + y.m;
	//cout<<"Significand Sum: "<<hex<<z.m<<endl;
	cout<<"z: "<<dec<<z.s<<"-"<<z.e<<"-"<<hex<<z.m<<endl<<endl;
	
	// Rounding and normalisation
	bool RoundUp = true;
	if ((x.s != y.s)&(!IsSub)){
		RoundUp = false;
	}
	round_norm(z, lostbit_high, lostbit_low, RoundUp);
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
			lostbits = extractBits(0,0,z.m);
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
			lostbits = extractBits(0,0,z.m);
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
		
		y = multiplier(f,y);	round_norm(y,0,0,1);	// calculate new value for denominator
		z = multiplier(f,z);	round_norm(z,0,0,1);	// calculate new value for numerator
		f = adder(two,y,true);
	}
	
	z.s = sign;
	
	// Full number (with significand)
	//cout<<"z: "<<dec<<z.s<<"-"<<z.e<<"-"<<hex<<z.m<<endl<<endl;
	
	return z;
}

fp_t gold2_divider(fp_t x, fp_t y){
	fp_t z;
	
	z.s = 0; z.m = 0; z.e = 0;
	
	// Full number (with significand)
	//cout<<"x: "<<dec<<x.s<<"-"<<x.e<<"-"<<hex<<x.m<<endl
	//	<<"y: "<<dec<<y.s<<"-"<<y.e<<"-"<<hex<<y.m<<endl<<endl;
	
	// Divide by power of 2, base case
	if(y.m == 0x800000){
		z.m = x.m;
		return z;
	}else{
		z.e--;
	}
	
	// Calculate sign
	if(x.s != y.s){
		z.s = 1;
	}

	// New exponent
	z.e = x.e - y.e + 127;
	//cout<<"New exponent: "<<dec<<z.e<<endl;

	// Goldschmidt's Algorithm
	int firstbits = 0;
	long long d = 0, f = 0, n = 0;
	
	d = y.m;
	n = x.m;
	f = 0x1000000 - d; f <<= 1;
	
	cout<<endl<<"f: "<<f<<"	"
		<<"n: "<<n<<"	"
		<<"d: "<<d<<"	"<<endl;
		
	int i = 0;
	while( i < 5 ){
		
		d = d*f*2; d >>= 24;	// calculate new value for denominator
		n = n*f*2; n >>= 24;	// calculate new value for numerator
		f = 0x1000000 - d; f <<= 1;		// calculate "error"
		
		cout<<endl<<"f: "<<f<<"	"
		<<"n: "<<n<<"	"
		<<"d: "<<d<<"	"<<endl;
		
		i++;
	}
	
	z.m = n>>39;
		
	// Full number (with significand)
	cout<<"z: "<<dec<<z.s<<"-"<<z.e<<"-"<<hex<<z.m<<endl<<endl;
	
	return z;
}

fp_t newton_divider(fp_t x, fp_t y){
	fp_t z;
	
	z.s = 0; z.m = 0; z.e = 0;
	
	// Full number (with significand)
	//cout<<"y: "<<dec<<y.s<<"-"<<y.e<<"-"<<hex<<y.m<<endl<<endl;
	
	// Divide by power of 2, base case
	if(y.m == 0x800000){
		z.e = x.e - y.e + 0x7F;
		z.m = x.m;
		return z;
	}
	
	// Calculate sign
	if(x.s != y.s){
		z.s = 1;
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
		z = multiplier(y,x0);	round_norm(z,0,0,1);
		z = adder(two,z,true);
		z = multiplier(z,x0);	round_norm(z,0,0,1);

		i++;

	}
		
	z = multiplier(z,x);	round_norm(z,0,0,1);
	z.s = sign;
	
	// Full number (with significand)
	//cout<<"z: "<<dec<<z.s<<"-"<<z.e<<"-"<<hex<<z.m<<endl<<endl;
	
	return z;
}


fp_t fractioning_rooter(fp_t x){
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

	// Fractioning Method
	
	/* f(0) = 1
	g(0) = 1
	f(i+1) = f(i) + g(i)*S
	g(i+1) = f(i)+g(i)
	
	sqrt(S) = f(x)/g(x)
	*/

	fp_t f,g,h;
	f.s = 0; f.e = 127; f.m = 0x800000;
	g = f;

	int i = 0;
	while( i < 5 ){
		
		h = multiplier(f,g);	round_norm(z,0,0,1);
		z = multiplier(g,x);	round_norm(z,0,0,1);
		f = adder(f,z,false);
		g = h;

		i++;
	}

	z = newton_divider(f,g); 	round_norm(z,0,0,1);
	
	// Full number (with significand)
	cout<<"z: "<<dec<<z.s<<"-"<<z.e<<"-"<<hex<<z.m<<endl<<endl;
	
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

	// initial guess is the root of the highest rootable power of 2 below radicand
	x0.s = 0; x0.e = 127 + x.e; x0.e >>= 1; x0.m = 0x800000;

	int i = 0;
	while( i < 5 ){
	
		z = newton_divider(x,x0);	round_norm(z,0,0,1);
		z = adder(z,x0,false);		round_norm(z,0,0,1);
		z.e--;

		i++;
		
		x0 = z;
	}
	
	// Full number (with significand)
	//cout<<"z: "<<dec<<z.s<<"-"<<z.e<<"-"<<hex<<z.m<<endl<<endl;
	
	return z;
}

fp_t newton_reciprocal_rooter(fp_t x){
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
		z = multiplier(x0,x0);	round_norm(z,0,0,1);
		z = multiplier(x,z);	round_norm(z,0,0,1);
		z = adder(three,z,true);
		z = multiplier(x0,z);	round_norm(z,0,0,1);
		z.e--;

		i++;

	}
	
	// Full number (with significand)
	//cout<<"z: "<<dec<<z.s<<"-"<<z.e<<"-"<<hex<<z.m<<endl<<endl;
	
	return z;
}

fp_t quake_reciprocal_rooter(fp_t x){
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
	quake_const.s = 0; quake_const.e = 190; quake_const.m = 0xB759DF; // Quake constant used to find reciprocal root quickly
	
	halfno = x;
	halfno.e--;
	z = halfno;
	z = adder(quake_const,z,true);	// subtract the fp_t equivalent of 0x5f3759df
	y = z;
	z = multiplier(z,z);		round_norm(z,0,0,1);
	z = multiplier(halfno,z);	round_norm(z,0,0,1);
	z = adder(threehalves,z,true);
	z = multiplier(y,z);		round_norm(z,0,0,1);
	
	// Full number (with significand)
	//cout<<"z: "<<dec<<z.s<<"-"<<z.e<<"-"<<hex<<z.m<<endl<<endl;
	
	return z;
}

fp_t dual_rooter(fp_t x, bool IsReciprocal){
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
		z = multiplier(x0,x0);	round_norm(z,0,0,1);
		z = multiplier(x,z);	round_norm(z,0,0,1);
		z = adder(three,z,true);
		z = multiplier(x0,z);	round_norm(z,0,0,1);
		z.e--;

		i++;

	}
	
	// If we are looking for the normal square root,
	// we multiply the reciprocal root we just calculated
	// by the original number
	if(!IsReciprocal){
		z = multiplier(x,z);	round_norm(z,0,0,1);
	}
	
	// Full number (with significand)
	//cout<<"z: "<<dec<<z.s<<"-"<<z.e<<"-"<<hex<<z.m<<endl<<endl;
	
	return z;
}



void read_in(fp_t &a_fp, fp_t &b_fp){
	string line, reline;
	int size;
	ifstream myfile("input.txt");
	if (myfile.is_open()){
		while (myfile.good()){
			getline (myfile,line);

			a_fp.s = atoi(line.substr(0,1).c_str());
			
			reline = line.substr(1,8);
			for(int i = 0; i<8; i++){
				a_fp.e <<= 1;
				a_fp.e += atoi(reline.substr(i,1).c_str());
			}
			
			reline = line.substr(9,23);
			for(int i = 0; i<23; i++){
				a_fp.m <<= 1;
				a_fp.m += atoi(reline.substr(i,1).c_str());
			}
			
			b_fp.s = atoi(line.substr(33,1).c_str());
			
			reline = line.substr(34,8);
			for(int i = 0; i<8; i++){
				b_fp.e <<= 1;
				b_fp.e += atoi(reline.substr(i,1).c_str());
			}
			
			reline = line.substr(42,23);
			for(int i = 0; i<23; i++){
				b_fp.m <<= 1;
				b_fp.m += atoi(reline.substr(i,1).c_str());
			}
		}
		myfile.close();
	}else{
	cout<<"Unable to open file";
	}

	cout<<endl;
	if(a_fp.e != 0){
		a_fp.m |= 0x00800000;
	}
	if(b_fp.e != 0){
		b_fp.m |= 0x00800000;
	}
}

void output(fp_t &a_fp){
	string line, reline;
	int size;
	ifstream myfile("output.txt");
	if (myfile.is_open()){
		while (myfile.good()){
			getline (myfile,line);

			a_fp.s = atoi(line.substr(0,1).c_str());
			
			reline = line.substr(1,8);
			for(int i = 0; i<8; i++){
				a_fp.e <<= 1;
				a_fp.e += atoi(reline.substr(i,1).c_str());
			}
			
			reline = line.substr(9,23);
			for(int i = 0; i<23; i++){
				a_fp.m <<= 1;
				a_fp.m += atoi(reline.substr(i,1).c_str());
			}
		}
		myfile.close();
	}else{
	cout<<"Unable to open file";
	}
}