function result = f(t_w, d, d_prime)
    % Define the main part of the function
    term1 = exp(3.7 - 1.5 * (12 / 12) * (t_w / 15) - 10.7 * log10(d - (t_w / 100)));
    
    % Define the conditional part
    if d_prime <= 4
        term2 = 0;
    else
        term2 = -7.8 + 15.3 * log10(d_prime);
    end
    
    % Combine the terms to get the result
    result = term1 + term2;
end
