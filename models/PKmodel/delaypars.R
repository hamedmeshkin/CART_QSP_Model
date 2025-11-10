pars <- c(
  # CAR-T transition & death rates (Eqs. 1–3)
  eta   = NA_real_,  # activation of CI -> CE            
  kappa = NA_real_,  # CE proliferation                   
  eps   = 0.02,  # CE -> CP                               
      theta = 1e-8,  # CP -> CE reactivation                  
  muI   = NA_real_,  # CI loss                             
  muE   = NA_real_,  # CE loss/exhaustion                  
  muP   = NA_real_,  # CP slow loss                        
  
  # Antigen binding & CE killing saturation (Eqs. 4–5)
  A     = NA_real_,  # half-saturation for F(TP)           
  B     = NA_real_,  # CE killing saturation               
  
  # Tumor growth & killing (Eqs. 4, 6–7)
  rho   = NA_real_,  # logistic growth rate                
        K     = 4.25e12,  # carrying capacity                   
  gamma = NA_real_,  # CE cytotoxic rate                   
  g0    = NA_real_,       # reduced killing vs TN (0<g0<<1)      if include_TN
  
  # Macrophages & IL-6 (Eqs. 8–11)
  sigmaM   = 0.0,  # naive macrophage production      
  deltaM   = 0.0,  # macrophage death                 
  deltaI   = 0.0,  # IL-6 decay    
  sigmaI   = 0.0,  # deltaI * IL6min,  # endogenous IL-6  
  alpha    = 0.0,  # IL-6 release per Ma              
  
  # h(·) components (Eq. 11)
  betaB    = 0.0,  # antigen-binding mediated         
  betaK    = 0.0,  # DAMPs via killing                
  betaC    = 0.0,  # CD40–CD40L contact               
        C_CD40   = 1e10,       # saturation for Ma in contact    
  # switches
  TN_switch = NA_real_,  # set TRUE to use Eqs. (6)–(7)
  timeout=3000,starttime=0
)

 