function [lik, latents] = likfun_ddm(x,data)
    
    % Likelihood function for two-armed bandit task.
    %
    % USAGE: [lik, latents] = likfun_ddm(x,data)
    %
    % INPUTS:
    %   x - parameters:
    %       x(1) - drift rate differential action value weight (b)
    %       x(2) - decision threshold (a)
    %       x(3) - non-decision time (d)
    %   data - structure with the following fields
    %           .c - [N x 1] choices
    %           .r - [N x 1] rewards
    %           .s - [N x 1] states
    %           .rt - [N x 1] response times
    %           .C - number of choice options
    %           .N - number of trials
    %
    % OUTPUTS:
    %   lik - log-likelihood
    %   latents - structure with the following fields:
    %           .P - [N x 1] action probability
    %           .v - [N x 1] drift rate
    %
    % Sam Gershman, Dec 2016
    
    % set parameters
    b = x(1);           % drift rate differential action value weight
    a = x(2);           % decision threshold
    if length(x)>2; d = x(3); else d = 0; end
    data.rt = max(eps,data.rt-d);
    
    lik = 0;
    for n = 1:length(data.choice)
        
        v = b*(data.V(n,1)-data.V(n,2));      % drift rate
        
        % accumulate log-likelihod
        if data.choice(n) == 1
            P = wfpt(data.rt(n),-v,a);  % Wiener first passage time distribution (lower boundary)
        else
            P = wfpt(data.rt(n),v,a);
        end
        if isnan(P) || P==0; P = realmin; end % avoid NaNs and zeros in the logarithm
        lik = lik + log(P);
        
        % store latent variables
        if nargout > 1
            latents.v(n,1) = v;
            latents.P(n,1) = P;
            latents.p(n,1) = 1/(1+exp(-a*v));
            if v==0; v = realmin; end
            latents.rt(n,1) = d + (0.5*a/v)*tanh(0.5*a*v);
        end
    end