#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <cmath>

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
void round_norm(fp_t &z);
fp_t adder(fp_t, fp_t, bool);	//takes in 32-bit floating point numbers and return sum
fp_t multiplier(fp_t, fp_t);
float fma(float, float, float);
fp_t good_ol_adder(fp_t x, fp_t y, bool IsSub);

//////////////////////main function//////////////////////////
int main(){
	float a, b, c, d, e, f;
	fp_t a_fp, b_fp, c_fp, d_fp, e_fp, f_fp;
	float z;
	fp_t z_fp;
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
				z_fp = multiplier(a_fp,b_fp);
				z = footer(z_fp);
				cout<<a<<"*"<<b<<"="<<z; break;
		
		case 2: cout << "Input two numbers to be added" << endl;
				cin>>a; a_fp = header(a);
				cin>>b;	b_fp = header(b);		
				z_fp = adder(a_fp,b_fp, false);
				z = footer(z_fp);
				cout<<a<<"+"<<b<<"="<<z; break;
		
		case 3: cout << "Input two numbers to be subtracted" << endl;
				cin>>a; a_fp = header(a);
				cin>>b;	b_fp = header(b);		
				z_fp = adder(a_fp,b_fp, true);
				z = footer(z_fp);
				cout<<a<<"-"<<b<<"="<<z; break;
		
		case 4: cout << "Input three numbers to be MACed" << endl;
				cin>>a; cin>>b; cin>>c;
				//z = (a*b)+c;
				// z = multiplier(a,b);
				// z = adder(z,c, false);
				z = fma(a,b,c);
				cout<<"("<<a<<"*"<<b<<")+"<<c<<"="<<z; break;
		
		case 5: cout << "Input two numbers to be divided" << endl;
				cin>>a; cin>>b;
				z = a/b;
				cout<<a<<"/"<<b<<"="<<z; break;

		case 6: cout << "Input two 2-vectors to be dotted" << endl;
				cin>>a; cin>>b; cin>>c; cin>>d;
				z = (a*c)+(b*d);
				// y = multiplier(a,c);
				// z = multiplier(b,d);
				// z = adder(y,z, false);
				cout<<"("<<a<<","<<b<<").("<<c<<","<<d<<")="<<z; break;

		case 7: cout << "Input two 3-vectors to be dotted" << endl;
				cin>>a; cin>>b; cin>>c; cin>>d; cin>>e; cin>>f;
				z = (a*d)+(b*e)+(c*f);
				// x = multiplier(a,d);
				// y = multiplier(b,e);
				// z = multiplier(c,f);
				// z = adder(y,z, false);
				// z = adder(x,z, false);
				cout<<"("<<a<<","<<b<<","<<c<<").("<<d<<","<<e<<","<<f<<")="<<z; break;

		case 8: cout << "Input number to be square-rooted" << endl;
				cin>>a;
				z = sqrt(a);
				cout<<a<<"^0.5"<<"="<<z; break;

		case 9: cout << "Input number to be inverse square-rooted" << endl;
				cin>>a;
				z = 1/(sqrt(a));
				cout<<a<<"^-0.5"<<"="<<z; break;

		case 10: cout << "Input two points for the Euclidean distance" << endl;
				cin>>a; cin>>b;
				z = sqrt((a*a) + (b*b));
				cout<<"|"<<a<<","<<b<<"|="<<z; break;

		case 11: cout << "Input three points for the Euclidean distance" << endl;
				cin>>a; cin>>b; cin>>c;
				z = sqrt((a*a) + (b*b) + (c*c));
				cout<<"|"<<a<<","<<b<<","<<c<<"|="<<z; break;

		case 12: cout << "Input 3-vector to be normalised" << endl;
				cin>>a; cin>>b; cin>>c;
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
		int lza = 25;
		int found = 0;
		int err;
		while(!found){
			err = extractBits(lza,lza,a_fp.m);
			//cout<<"lza: "<<dec<<lza<<endl;
			//cout<<"err: "<<dec<<err<<endl;
			if(err == 1){
				found = 1;
			}else{
				lza--;
			}
		}
		
		lza = lza - 23;
		a_fp.m >>= lza;
		a_fp.e += lza;
	}
	
	// Remove significand's leading 1 bit
	a_fp.m &= 0x007FFFFF;
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

void round_norm(fp_t &z){
// Rounding and normalisation
	if(z.m != 0){
		int lza = 25;
		int found = 0;
		int err;
		while(!found){
			err = extractBits(lza,lza,z.m);
			//cout<<"lza: "<<dec<<lza<<endl;
			//cout<<"err: "<<dec<<err<<endl;
			if(err == 1){
				found = 1;
			}else{
				lza--;
			}
		}
		
		lza = lza - 23;
		z.m >>= lza;
		z.e += lza;
	}
}

fp_t adder(fp_t x, fp_t y, bool IsSub){
	fp_t z, w;
	int i = 0;
	
	z.s = 0; z.m = 0; z.e = 0;

	// Full numbers (with significands)
	//cout<<"x: "<<dec<<x.s<<"-"<<x.e<<"-"<<hex<<x.m<<endl
	//	<<"y: "<<dec<<y.s<<"-"<<y.e<<"-"<<hex<<y.m<<endl<<endl;
	
	// Put the bigger number in x
	if((x.e < y.e)|((x.e == y.e)&(x.m < y.m))){
		w = x;
		x = y;
		y = w;
	}	
	
	// Difference of exponents
	int d;
	d = x.e-y.e;
	//cout<<"Difference of exponents: "<<dec<<d<<endl;
	
	// Align significands
	for(i = 0; i<d; i++){
		y.m >>= 1;
	}
	z.e = x.e;

	// decision: add or subtract?
	z.s = x.s;
	if ((x.s == 1)^(y.s == 1)^IsSub){
		y.m = ~y.m;
		z.m = 1;
	}

	//cout<<dec<<x.s<<"-"<<z.e<<"-"<<hex<<x.m<<endl
	//	<<dec<<y.s<<"-"<<z.e<<"-"<<hex<<y.m<<endl
	//	<<dec<<z.s<<"-"<<z.e<<"-"<<hex<<z.m<<endl;
	
	// add
	z.m += x.m + y.m;
	//cout<<"Significand Sum: "<<hex<<z.m<<endl;
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
		z.e = x.e + y.e - 127;
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
	int round = 0; int lostbits = 0;
	for(int i = 0; i<=11; i++){
		beys = extractBits(2*i,(2*i)+2,y.m);
		//cout<<dec<<2*i<<" to "<<(2*i)+2<<" is "<<hex<<beys<<endl;
		//cout<<hex<<z.m<<"	";
		if(round == 0){
			lostbits = extractBits(0,1,z.m);
			if(lostbits != 0){
				round = 1;
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
		if(round == 0){
			lostbits = extractBits(0,1,z.m);
			if(lostbits != 0){
				round = 1;
			}
		}
		z.m = z.m>>2;
		z.m += x.m; // this takes account of the leading 1
	}
	
	z.m <<= 1;
	
	return z;
}

float fma(float a_f, float b_f, float c_f){
	fp_t x, y, z;
	float d_f;
	
	//unpack
	x = unpack_f(a_f);
	y = unpack_f(b_f);
	z.s = 0; z.m = 0; z.e = 0;
	
	// Calculate sign
	if(x.s != y.s){
		z.s = 1;
	}

	cout<<endl;
	cout<<a_f<<": "<<dec<<x.s<<"-"<<x.e<<"-"<<hex<<x.m<<endl
		<<b_f<<": "<<dec<<y.s<<"-"<<y.e<<"-"<<hex<<y.m<<endl<<endl;

	//Create significand
	x.m |= 0x00800000;
	y.m |= 0x00800000;

	//cout<<a_f<<": "<<dec<<x.s<<"-"<<x.e<<"-"<<hex<<x.m<<endl
	//	<<b_f<<": "<<dec<<y.s<<"-"<<y.e<<"-"<<hex<<y.m<<endl<<endl;

	//calculate new exponent
	z.e = x.e + y.e - 127;

	//cout<<"New exponent: "<<dec<<z.e<<endl;

	//Booth encode
	int beys; // booth encoded y.m segment
	y.m = y.m<<1;

	int negxm = ~x.m;
	negxm++;
	int twoxm = x.m<<1;
	int negtwoxm = negxm<<1;	
	
	//cout<<hex<<"x: "<<x.m<<endl
	//	<<"-x: "<<negxm<<endl
	//	<<"2x: "<<twoxm<<endl
	//	<<"-2x: "<<negtwoxm<<endl<<endl;

	for(int i = 0; i<=11; i++){
		beys = extractBits(2*i,(2*i)+2,y.m);
		//cout<<dec<<2*i<<" to "<<(2*i)+2<<" is "<<hex<<beys<<endl;
		//cout<<hex<<z.m<<"	";
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

	z.m = z.m>>2;
	z.m += x.m; // this takes account of the leading 1

	//Rounding and normalisation
	int err = extractBits(23,31,z.m);
	z.m = z.m<<1;
	z.m = z.m>>err;
	z.e += err;
	//cout<<z.m<<endl;

	//unpack
	x = z;
	y = unpack_f(c_f);
	z.s = 0; z.m = 0; z.e = 0;

	//Create significand
	y.m |= 0x00800000;

	//difference of exponents
	int d;
	d = x.e-y.e;

	//cout<<"Difference in exponents: "<<dec<<d<<endl;
	
	//align significand
	if(d>0){
		y.m >>= d;
		z.e = x.e;
	}	
	else if(d<0){
		x.m >>= -d;
		z.e = y.e;
	}
	else z.e = x.e;

	//cout<<dec<<x.s<<"-"<<z.e<<"-"<<hex<<x.m<<endl
	//	<<dec<<y.s<<"-"<<z.e<<"-"<<hex<<y.m<<endl<<endl;

	
	//decision: add or subtract?
	if(x.m > y.m){
		z.s = x.s;
		if ((x.s == 1)^(y.s == 1)){
			y.m = ~y.m;
			z.m = 1;
		}
	}else if(x.m < y.m){
		z.s = y.s;
		if ((x.s == 1)^(y.s == 1)){
			x.m = ~x.m;
			z.m = 1;
		}
	}

	//cout<<dec<<x.s<<"-"<<z.e<<"-"<<hex<<x.m<<endl
	//	<<dec<<y.s<<"-"<<z.e<<"-"<<hex<<y.m<<endl
	//	<<dec<<z.s<<"-"<<z.e<<"-"<<hex<<z.m<<endl;
	
	// add
	z.m += x.m + y.m;
	//cout<<"Significand Sum: "<<hex<<z.m<<endl;

	//Rounding and normalisation
	err = extractBits(24,31,z.m);
	z.m = z.m>>err;
	z.e += err;
	//cout<<z.m<<endl;

	//Turn significand into mantissa
	z.m &= 0x7FFFFF;
	cout<<"Result: "<<z.s<<"-"<<dec<<z.e<<"-"<<hex<<z.m<<endl;

	d_f = pack_f(z);
	//cout<<dec<<c_f<<endl<<endl;
	
	return d_f;

}

float reciprocal(float b_f){
	fp_t x, y, z;
	float c_f;
	
	//unpack
	y = unpack_f(b_f);
	z.s = 0; z.m = 0; z.e = 0;
	
	// Calculate sign
	z.s = y.s;

	cout<<endl;
	cout<<b_f<<": "<<dec<<y.s<<"-"<<y.e<<"-"<<hex<<y.m<<endl<<endl;

	//Create significand
	y.m |= 0x00800000;

	//calculate new exponent
	//z.e = x.e + y.e - 127; <-------------- ????????????????????????????????????????????

	// Reciprocate
	int x0 = 0.0000001;


	int beys; // booth encoded y.m segment
	y.m = y.m<<1;

	int negxm = ~x.m;
	negxm++;
	int twoxm = x.m<<1;
	int negtwoxm = negxm<<1;	
	
	//cout<<hex<<"x: "<<x.m<<endl
	//	<<"-x: "<<negxm<<endl
	//	<<"2x: "<<twoxm<<endl
	//	<<"-2x: "<<negtwoxm<<endl<<endl;

	for(int i = 0; i<=11; i++){
		beys = extractBits(2*i,(2*i)+2,y.m);
		//cout<<dec<<2*i<<" to "<<(2*i)+2<<" is "<<hex<<beys<<endl;
		//cout<<hex<<z.m<<"	";
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

	z.m = z.m>>2;
	z.m += x.m; // this takes account of the leading 1

	//Rounding and normalisation
	int err = extractBits(23,31,z.m);
	z.m = z.m<<1;
	z.m = z.m>>err;
	z.e += err;
	//cout<<z.m<<endl;

	z.m &= 0x7FFFFF;
	cout<<"Result: "<<z.s<<"-"<<dec<<z.e<<"-"<<hex<<z.m<<endl;

	c_f = pack_f(z);
	//cout<<dec<<c_f<<endl<<endl;
	
	return c_f;

}