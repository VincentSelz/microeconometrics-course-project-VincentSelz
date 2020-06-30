function [br2]=BR2_60_regret(e1,gamma,v,B,lambda,C,NP_s,eta,weight,g,rho)

rho=rho*ones(NP_s,49);

% Optional effort if win with Effort=j
E2=(0:1:48)';
CE=(E2/50)*B'+25*(1/eta)*(E2/50).^eta*C';

% Pre Allocate memory
EU_win=zeros(NP_s,49);
EU_lose=zeros(NP_s,49);

CEi=CE';

%loop over 2nd mover effort choices
for j=0:48
    
    P2=(ones(NP_s,1)*E2'-e1*ones(1,49)+gamma)./(j-e1*ones(1,49)+gamma);
    P2=min(P2,1);
    
    EU=P2.*(v*ones(1,49))-CEi;
    
    ii=EU==(max(EU')'*ones(1,49));
    EU(ii)=-10000;
    ii=EU==(max(EU')'*ones(1,49));
    EU_win(:,j+1)=sum(EU.*ii,2);
    
    
    P2=(ones(NP_s,1)*E2'-j)./(gamma-j+e1*ones(1,49));
    P2=max(P2,0);
    
    EU=P2.*(v*ones(1,49))-CEi;
    
    ii=EU==(max(EU')'*ones(1,49));
    EU(ii)=-10000;
    ii=EU==(max(EU')'*ones(1,49));
    EU_lose(:,j+1)=sum(EU.*ii,2);
end



% Ex ante expected utility including regret
CE=(E2/50)*B'+25*(1/eta)*(E2/50).^eta*C';
CE=CE';
CE=CE(1:NP_s,:);
P2=(ones(NP_s,1)*E2'-e1(1:NP_s)*ones(1,49)+gamma)/(2*gamma);

EU=P2.*(v(1:NP_s)*ones(1,49))-CE-(lambda*ones(1,49)).*(v(1:NP_s)*ones(1,49)).*P2.*(1-P2);
% EU=P2.*(v(1:NP_s)*ones(1,49))-CE;

U_win=(v(1:NP_s)*ones(1,49))-CE;
U_lose=-CE;

Reg_win=(sign(U_win-EU_win)==-1).*(U_win-EU_win);
Reg_lose=(sign(U_lose-EU_lose)==-1).*(U_lose-EU_lose);
EU_reg=EU+rho.*P2.*Reg_win+rho.*(1-P2).*Reg_lose;


choice=ones(NP_s,1)*(0:1:48);
ii=EU_reg==max(EU_reg')'*ones(1,49);
Choice=sum(choice.*ii,2);
br2=Choice;

