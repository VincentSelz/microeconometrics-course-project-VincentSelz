function [beta_opt,betac,fopt,fc,nacp]=...
    v_sa(fcn,beta_opt,betac,fopt,fc,User,lb,ub,t,vm,nacp,sz)


for r=1:5
    for h=1:sz
        
        xp=betac;
        
        rand('state',sum(1e6*clock));
        xp(h)=xp(h)+(rand(1,1).*2-1)*vm(h);
        
        while ((xp(h)>ub(h)) || (xp(h)<lb(h)))
            xp(h)=lb(h)+(ub(h)-lb(h))*rand(1,1);
        end
        fp=msm_60(1,xp,User);
        
        if fp<fc
            betac=xp;
            fc=fp;
            nacp(h)=nacp(h)+1;
        end
        
        if fp<fopt
            fopt=fp
            beta_opt=xp
        end
        
        if fp>fc
            p=exp((fc-fp)/t);
            rand('state',sum(1e6*clock));
            pp=rand(1,1);
            if pp<p
                fc=fp
                betac=xp;
                nacp(h)=nacp(h)+1;
            end
        end
    end
end
