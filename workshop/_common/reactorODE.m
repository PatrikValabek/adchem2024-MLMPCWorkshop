function dxdt = reactorODE(~, x, u, Tr_in, Tc_in)
    % params: cA_in, cB_in, Tr_in[tunable], Tc_in[tunable], ROr, Roc, CPr, ...
    % params: CPc, CoeffTT, A, Vr, Vc, Kr, Er, Hr, stCoeffA, stCoeffB
    %
    % inputs: u = [qr, qc]'
    % states: x = [cA, cB, Tr, Tc]', cB is product
    % us = [0.015; 0.004]
    % [xs,us] = get_xsus;
    % Tr_in = 325
    % Tx_in = 288

    % params init.
    % Tr_in             % reaction mixture inlet temperature
    % Tc_in             % coolant inlet temperature
    cA_in = 4.22;       % reagent A inlet concentration
    cB_in = 0;          % reagent B inlet concentration
    ROr = 1020;         % reaction mixture density
    ROc = 998;          % coolant density
    CPr = 4.02;         % reaction mixture spec. heat capacity
    CPc = 4.182;        % coolant spec. heat capacity
    CoeffTT = 42.8;     % total heat transfer coeff. in react. wall
    A = 1.51;           % react. wall heat transfer area
    Vr = 0.23;          % reactor volume
    Vc = 0.21;          % cooling system volume
    Kr = 1.55e11;       % react. collision factor
    Er = 8.1e4;         % activation energy
    Hr = -6.4e4;        % react. entalpy
    stCoeffA = 1;       % stech. coeff. A
    stCoeffB = 1;       % stech. coeff. B

    dxdt = zeros(4, 1);
    % reactions speed
    k = Kr*exp(-Er/(8.314*x(3)));
    % ODEs
    dxdt(1) = -u(1)/Vr*x(1) + u(1)/Vr*cA_in - stCoeffA*k*x(1)^stCoeffA;
    dxdt(2) = -u(1)/Vr*x(2) + u(1)/Vr*cB_in + stCoeffB*k*x(1)^stCoeffA;
    dxdt(3) = -Hr/ROr/CPr*k*x(1) + u(1)/Vr*(Tr_in-x(3)) + CoeffTT*A/Vr/ROr/CPr*(x(4)-x(3));
    dxdt(4) = u(2)/Vc*(Tc_in-x(4)) + CoeffTT*A/Vc/ROc/CPc*(x(3)-x(4));
end