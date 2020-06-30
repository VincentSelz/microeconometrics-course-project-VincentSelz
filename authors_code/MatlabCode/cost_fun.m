function [Med_Costs]=cost_fun(e1,parameters,NP,R,V,gamma,MaxEffort,r_it_2,r_i_2,Normal,HetC,CA,Quad,CA_g,Restrictive,Additive)

if (Normal==0 && HetC==1 && CA==0 && Quad==0)
    
    beta=parameters(1);
    c_tt=parameters(2:11);
    A1=parameters(12);
    A2=parameters(13);
    B1=parameters(14);
    B2=parameters(15);
    lambda=parameters(16);
    sigma_lambda=parameters(17);
    weight=1;
    eta=2;
end

if (Normal==0 && HetC==1 && CA==0 && Quad==1)
    
    beta=parameters(1);
    c_tt=parameters(2:11);
    A1=parameters(12);
    A2=parameters(13);
    B1=parameters(14);
    B2=parameters(15);
    lambda=parameters(16);
    sigma_lambda=parameters(17);
    weight=1;
    eta=parameters(18);
end



if (Normal==0 && HetC==1 && CA==1 && Quad==0 && Restrictive==0)
    beta=parameters(1);
    c_tt=parameters(2:11);
    A1=parameters(12);
    A2=parameters(13);
    B1=parameters(14);
    B2=parameters(15);
    lambda=parameters(16);
    sigma_lambda=parameters(17);
    eta=2;
    weight=parameters(18);
    g=CA_g;
end


if (Normal==0 && HetC==1 && CA==1 && Quad==1 & Restrictive==0)
    beta=parameters(1);
    c_tt=parameters(2:11);
    A1=parameters(12);
    A2=parameters(13);
    B1=parameters(14);
    B2=parameters(15);
    lambda=parameters(16);
    sigma_lambda=parameters(17);
    weight=parameters(18);
    eta=parameters(19);
    g=CA_g;
end



if (Normal==1 && HetC==1 && CA==0 && Quad==0)
    beta=parameters(1);
    c_tt=parameters(2:11);
    A1=parameters(12);
    A2=parameters(13);
    lambda=parameters(14);
    sigma_lambda=parameters(15);
    weight=1;
    eta=2;
    g=0;
end


if Restrictive==1
    beta=parameters(1);
    c_tt=parameters(2:11);
    A1=parameters(12);
    lambda=parameters(13);
    sigma_lambda=0;
    weight=1;
    eta=2;
    g=0;
end

if isequal(Normal,0) && isequal(Restrictive,0)
    er1=A1*(-log(r_it_2)).^(1/B1);
    er2=(A2*(-log(r_i_2)).^(1/B2))*ones(1,R);
end

if isequal(Normal,1) && isequal(Restrictive,0)
    er1=A1*norminv(r_it_2);
    er2=(A2*norminv(r_i_2))*ones(1,R);
end

if isequal(Restrictive,1)
    er1=A1*norminv(r_it_2);
    er2=zeros(NP,R);
end

if isequal(HetC,1) && isequal(Additive,0)
    C=(ones(NP,10)*c_tt(1)+ones(NP,1)*[0 c_tt(2:10)']+er1+er2);
    C=max(C,0.0001);

    
else
    if isequal(Additive,0)
        C=(ones(NP,10)*c_tt(1));
        C=max(C,0.0001);

    else
        C=(ones(NP,10)*c_tt(1)+ones(NP,1)*[0 c_tt(2:10)']);
        C=max(C,0.0001);

    end
    
end



%C=(ones(NP,10)*c_tt(1)+ones(NP,1)*[0,c_tt(2:10)']+er1+er2);

beta2_r=reshape(beta*ones(NP,R),[],1);



for e2=0:48
    Med_Costs(e2+1,1)=prctile(beta*ones(NP,1)*e2/50+25*(1/eta)*C(:,1)*(e2/50)^eta,5);
    Med_Costs(e2+1,2)=prctile(beta*ones(NP,1)*e2/50+25*(1/eta)*C(:,1)*(e2/50)^eta,50);
    Med_Costs(e2+1,3)=prctile(beta*ones(NP,1)*e2/50+25*(1/eta)*C(:,1)*(e2/50)^eta,95);
end



