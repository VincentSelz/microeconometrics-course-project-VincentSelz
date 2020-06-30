function [f,User,M_sim]=msm_60(parameters,User)
E1o=User.E1o;
E2o=User.E2o;
NP=User.NP;
R=User.R;
V=User.V;
gamma=User.gamma;
MaxEffort=User.MaxEffort;
omega=User.omega;
K=User.K;
r_it_2=User.r_it_2;
M_obs=User.M_obs;
r_i_2=User.r_i_2;
sim=User.sim;
Normal=User.Normal;
r_sigma_lambda=User.r_sigma_lambda;
HetC=User.HetC;
CA=User.CA;
CA_g=User.CA_g;
Quad=User.Quad;
Restrictive=User.Restrictive;
Additive=User.Additive;
Regret=User.Regret;

M_sim=moments(parameters,E1o,E2o,NP,R,V,gamma,MaxEffort,K,r_it_2,sim,r_i_2,Normal,r_sigma_lambda,HetC,CA,Quad,CA_g,Restrictive,Additive,Regret);

M=(M_sim-M_obs).*User.MS';

omega_scalled=(1./User.MS*ones(1,38)).*omega.*(1./User.MS*ones(1,38))';

f=M*omega_scalled*M';

