function [response, targetPresent, correct, targetAmp, cT, b, cTEst] = simulateExperiment(ImgStats, binIndex, targetTypeStr, targetLvls, w)
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

nTrials = 300;
nLevels = length(targetLvls);

targetIndex = lib.getTargetIndexFromString(ImgStats.Settings, targetTypeStr);

patchIndex = ImgStats.patchIndex{targetIndex}{binIndex(1), binIndex(2), binIndex(3)};

[tSigma, ~] = model.computeTemplateResponseSigma(ImgStats, targetTypeStr, 0); 

template = ImgStats.Settings.targets(:,:,targetIndex);
templateEnergy = sum(template(:).*template(:));

if(size(binIndex,1) == 1)
    binSigma = tSigma(binIndex(1), binIndex(2), binIndex(3));
    cTEst = binSigma./templateEnergy;
    cTEst = cTEst./(2^14-1);
else
    binSigma = 0;
end

response = zeros(nTrials, nLevels);
targetPresent = zeros(nTrials, nLevels);
targetAmp = zeros(nTrials, nLevels);
templateResp = zeros(nTrials, nLevels);
criterion = zeros(nTrials, nLevels);
singleCriterionPC = zeros(nLevels, 1);

parfor lItr = 1:nLevels
    if(size(binIndex,1) == 1)
        thisCriterion = ((2^14-1).*targetLvls(lItr).*templateEnergy)./(binSigma.*2);
        thisTarget = template.*(2^14 - 1).*targetLvls(lItr);
    end
    for tItr = 1:nTrials
        if(size(binIndex,1) == 1)
            [response(tItr, lItr), targetPresent(tItr, lItr), targetAmp(tItr, lItr)] = ...
                model.simulateTrialBinned(ImgStats, template, thisTarget, targetLvls(lItr), thisCriterion, binSigma, patchIndex, filePath);
        else
            % Randomly select a bin
            randBinIndex = randsample(1:size(binIndex,1), 1);
            thisBinIndex = binIndex(randBinIndex,:);
            thisBinSigma = tSigma(thisBinIndex(1), thisBinIndex(2), thisBinIndex(3));
            
            thisTargetAmp = (targetLvls(lItr).*thisBinSigma)./templateEnergy;
            thisTargetAmp./(2^14-1)
            thisTarget    =  template.*thisTargetAmp;

            thisPatchIndex  = ImgStats.patchIndex{targetIndex}{thisBinIndex(1), thisBinIndex(2), thisBinIndex(3)};

            [response(tItr, lItr), targetPresent(tItr, lItr), templateResp(tItr, lItr), criterion(tItr, lItr)] = model.simulateTrialRandom(ImgStats, template, thisTarget, targetIndex, targetLvls(lItr), w, thisPatchIndex, filePath, thisBinSigma);
        end
    end
end

correct = response == targetPresent;
pC = mean(correct);
%%

if(size(binIndex,1) == 1)
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
else
    
    dPrimeRange = 0.51:0.1:4.5;
    for dItr = 1:length(dPrimeRange)
        singleCriterionPC(dItr) = model.computeBestSingleCriterion(ImgStats, targetTypeStr, dPrimeRange(dItr), binIndex);
    end
    
    figure; hold on;    
    ylim([0.6 1]);
    xlim([0.6 1]);
    axis square; box off;
    set(gca, 'FontSize', 20);
    set(gca,'TickDir','out')
    set(gcf,'color','w');
    xlabel('Blocked % Correct');
    ylabel('Random % Correct');
    xlabelval = 0.65:0.1:0.95;
    set(gca, 'YTick', xlabelval);
    set(gca, 'XTick', xlabelval);
    plot(normcdf(targetLvls/2), pC, '-o', 'LineWidth', 2, 'MarkerSize', 10);
    plot([0.5 1], [0.5 1], '-k', 'LineWidth', 2); 
    plot(normcdf(dPrimeRange/2), singleCriterionPC, '--k', 'LineWidth', 2);
end



