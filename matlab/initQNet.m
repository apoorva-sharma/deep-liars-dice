function [ net ] = initQNet( total_coins, hiddenLayerSize )
%INITQNET Initializes Q neural network
%   Detailed explanation goes here

    outputsize = 1; % just a Q value
    
    trainFcn = 'trainlm';  % Levenberg-Marquardt backpropagation.
    net = fitnet(hiddenLayerSize,trainFcn);
    net.layers{length(hiddenLayerSize)+1}.size = outputsize;

    net.divideFcn = 'dividerand';  % Divide data randomly
    net.divideMode = 'sample';  % Divide up every sample
    net.divideParam.trainRatio = 70/100;
    net.divideParam.valRatio = 15/100;
    net.divideParam.testRatio = 15/100;

    net.performFcn = 'crossentropy';  % Cross-Entropy
end

