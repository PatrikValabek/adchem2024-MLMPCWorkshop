clear; close all; rng(42);
rng(42);
addpath("../_common/")
%% Creation of nMPC

nx = 4;
ny = 4;
nu = 2;
nlobj = nlmpc(nx, ny, nu);

Ts = 10;
nlobj.Ts = Ts;
[xs,us] = get_xsus();

nlobj.PredictionHorizon = 20;

nlobj.ControlHorizon = 20;

%% Specify Nonlinear Plant Model

nlobj.Model.StateFcn = "reactorDT0";
nlobj.Model.IsContinuousTime = false;
nlobj.Model.NumberOfParameters = 1;
nlobj.Model.OutputFcn = 'reactorOutputFcn';

%% Define Cost and Constraints

nlobj.Weights.OutputVariables = ones(20,4);
nlobj.Weights.ManipulatedVariables =ones(20,2)/10;
nlobj.Weights.ManipulatedVariablesRate = [0 0];

nlobj.MV(1).Min = 0-us(1);     
nlobj.MV(1).Max = us(1);     
nlobj.MV(2).Min = 0-us(2);    
nlobj.MV(2).Max = us(2);

%% Validate Nonlinear MPC Controller
x = xs;
u0 = us;
validateFcns(nlobj,x,u0,[],{Ts});
nlobj.Optimization.CustomCostFcn = @quadCostFunction;

%% Closed-Loop Simulation in MATLAB(R)
x = xs;
y = x;
mv = us;

nloptions = nlmpcmoveopt;
nloptions.Parameters = {Ts};

%% one prediction
xin = x-xs ;
[mv,nloptions,info] = nlmpcmove(nlobj,xin,mv-us,[0 0 0 0],[],nloptions);


%% Data collection  

datapoints = 15;
% small = 4
% medium = 15
% large = 22


% x1 = linspace(0,4.22,datapoints)-xs(1);
% x2 = [4.22]-(x1+xs(1))-xs(2);
% x3 = linspace(350,385, datapoints)-xs(3);
% x4 = linspace(335,380, datapoints)-xs(4);
percentage = 0.1;
x1 = linspace(-4.22*percentage,4.22*percentage,datapoints);
x2 = [4.22]-(x1+xs(1))-xs(2);
x3 = linspace(-35*percentage,35*percentage, datapoints);
x4 = linspace(-35*percentage,35*percentage, datapoints);


x = combvec([x1;x2],x3,x4);
length(x)
%% placeholders for data
u = zeros(nu,length(x));

%%
t_start = cputime;

% Preallocate the futures array
futures = parallel.FevalFuture.empty(length(x), 0);

% Run nlmpcmove in parallel
for i = 1:length(x)
    xin = x(:,i);
    futures(i) = parfeval(@nlmpcmove, 3, nlobj, xin, mv-us, [0 0 0 0], [], nloptions);
end

% Wait for all futures to complete and collect results
for i = 1:length(x)
    [u(:,i), result2, info] = fetchOutputs(futures(i));
    if info.ExitFlag == 0
        "suboptimal solution " + string(i)
    elseif info.ExitFlag < 0
        "infeasable or other problem " + string(i)
    end

end

t_end = cputime;

fprintf(['\nData generation time: ', num2str(t_end-t_start), 's\n'])

%% saving data

save('../data/x_data_medium_10.mat', 'x')
save('../data/y_data_medium_10.mat', 'u')


