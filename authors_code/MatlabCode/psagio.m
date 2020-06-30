% sagio.m   -   5.7.99t

% this file is the sim ann function from goffe.
% (It includes the correction mentioned
% in previous notes the Matlab version).



function [xopt,fopt,nacc,nfcnev,nobds,ier,t,vm] ...
    =psagio(fcn,x,Max,rt,eps,ns,nt,neps,Maxevl,lb,ub,c,iprint,seed,t,vm)



% Initialize the random number generator.
RandStream.setDefaultStream(RandStream('mt19937ar','seed',100000*sum(clock)));




%  Define number of parameters.
n=length(x);

%  Set initial values.
nacc=0;
nobds=0;
nfcnev=0;
fp=[];
ier=99;
xopt=x;
nacp=zeros(n,1);
fstar=realMax.*ones(neps,1);
xp=x;

%  If the initial temperature is not positive, notify the user and abort.
if t<=0
    prt11;
    ier=3;
    return;
end

%  If the initial value is out of bounds, notify the user and abort.
if (any(x>ub) | any(x<lb))
    prt1;
    ier=2;
    return;
end

%  Evaluate the function with input x and return value as f.
f=feval(fcn,x);

% Initialize the random number generator.


%  If the function is to be minimized, switch the sign of the function.
%  Note that all intermediate and final output switches the sign back
%  to eliminate any possible confusion for the user.
if not(Max)
    f=-f;
end
nfcnev=nfcnev+1;
fopt=f;
if iprint>1
    prt2(Max,x,f);
end

%  Start the main loop. Note that it terminates if (i) the algorithm
%  succesfully optimizes the function or (ii) there are too many
%  function evaluations (more than MAXEVL).


Fopt=fopt*ones(1,4);
Xopt=xopt*ones(1,4);
X=xopt*ones(1,4);
Nacp=nacp*ones(1,4);
F=fopt*ones(1,4);

quit=0;
while not(quit)

    nup=0;
    nrej=0;
    nnew=0;
    ndown=0;
    lnobds=0;

    for m=1:nt
        for j=1:ns
            %loop over processors
            fopti=max(Fopt);
            R=rand(n,4);
            P=rand(n,4);
            tic
            parfor pr=1:4
                fopt=Fopt(pr);
                xopt=Xopt(:,pr);
                x=X(:,pr);
                nacp=Nacp(:,pr);
                f=F(pr);
                r=R(:,pr);
                pd=P(:,pr);
                
                for h=1:n

                    %  Generate xp, the trial value of x.
                    xp=x;
                    
                    LB=max(lb(h),x(h)-vm(h)/2);
                    UB=min(ub(h),x(h)+vm(h)/2);
                    xp(h)=LB+(UB-LB)*r(h);

                    %  Evaluate the function with the trial point xp and return as fp.
                    fp=feval(fcn,xp);
                    if not(Max)
                        fp=-fp;
                    end

                    %  Accept the new point if the function value increases.
                    if fp>=f
                        if iprint>=3
                            prt12;
                        end
                        x=xp;
                        f=fp;
                        nacc=nacc+1;
                        nacp(h)=nacp(h)+1;
                        nup=nup+1;

                        %  If greater than any other point, record as new optimum.
                        if fp>fopt
                            count=0;
                            xopt=xp;
                            fopt=fp;
                            nnew=nnew+1;
                        end

                        %  If the point is lower, use the Metropolis criteria to decide on
                        %  acceptance or rejection.
                    else
                        p=exp((fp-f)/t);
                        pp=pd(h);
                        if pp<p
                            x=xp;
                            f=fp;
                            nacc=nacc+1;
                            nacp(h)=nacp(h)+1;
                            ndown=ndown+1;
                        else
                            nrej=nrej+1;
                        end
                    end

                end % of for h=1:n (loop over paramerers)
                
                Fopt(pr)=fopt;
                Xopt(:,pr)=xopt;
                X(:,pr)=x;
                Nacp(:,pr)=nacp;
                F(pr)=f;

            end % end loop over processors    
            toc

            % choose best position from 4 processors if a new optimum
            if max(Fopt)>fopti
                if isequal(Fopt(1),max(Fopt))
                    fopt=Fopt(1);
                    xopt=Xopt(:,1);
                    x=X(:,1);
                    nacp=Nacp(:,1);
                    f=F(1);
                end
                
                if isequal(Fopt(2),max(Fopt))
                    fopt=Fopt(2);
                    xopt=Xopt(:,2);
                    x=X(:,2);
                    nacp=Nacp(:,2);
                    f=F(2);
                end
                if isequal(Fopt(3),max(Fopt))
                    fopt=Fopt(3);
                    xopt=Xopt(:,3);
                    x=X(:,3);
                    nacp=Nacp(:,3);
                    f=F(3);

                end
                if isequal(Fopt(4),max(Fopt))
                    fopt=Fopt(4);
                    xopt=Xopt(:,4);
                    x=X(:,4);
                    nacp=Nacp(:,4);
                    f=F(4);
                end
                Fopt=fopt*ones(1,4);
                Xopt=xopt*ones(1,4);
                x=Xopt;
                f=Fopt;
                Nacp=nacp*ones(1,4);
                
                save('xopt','xopt')
                save('fopt','fopt')
                save('vm','vm')
                save('t','t')
                
                xopt
                fopt
                
            end

            nfcnev=nfcnev+n;
            
            %  If too many function evaluations occur, terminate the algorithm.
                    if nfcnev>=Maxevl
                        prt5;
                        if not(Max)
                            fopt=-fopt;
                        end
                        ier=1;
                        return;
                    end

        end % of while j=1:ns (loop over evaluations at current step length)


        %  Adjust vm so that approximately half of all evaluations are accepted.
        %  (for each component of x, if more than 60% of all evaluations yield
        %  new optima, then vm will be widened, to broaden the search; likewise,
        %  if less than 40% of all evals yield new optima, then vm is also widened)

        %average number of acceptances
        
        m_nact=mean(Nacp,2);
        for i=1:n
            ratio=m_nact(i)/ns;
            if ratio>0.6
                vm(i)=vm(i).*(1+c(i).*(ratio-0.6)./0.4);
            elseif ratio<0.4
                vm(i)=vm(i)./(1+c(i).*(0.4-ratio)./0.4);
            end
            if vm(i)>(ub(i)-lb(i))
                vm(i)=ub(i)-lb(i);
            end
        end

        nacp=zeros(n,1);
        Nacp=nacp*ones(1,4);

    end % of for m=1:nt (loop over evaluations at the current temperature)

    % select best point at current temperature
    if isequal(Fopt(1),max(Fopt))
        fopt=Fopt(1);
        xopt=Xopt(:,1);
        x=X(:,1);
        nacp=Nacp(:,1);
        f=F(1);
    end

    if isequal(Fopt(2),max(Fopt))
        fopt=Fopt(2);
        xopt=Xopt(:,2);
        x=X(:,2);
        nacp=Nacp(:,2);
        f=F(2);
    end
    if isequal(Fopt(3),max(Fopt))
        fopt=Fopt(3);
        xopt=Xopt(:,3);
        x=X(:,3);
        nacp=Nacp(:,3);
        f=F(3);

    end
    if isequal(Fopt(4),max(Fopt))
        fopt=Fopt(4);
        xopt=Xopt(:,4);
        x=X(:,4);
        nacp=Nacp(:,4);
        f=F(4);
    end

    if (iprint>=1||iprint==-5)
        prt9(Max,t,xopt,vm,fopt,nup,ndown,nrej,lnobds,nnew);
    end
    
    %  Check termination criteria.
    fstar(1)=f;
    if (fopt-fstar(1))<=eps % quit if current f (fstar) not too much lower than fopt.
        quit=1;
    end
    if any(abs(f-fstar)>eps) % but unquit is any of the neps most recent fs are more than ops away from current f
        quit=0;
    end

    %  If termination criteria are not met, prepare for another loop.
    if not(quit)
        t=rt*t;

        fstar(2:neps)=fstar(1:neps-1);
        f=fopt; % resent f to the optimal f
        x=xopt; % reset x to the optimal x
    end
    Fopt=fopt*ones(1,4);
    Xopt=xopt*ones(1,4);
    x=Xopt;
    f=Fopt;
    Nacp=nacp*ones(1,4);

    save('vm','vm')
    save('t','t')
    

end % of while not(quit)

%  Terminate SA if appropriate.
x=xopt;
ier=0;
if not(Max)
    fopt=-fopt;
end
if iprint>=1
    prt10;
end

% End of function

% ******************************************************************

function prt1;

%  This subroutine prints intermediate output, as does PRT2 through
%  PRT10. Note that if SA is minimizing the function, the sign of the
%  function value and the directions (up/down) are reversed in all
%  output to correspond with the actual function optimization. This
%  correction is because SA was written to Maximize functions and
%  it minimizes by Maximizing the negative a function.

disp('The starting value (x) is outside the bounds');
disp('(lb and ub). Execution terminated without any');
disp('optimization. Respecify x, ub or lb so that');
disp('lb(i)<x(i)<ub(i), i=1,...,n');

% End of function

% ******************************************************************

function prt2(Max,x,f);

disp('initial x'); disp(x)
if Max
    disp('initial f'); disp(f)
else
    disp('initial f'); disp(-f)
end

% End of function

% ******************************************************************

function prt3(Max,xp,x,fp,f);

disp('current x'); disp(x)
if Max
    disp('current f'); disp(f)
else
    disp('current f'); disp(-f)
end
disp('trial x'); disp(xp)
disp('point rejected since out of bounds');

% End of function

% ******************************************************************

function prt4(Max,xp,x,fp,f);

disp('current x'); disp(x)
if Max
    disp('current f'); disp(f)
    disp('trial x'); disp(xp)
    disp('resulting f'); disp(fp)
else
    disp('current f'); disp(-f)
    disp('trial x'); disp(xp)
    disp('resulting f'); disp(-fp)
end

% End of function

% ******************************************************************

function prt5;

disp('Too many function evaluations; consider');
disp('increasing Maxevl or eps, or decreasing');
disp('nt or rt. These results are likely to be poor.');

% End of function

% ******************************************************************

function prt6(Max);

if Max
    disp('though lower,point accepted');
else
    disp('though higher,point accepted');
end

% End of function

% ******************************************************************

function prt7(Max);

if Max
    disp('lower point rejected');
else
    disp('higher point rejected');
end

% End of function

% ******************************************************************

function prt8(vm,xopt,x);

disp('intermediate results after step length adjustment');
disp('new step length (vm)'); disp(vm)
disp('current optimal x'); disp(xopt)
disp('current x'); disp(x)

% End of function

% ******************************************************************

function prt9(Max,t,xopt,vm,fopt,nup,ndown,nrej,lnobds,nnew);

disp('intermediate results before next temperature reduction');
disp('current temperature'); disp(t)
if Max
    disp('Max function value so far'); disp(fopt)
    disp('total moves'); disp(nup+ndown+nrej);
    disp('uphill'); disp(nup)
    disp('accepted downhill'); disp(ndown)
    disp('rejected downhill'); disp(nrej)
    disp('out of bounds trials'); disp(lnobds)
    disp('new Maxima this temperature'); disp(nnew)
else
    disp('min function value so far'); disp(-fopt)
    disp('total moves'); disp(nup+ndown+nrej)
    disp('downhill'); disp(nup)
    disp('accepted uphill'); disp(ndown)
    disp('rejected uphill'); disp(nrej)
    disp('trials out of bounds'); disp(lnobds)
    disp('new minima this temperature'); disp(nnew)
end
disp('current optimal x'); disp(xopt)
disp('step length (vm)'); disp(vm)

% End of function

% ******************************************************************

function prt10;

disp('SA achieved termination criteria. ier=0.');

% End of function

% ******************************************************************

function prt11;

disp('The initial temperature is not positive. Reset the variable t.');

% End of function

% ******************************************************************

function prt12;

disp('point accepted');

% End of function

% ******************************************************************

function prt13(xopt,fopt);

disp('new optimum');
disp(xopt)
disp(-fopt)

% End of function

% ******************************************************************

