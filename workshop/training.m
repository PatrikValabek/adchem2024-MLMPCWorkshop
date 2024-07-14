clear; close all; rng(42);

%% Loadnig data
load('data/x_data_medium_5.mat')
load('data/u_data_medium_5.mat')

%% Creation of NN
% Define custom neural network architecture
hiddenLayerSizes = []; 

% Create a feedforward neural network
net = fitnet(hiddenLayerSizes);

% Customize network activation functions
% help nntransfer
% 'purelin' - linear
% 'logsig' - logistic sigmoid (0; 1)
% 'tansig' - tanh, hyperbolic tangens (-1; 1)
% 'poslin' - ReLu

% net.layers{end}.transferFcn = 'tansig'; 

% Data division
net.divideFcn = 'dividerand'; % Data division function
net.divideParam.trainRatio = 0.7; % Percentage of data for training
net.divideParam.valRatio = 0.15; % Percentage of data for validation
net.divideParam.testRatio = 0.15; % Percentage of data for testing

%% Specification of training (if needed)
% net.trainParam.epochs = 1000; % Number of training epochs
% net.trainParam.goal = 0.01; % Training goal (mean squared error)
% net.trainParam.min_grad = 1e-40; % Minimum gradient for training to stop

% net.trainParam.epochs = 100; % Maximum number of training epochs
% net.trainParam.lr = 0.01; % Learning rate
% net.trainParam.goal = 1e-15; % Performance goal (target mean squared error)
% net.trainParam.max_fail = 1000; % Maximum validation failures before stopping
% net.trainParam.min_grad = 1e-6; % Minimum performance gradient
% net.trainParam.showWindow = true; % Show training progress window
% net.trainParam.showCommandLine = false; % Display command-line output during training
% net.trainParam.show = 25; % Number of epochs between showing progress
% net.trainParam.time = inf; % Maximum training time in seconds (inf for no limit)

%% wiev NN arch
view(net)

%% Training
[net,tr] = train(net, x, u);


%% Test

% plot performance
figure
plotperform(tr)

% calculatetest MSE
testX = x(:,tr.testInd);
testU = u(:,tr.testInd);

testU_pred = net(testX);

perf = mse(net,testU,testU_pred)

% how often breaks the boundaries
breaks_upper = sum(testU_pred(1,:) >= 0.0015) + sum(testU_pred(2,:) >= 0.0004)
breaks_lower = sum(testU_pred(1,:) <= -0.0015) + sum(testU_pred(2,:) <= -0.0004)
%% Saving
save ('trained_NN.mat', 'net')




