function paramsOut = fitTemplateSigmaModel(ImgStats, x0, modelFunction, targetTypeStr, bScale, bPlot)

%% Check input

if(nargin < 5)
    bScale = 1;
end

if(nargin < 6)
    bPlot = 0;
end

if(strcmp(targetTypeStr, 'all'))
    targetTypeStr = ImgStats.Settings.targetKey;
end

binCenterStruct = ImgStats.Settings.binCenters;
nBins = length(binCenterStruct.L);
nTargets = numel(targetTypeStr);

%% Get template response sigmas

tSigma = model.computeTemplateResponseSigma(ImgStats, targetTypeStr, bScale);

%% Get bin centers

Lin = zeros(nBins,nBins,nBins,nTargets);
Cin = zeros(nBins,nBins,nBins,nTargets);
Sin = zeros(nBins,nBins,nBins,nTargets);

for iTarget = 1:nTargets
    for iLum = 1:nBins
        for iCon  = 1:nBins
            for iSim = 1:nBins
                Lin(iLum,iCon,iSim,iTarget) = binCenterStruct.L(iLum);
                Cin(iLum,iCon,iSim,iTarget) = binCenterStruct.C(iCon);
                Sin(iLum,iCon,iSim,iTarget) = binCenterStruct.Sa(iSim,iTarget);
            end
        end
    end
end

%% Fit Model
% x0 = [230.3170*scaleFactor(1), 230.3170*scaleFactor(2), 230.3170*scaleFactor(3), 1  1 1];
options = optimset('Display','iter', 'TolX', 1.e-14, 'TolFun', 1.e-14, 'MaxFunEvals', 3000, 'MaxIter', 5000);
f = @(x)model.objectiveFunction(x,Lin,Cin,Sin,tSigma,modelFunction);

[paramsOut,fval] = fminsearch(f, x0, options);

sigmaModel = modelFunction(paramsOut,Lin,Cin,Sin);

yBar = mean(tSigma(:));
sTot = sum((tSigma(:) - yBar).^2);
sRes = sum((tSigma(:) - sigmaModel(:)).^2);
 
R2 = 1 - sRes/sTot;

disp(['MSE: ' num2str(fval)]);
disp(['R2:  ' num2str(R2)]);

%% Plot
if(bPlot)
    vis.plotTemplateRespSigmaVsStats(ImgStats, 'all', modelFunction, paramsOut);
end
