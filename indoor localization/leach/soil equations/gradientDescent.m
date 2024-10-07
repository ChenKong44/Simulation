function [x_1, fval] = gradientDescent(x0, alpha, maxIter,number,distance,primdistance)
    % f - handle to the cost function
    % gradf - handle to the gradient of the cost function
    % x0 - initial guess
    % alpha - learning rate
    % maxIter - maximum number of iterations
    % tol - tolerance for the stopping criterion
%     
%     n=number;
%     d= distance;
%     d_prime= primdistance;

    d= 7;
    d_prime= 5;
    n=1;
    maxIter=100;
    alpha=0.00009;
    x0=13;

    syms x
%     32.45+20*log10(d)+10*log10(917)+20*log10(d)
    % Define the cost function
    term1(x) = 3.7 - n.*1.5 .* (12 ./ 12) * (x ./ 15) - 10.7 .* log10(d);
    
    % Define the conditional part
    if d_prime <= 4
        term2 = 0;
    else
        term2 = -7.8 + 15.3 .* log10(d_prime);
    end

    f(x) = exp((17)+(term1(x) + term2));
    
    % Define the gradient of the cost function
    fdiff(x) = diff(f(x));

    x_1 = x0;
%     history = zeros(maxIter, length(x0));  % To store the history of x
    for i = 1:maxIter
        grad = subs(fdiff,x,x_1);       % Compute the gradient at x
        x_1 = x - alpha .* grad;     % Update the parameters
        fprintf('x: %d %d\n',i,x_1);
%         history(i, :) = x;        % Store the current x in history
        
    end
   
    fval =subs(f,x,x_1);  % Compute the final value of the cost function
    
    % Trim the history to the actual number of iterations
%     history = history(1:i, :);
end

