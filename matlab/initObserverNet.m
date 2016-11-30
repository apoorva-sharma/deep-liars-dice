function [ net ] = initObserverNet(  )
%INITOBSERVERNET Initializes observer neural network
%   Detailed explanation goes here

    hiddenLayerSize = [20];
    net = patternnet(hiddenLayerSize);
    %net.layers{length(hiddenLayerSize)+1}.transferFcn = 'logsig';

    net.divideFcn = 'dividerand';  % Divide data randomly
    net.divideMode = 'sample';  % Divide up every sample
    net.divideParam.trainRatio = 70/100;
    net.divideParam.valRatio = 15/100;
    net.divideParam.testRatio = 15/100;

    net.performFcn = 'crossentropy';  % Cross-Entropy


end

