function sigmaOut = fourParamLCS(params, Lin,Cin,Sin)

sigmaOut = params(1).*(Lin+params(2)).*(Cin+params(3)).*(Sin+params(4));

