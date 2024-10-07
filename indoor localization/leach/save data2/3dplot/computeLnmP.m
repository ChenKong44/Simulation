function L_nm_p = computeLnmP(vartheta_w, t_w, a_nm, d, d_prime)
    % Compute the main part of the function
    term1 = 3.7 - a_nm * 1.5 * (vartheta_w / 12) * (t_w / 15) - 10.7 * log10(d - (t_w / 100));
    
    % Compute the conditional part
    if d_prime <= 4
        term2 = 0;
    else
        term2 = -7.8 + 15.3 * log10(d_prime);
    end
    
    % Combine the terms to get the result
    L_nm_p = term1 + term2;
end

