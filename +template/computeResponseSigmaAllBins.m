function [tSigma, binCenters] = computeResponseSigmaAllBins(ImgStats, targetTypeStr, 

%% Get template response
nBins = length(ImgStats.binCenters,L);
nTargets = size(ImgStats,Settings.targetKey,2);

if(strcmp(targetTypeStr, 'all') || size(targetTypeStr, 2) )
    binCenter = [];
    for iTarget = 1:size(ImgStats.Settings.targetKey,2)
        targetIndex = lib.getTargetIndexFromString(ImgStats.Settings,ImgStats.Settings.targetKey{iTarget});
        target = ImgStats.Settings.targets(:,:,targetIndex);
        scaleFactor = sum(target(:).*target(:)); 
    
        tMatch = ImgStats.tMatch(:,:,targetIndex);

        if(strcmp(simType, 'amp'))
            patchIndex = ImgStats.patchIndex{targetIndex};
        else
            patchIndex = ImgStats.patchIndexSs{targetIndex};
        end
            
        tSigma(:,:,:,iTarget) = model.computeTemplateResponseSigma(tMatch, patchIndex, scaleFactor);
    end
else
    targetIndex = lib.getTargetIndexFromString(ImgStats.Settings,targetTypeStr);
    target = ImgStats.Settings.targets(:,:,targetIndex);
    scaleFactor = sum(target(:).*target(:)); 
    
    tMatch = ImgStats.tMatch(:,:,targetIndex);
    
    if(strcmp(simType, 'amp'))
        patchIndex = ImgStats.patchIndex{targetIndex};
    else
        patchIndex = ImgStats.patchIndexSs{targetIndex};
    end
    
    tSigma = model.computeTemplateResponseSigma(tMatch, patchIndex, scaleFactor);

end