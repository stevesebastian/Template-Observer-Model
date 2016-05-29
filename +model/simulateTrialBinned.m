function [response, targetPresent, targetAmp] = simulateTrialBinned(ImgStats, template, target, targetAmp, criterion, binSigma, patchIndex, filePath)

thisIndex = randsample(patchIndex, 1);
[~, bgPatch] = lib.loadPatchAtIndex(ImgStats, thisIndex, filePath, 0, 0);
        
% Add target
bTargetPresent = binornd(1, 0.5);
if(bTargetPresent)
    bgPatch = lib.embedImageinCenter(bgPatch, target, 1);
end

templateResp = (sum(bgPatch(:).*template(:)))./binSigma;

response = templateResp > criterion;
targetPresent = bTargetPresent;
