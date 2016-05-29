function sigmaEst = computeSigmaEstimate(lEst, cEst, sEst)

params = [216.6446    0.2445   -0.0141   -0.0673];

sigmaEst = linear_models.fourParamLCS(params, lEst,cEst,sEst);