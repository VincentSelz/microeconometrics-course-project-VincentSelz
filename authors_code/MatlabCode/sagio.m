% sagio.m   -   5.7.99t

% this file is the sim ann function from goffe.
% (It includes the correction mentioned
% in previous notes the Matlab version).



function [xopt,fopt,nacc,nfcnev,nobds,ier,t,vm] ...
    =sagio(fcn,x,max,rt,eps,ns,nt,neps,maxevl,lb,ub,c,iprint,seed,t,vm);


% Initialize the random number generator.
if seed>=0
    rand('state',seed);
end

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
fstar=realmax.*ones(neps,1);
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
if seed<0
    rand('state',sum(1e6*clock));
end

%  If the function is to be minimized, switch the sign of the function.
%  Note that all intermediate and final output switches the sign back
%  to eliminate any possible confusion for the user.
if not(max)
    f=-f;
end
nfcnev=nfcnev+1;
fopt=f;
if iprint>1
    prt2(max,x,f);
end

%  Start the main loop. Note that it terminates if (i) the algorithm
%  succesfully optimizes the function or (ii) there are too many
%  function evaluations (more than MAXEVL).
quit=0;
while not(quit)

    nup=0;
    nrej=0;
    nnew=0;
    ndown=0;
    lnobds=0;
    count=0;

    for m=1:nt
        for j=1:ns
            for h=1:n
                count=count+1;
                if count>50
                    count=0;
                    %x=xopt;
                    %f=fopt;
                end

                %  Generate xp, the trial value of x. Note use of vm to choose xp.
                rand('state',sum(h*j*m*100*clock));
                xp=x;
                xp(h)=x(h)+(rand(1,1).*2-1)*vm(h);

                %xp(h)=x(h)+(randn(1,1))*vm(h);

                %  If xp is out of bounds, select a point in bounds for the trial.
                while ((xp(h)>ub(h)) | (xp(h)<lb(h)))
                    xp(h)=lb(h)+(ub(h)-lb(h))*rand(1,1);
                    %xp(h)=x(h)+(randn(1,1))*vm(h);
                    %lnobds=lnobds+1;
                    % nobds=nobds+1;
                    if iprint>=3; prt3(max,xp,x,fp,f); end
                end

                %  Evaluate the function with the trial point xp and return as fp.
                fp=feval(fcn,xp);
                
                if not(max)
                    fp=-fp;
                end
                
                nfcnev=nfcnev+1;
                if iprint>=3
                    prt4(max,xp,x,fp,f);
                end

                % Initialize the random number generator.
                if seed<0
                    rand('state',sum(100*h*j*n*clock));
                end

                %  If too many function evaluations occur, terminate the algorithm.
                if nfcnev>=maxevl
                    prt5;
                    if not(max)
                        fopt=-fopt;
                    end
                    ier=1;
                    return;
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
                        %save('c:\xopt','xopt')
                        if isequal(iprint,-5)
                            prt13(xopt,fopt);
                        end
                    end

                    %  If the point is lower, use the Metropolis criteria to decide on
                    %  acceptance or rejection.
                else
                    p=exp((fp-f)/t);
                    pp=rand(1,1);
                    if pp<p
                        if iprint>=3
                            prt6(max);
                        end
                        x=xp;
                        f=fp;
                        nacc=nacc+1;
                        nacp(h)=nacp(h)+1;
                        ndown=ndown+1;
                    else
                        nrej=nrej+1;
                        if iprint>=3
                            prt7(max);
                        end
                    end
                end

            end % of for h=1:n (loop over paramerers)
        end % of while j=1:ns (loop over evaluations at current step length)


        %  Adjust vm so that approximately half of all evaluations are accepted.
        %  (for each component of x, if more than 60% of all evaluations yield
        %  new optima, then vm will be widened, to broaden the search; likewise,
        %  if less than 40% of all evals yield new optima, then vm is also widened)

        for i=1:n
            ratio=nacp(i)/ns;
            if ratio>0.6
                vm(i)=vm(i).*(1+c(i).*(ratio-0.6)./0.4);
            elseif ratio<0.4
                vm(i)=vm(i)./(1+c(i).*(0.4-ratio)./0.4);
            end
            if vm(i)>(ub(i)-lb(i))
                vm(i)=ub(i)-lb(i);
            end
        end

        if (iprint>=2||iprint==-5)
            prt8(vm,xopt,x);
        end

        nacp=zeros(n,1);

    end % of for m=1:nt (loop over evaluations at the current temperature)

    if (iprint>=1||iprint==-5)
        prt9(max,t,xopt,vm,fopt,nup,ndown,nrej,lnobds,nnew);
    end

    %  Check termination criteria.
    fstar(1)=f;
    if (fopt-fstar(1))<=eps % quit if current f (fstar) not too much lower than fopt.
        quit=0;
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

end % of while not(quit)

%  Terminate SA if appropriate.
x=xopt;
ier=0;
if not(max)
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
%  correction is because SA was written to maximize functions and
%  it minimizes by maximizing the negative a function.

disp('The starting value (x) is outside the bounds');
disp('(lb and ub). Execution terminated without any');
disp('optimization. Respecify x, ub or lb so that');
disp('lb(i)<x(i)<ub(i), i=1,...,n');

% End of function

% ******************************************************************

function prt2(max,x,f);

disp('initial x'); disp(x)
if max
    disp('initial f'); disp(f)
else
    disp('initial f'); disp(-f)
end

% End of function

% ******************************************************************

function prt3(max,xp,x,fp,f);

disp('current x'); disp(x)
if max
    disp('current f'); disp(f)
else
    disp('current f'); disp(-f)
end
disp('trial x'); disp(xp)
disp('point rejected since out of bounds');

% End of function

% ******************************************************************

function prt4(max,xp,x,fp,f);

disp('current x'); disp(x)
if max
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
disp('increasing maxevl or eps, or decreasing');
disp('nt or rt. These results are likely to be poor.');

% End of function

% ******************************************************************

function prt6(max);

if max
    disp('though lower,point accepted');
else
    disp('though higher,point accepted');
end

% End of function

% ******************************************************************

function prt7(max);

if max
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

function prt9(max,t,xopt,vm,fopt,nup,ndown,nrej,lnobds,nnew);

disp('intermediate results before next temperature reduction');
disp('current temperature'); disp(t)
if max
    disp('max function value so far'); disp(fopt)
    disp('total moves'); disp(nup+ndown+nrej);
    disp('uphill'); disp(nup)
    disp('accepted downhill'); disp(ndown)
    disp('rejected downhill'); disp(nrej)
    disp('out of bounds trials'); disp(lnobds)
    disp('new maxima this temperature'); disp(nnew)
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

