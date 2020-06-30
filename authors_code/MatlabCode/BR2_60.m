function [br2]=BR2_60(e1,gamma,v,B,lambda,C,NP_s,eta,weight,g)

e2_bar=25;

E2=(0:1:48)';

CE=(E2/50)*B'+25*(1/eta)*(E2/50).^eta*C';

P2=(E2*ones(1,NP_s)-ones(49,1)*e1'+gamma)/(2*gamma);

P2bar=(e2_bar.*ones(49,NP_s)*(1-weight)+weight*E2*ones(1,NP_s)-ones(49,1)*e1'+gamma)/(2*gamma);

[sz1 sz2]=size(lambda);

G=g*ones(sz1,sz2);
L=lambda+G;

V2bar=P2.*((ones(49,1)*(v'+G'.*v')))+P2.*P2bar.*(ones(49,1)*(lambda'.*v'))-P2bar.*((ones(49,1)*(L'.*v')))-CE;

V2=V2bar;

choice=(0:1:48)'*ones(1,NP_s);

ii=V2==(ones(49,1)*max(V2));
Choice=sum(choice.*ii);
br2=Choice;

