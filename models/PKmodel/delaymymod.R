carT_ode <- function(t, state, pars) {
  with(as.list(c(state, pars)), {
    # Antigen-receptor binding (Eq. 5)
	F_TP = TP / (A + TP);
	TN_eff <- if (TN_switch == 0) 0 else TN
	# Macrophage activation rate h(·) (Eq. 11)
	h_rate = betaB * (TP / (A + TP)) * CE +  betaK * (CE / (B + CE)) * (TP + g0 * TN_eff) +  betaC * (Ma / (C_CD40 + Ma)) * CE;
	
	# ---- CAR-T phenotypes (Eqs. 1–3) ----
	dCI = -eta * F_TP * CI - muI * CI;
	dCE =  eta * F_TP * CI +   kappa * F_TP * CE -   eps * (1 - F_TP) * CE +   theta * F_TP * CP -   muE * CE;
	dCP =  eps * (1 - F_TP) * CE -   theta * F_TP * CP -   muP * CP;
	
	# ---- Tumor cells ----
	if (TN_switch == 0) {
	# Base y[3]-only tumor (Eq. 4)
		dTP = rho * TP * (1 - TP / K) - gamma * (CE / (B + CE)) * TP;
	    dTN = 0;
	    TT = TP;
	} else {
	# Antigen-positive/negative (Eqs. 6–7)
		dTP = rho * TP * (1 - (TP + TN) / K) - gamma * (CE / (B + CE)) * TP;
	    dTN = rho * TN * (1 - (TP + TN) / K) - g0 * gamma * (CE / (B + CE)) * TN;
	    TT = TP + TN;
	}
	
	# ---- Macrophages & IL-6 (Eqs. 8–10) ----
	dMi  = sigmaM - h_rate * Mi - deltaM * Mi;
	dMa  = h_rate * Mi - deltaM * Ma;
	dIL6 = sigmaI + alpha * Ma - deltaI * IL6;
	
	# Derived outputs
	CT = CI + CE + CP; 
	T_pop = TT;
	
	list(
		c(dCI, dCE, dCP, dTP, dTN, dMi, dMa, dIL6), 
	    c(CT = CT, T_pop = T_pop)
	)
  })
}


 
	
