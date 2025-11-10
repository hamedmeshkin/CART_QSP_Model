#include <R.h>
#include <Rinternals.h>
#include <Rdefines.h>
#include <R_ext/Rdynload.h>
#include <time.h>
static double parms[25];
#define eta parms[0]
#define kappa parms[1]
#define eps parms[2]
#define theta parms[3]
#define muI parms[4]
#define muE parms[5]
#define muP parms[6]
#define A parms[7]
#define B parms[8]
#define rho parms[9]
#define K parms[10]
#define gamma parms[11]
#define g0 parms[12]
#define sigmaM parms[13]
#define deltaM parms[14]
#define deltaI parms[15]
#define sigmaI parms[16]
#define alpha parms[17]
#define betaB parms[18]
#define betaK parms[19]
#define betaC parms[20]
#define C_CD40 parms[21]
#define TN_switch parms[22]
#define timeout parms[23]
#define starttime parms[24]

void lagvalue(double *T, int *nr, int N, double *yout) {
	static void(*fun)(double*, int*, int, double*) = NULL;
	if(fun==NULL)
	fun =  (void(*)(double*, int*, int, double*))R_GetCCallable("deSolve", "lagvalue");
	return fun(T, nr, N, yout);
}
void lagderiv(double *T, int *nr, int N, double *yout) {
	static void(*fun)(double*, int*, int, double*) = NULL;
	if (fun == NULL)
	fun =  (void(*)(double*, int*, int, double*))R_GetCCallable("deSolve", "lagvalue");
	return fun(T, nr, N, yout);
}

void initmod(void (* odeparms)(int *, double *)){
	int N=25;
	odeparms(&N, parms);}
	
	void derivs (int *neq, double *t, double *y, double *ydot, double *yout, int *ip){
	if (ip[0] < 0 ) error("nout not enough!");
	time_t s = time(NULL);
	if((int) s - (int) starttime > timeout) error("timeout!");
	int CI_s = 0;
	int CE_s = 1;
	int CP_s = 2;
	int TP_s = 3;
	int TN_s = 4;
	int Mi_s = 5;
	int Ma_s = 6;
	int IL6_s = 7;
	double TT;
	
	double F_TP = y[TP_s] / (A + y[TP_s]);
	//# Macrophage activation rate h(·) (Eq. 11)
	double h_rate = betaB * (y[TP_s] / (A + y[TP_s])) * y[CE_s] +  betaK * (y[CE_s] / (B + y[CE_s])) * (y[TP_s] + g0 * y[TN_s]) +  betaC * (y[Ma_s] / (C_CD40 + y[Ma_s])) * y[CE_s];
	
	//# ---- CAR-T phenotypes (Eqs. 1–3) ----
	ydot[CI_s] = -eta * F_TP * y[CI_s] - muI * y[CI_s];
	ydot[CE_s] =  eta * F_TP * y[CI_s] +   kappa * F_TP * y[CE_s] -   eps * (1 - F_TP) * y[CE_s] +   theta * F_TP * y[CP_s] -   muE * y[CE_s];
	ydot[CP_s] =  eps * (1 - F_TP) * y[CE_s] -   theta * F_TP * y[CP_s] -   muP * y[CP_s];
	
	//# ---- Tumor cells ----
	if (TN_switch == 0) {
	//  # Base y[3]-only tumor (Eq. 4)
	  ydot[TP_s] = rho * y[TP_s] * (1 - y[TP_s] / K) - gamma * (y[CE_s] / (B + y[CE_s])) * y[TP_s];
	  ydot[TN_s] = 0;
	  TT = y[TP_s];
	} else {
	//  # Antigen-positive/negative (Eqs. 6–7)
	  ydot[TP_s] = rho * y[TP_s] * (1 - (y[TP_s] + y[TN_s]) / K) - gamma * (y[CE_s] / (B + y[CE_s])) * y[TP_s];
	  ydot[TN_s] = rho * y[TN_s] * (1 - (y[TP_s] + y[TN_s]) / K) - g0 * gamma * (y[CE_s] / (B + y[CE_s])) * y[TN_s];
	  TT = y[TP_s] + y[TN_s];
	}
	
	//# ---- Macrophages & IL-6 (Eqs. 8–10) ----
	ydot[Mi_s]  = sigmaM - h_rate * y[Mi_s] - deltaM * y[Mi_s];
	ydot[Ma_s]  = h_rate * y[Mi_s] - deltaM * y[Ma_s];
	ydot[IL6_s] = sigmaI + alpha * y[Ma_s] - deltaI * y[IL6_s];
	yout[0] = y[CI_s] + y[CE_s] + y[CP_s]; 
	yout[1] = TT;
	
}
 
