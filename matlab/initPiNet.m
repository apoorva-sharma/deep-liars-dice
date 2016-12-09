function [ net ] = initPiNet( total_coins, hiddenLayerSize )
%INITPINET Initializes Pi neural network
%   Detailed explanation goes here

    outputsize = total_coins + 2; % one_hot over actions
    
    net = patternnet(hiddenLayerSize);
    net.layers{length(hiddenLayerSize)+1}.size = outputsize;

    net.divideFcn = 'dividerand';  % Divide data randomly
    net.divideMode = 'sample';  % Divide up every sample
    net.divideParam.trainRatio = 70/100;
    net.divideParam.valRatio = 15/100;
    net.divideParam.testRatio = 15/100;

    net.performFcn = 'crossentropy';  % Cross-Entropy


end

