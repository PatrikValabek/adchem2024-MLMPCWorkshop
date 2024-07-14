function J = quadCostFunction(X,U,e,data,params)
    % Define your custom cost function here
    % u: control input
    % e: prediction error
    % parameters: additional parameters needed for your cost function
    
    % Example: Quadratic cost function
    [xs, us] = get_xsus;
    J = 0;
    Q =  [1 0 0 0
        0 50 0 0
        0 0 100 0
        0 0 0 1]./xs;
    R =  [1 0
        0 0.01];
    for k=1:length(U)
        J = J + U(k,:)*R*U(k,:)' + X(k,:)*Q*X(k,:)';
    end
end
