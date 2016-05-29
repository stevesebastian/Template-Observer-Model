function [response, targetPresent, correct, targetAmp, cT, b, cTEst] = simulateExperiment(ImgStats, binIndex, targetTypeStr, targetLvls)
%SIMULATEEXPREIMENT Generates template responses from real images in either
%   the binned or randomized experiment.
%
% Example:
%   [gabor, envelope, sinusoid] = model.SIMULATEEXPERIMENT(X,Y,Parameters)
%
% Output:
%   gabor:      gabor target
%   envelope:   envelope of the gabor
%   sinusoid:   sinusoid of the gabor
%
%   See also DIFFERENCEOFGAUSSIANS2D.
%
%
%  v1.0,  5/21/2016 Steve Sebastian <sebastian@utexas.edu>

filePath = ImgStats.Settings.imgFilePath;

nTrials = 50;
nLevels = length(targetLvls);

targetIndex = lib.getTargetIndexFromString(ImgStats.Settings, targetTypeStr);

patchIndex = ImgStats.patchIndex{targetIndex}{binIndex(1), binIndex(2), binIndex(3)};

[tSigma, tMu] = model.computeTemplateResponseSigma(ImgStats, targetTypeStr, 0); 
binSigma = tSigma(binIndex(1), binIndex(2), binIndex(3));
binMu = tMu(binIndex(1), binIndex(2), binIndex(3));
binMu = 0;
template = ImgStats.Settings.targets(:,:,targetIndex);
templateEnergy = sum(template(:).*template(:));

cTEst = binSigma./templateEnergy;
cTEst = cTEst./(2^14-1);

response = zeros(nTrials, nLevels);
targetPresent = zeros(nTrials, nLevels);
targetAmp = zeros(nTrials, nLevels);
parfor lItr = 1:nLevels
    thisCriterion = ((2^14-1).*targetLvls(lItr).*templateEnergy)./(binSigma.*2);
    thisTarget = template.*(2^14 - 1).*targetLvls(lItr);
    for tItr = 1:nTrials
        thisIndex = randsample(patchIndex, 1);
        [~, bgPatch] = lib.loadPatchAtIndex(ImgStats, thisIndex, filePath, 0, 0);
        
        % Add target
        bTargetPresent = binornd(1, 0.5);
        if(bTargetPresent)
            bgPatch = lib.embedImageinCenter(bgPatch, thisTarget, 1);
        end
        
        templateResp = (sum(bgPatch(:).*template(:)) - binMu)./binSigma;
        
        response(tItr, lItr) = templateResp > thisCriterion;
        targetPresent(tItr, lItr) = bTargetPresent;
        targetAmp(tItr, lItr) = targetLvls(lItr);
    end
end

correct = response == targetPresent;
pC = mean(correct);
%%
[cT, b] = analysis.fitPsychometric(0.002, 1, targetAmp, correct);

figure; hold on;
ylim([0.5 1]);
xLimFactor = diff(targetLvls);
xlim([targetLvls(1)-xLimFactor(2), targetLvls(end)+xLimFactor(end)]);
axis square; box off;
set(gca, 'FontSize', 20);
set(gca,'TickDir','out')
set(gcf,'color','w');
yLabelVal = 0.5:0.1:1;
set(gca, 'YTick', yLabelVal);
set(gca,'YTickLabel',sprintf('%1.1f\n',yLabelVal));
xLabelVal = targetLvls;
set(gca, 'XTick', xLabelVal);
set(gca,'XTickLabel',sprintf('%.3f\n',xLabelVal));
x = 0:0.0001:(targetLvls(end)+0.002);
y =  normcdf(0.5.*(x./cT).^b);
plot(x, y, 'k-', 'LineWidth', 2);
xlabel('Target Amplitude');
ylabel('Proportion Correct');

plot(targetLvls, pC, 'o', 'LineWidth', 2, 'MarkerSize', 10)
xlabel('Target Amplitude');
ylabel('Percent Correct');




