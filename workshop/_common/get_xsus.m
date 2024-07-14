function [xs,us] = get_xsus()
    x0 = [0.5991; 3.6209; 364.9228; 349.1312];
    us = [0.015; 0.004];
    
    Tr_in = 325;
    Tx_in = 288;
    options = optimset('Display','off');
    xs = fsolve(@(x) reactorODE(0, x, us, Tr_in, Tx_in), x0, options);
end