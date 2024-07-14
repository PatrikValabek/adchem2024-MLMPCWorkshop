clear; close all; rng(42);

%% Loading the performance of MPC
load('data/x_nmpc.mat')
load('data/u_nmpc.mat')

umin = [0, 0];
umax = [0.03, 0.008];
[xs,us] = get_xsus();
x_nmpc(:,1) = xs;
u_nmpc(:,1) = us;

%% Simulating the NN in closed loop
nx = 4;
nu = 2;
load('trained_NN.mat')

x = xs;
Ts = 10;
Duration = 600;
hbar = waitbar(0,'Simulation Progress');
xHistory = x;
u_nn = [0;0];
u_nnHistory = us;
odeOptions = [];

Tr_in = 325;
Tx_in = 288;

for ct = 1:(Duration/Ts)
    % disturbance #2 - failed reading of the sensor
    X_inm = x;
    if ct >= 20 && ct <= 23
        X_inm(3) = 273.15;
    end

    % Compute control moves
    xin = X_inm-xs;
    u_nn = net(xin);%-net(zeros(nx,1));
    u_nn = u_nn+us;

    % disturbance #3 - valve failure, fail to open
    if ct >= 40 && ct <= 41
        u_nn(2) = 0.008;
    end
    
    % Simulate the next state
    [tode, X] = ode45(@(t, x, u) reactorODE(t, x, u,Tr_in, Tx_in), [0,Ts], x, odeOptions, u_nn);
    Xode{ct, 1} = X;
    Tode{ct, 1} = tode;
    
    x = X(end,:)';

    % disturbance #1 - coolant temperature changes
    if ct == 5
        Tr_in = Tr_in-15;
    end
    if ct == 7
        Tr_in = 325;
    end
    xHistory = [xHistory x]; %#ok<*AGROW>
    u_nnHistory = [u_nnHistory u_nn]; %#ok<*AGROW>
    waitbar(ct*Ts/Duration,hbar);

end

close(hbar)
Tode_nmpc = cell2mat(Tode);
Xode_nmpc = cell2mat(Xode);


%%
figure

for k = 1:1:nx
    subplot(nx, 1, k)
    hold on
    stairs(0:Ts:Duration,x_nmpc(k,1:end),'r', 'linewidth', 3)
    stairs(0:Ts:Duration,xHistory(k,:),'b', 'linewidth', 3)
    legend("mpc","nn")
    xlabel('t [s]')
    ylabel(['x_' num2str(k)])
    set(gcf, 'name', 'states')
end

%%
figure

for k = 1:1:nu
    subplot(nu, 1, k)
    hold on
    stairs(0:Ts:Duration,u_nmpc(k,1:end),'r', 'linewidth', 3)
    stairs(0:Ts:Duration,u_nnHistory(k,:),'b', 'linewidth', 3)
    legend("mpc","nn")
    stairs([0, Duration], [umax(k) umax(k)], ...
        'linestyle', '--', 'linewidth', 3, 'Color', 'k')
    stairs([0, Duration], [umin(k) umin(k)], ...
        'linestyle', '--', 'linewidth', 3, 'Color', 'k')
    xlabel('t [s]')
    ylabel(['u_' num2str(k)])
end

