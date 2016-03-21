function paramsOut = fitTemplateSigmaModel(ImgStats, modelFunction, targetTypeStr)

%% Check input

nBins = length(binCenters.L);
nTargets = size(ImgStats.Settings.targetKey,2);

simType = 'amp';
%% Get template response
if(strcmp(targetTypeStr, 'all'))
    binCenter = [];
    for iTarget = 1:nTargets
        targetIndex = lib.getTargetIndexFromString(ImgStats.Settings,ImgStats.Settings.targetKey{iTarget});
        target = ImgStats.Settings.targets(:,:,targetIndex);
        scaleFactor = sum(target(:).*target(:)); 
    
        tMatch = ImgStats.tMatch(:,:,targetIndex);
        if(strcmp(simType, 'amp'))
            patchIndex = ImgStats.patchIndex{targetIndex};
            binCenter = [binCenter ImgStats.Settings.binCenters.Sa(:,targetIndex)'];
        else
            patchIndex = ImgStats.patchIndexSs{targetIndex};
            binCenter = [binCenter ImgStats.Settings.binCenters.Ss(:,targetIndex)'];
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
        binCenter = ImgStats.Settings.binCenters.Sa(:,targetIndex)';
    else
        patchIndex = ImgStats.patchIndexSs{targetIndex};
        binCenter = ImgStats.Settings.binCenters.Ss(:,targetIndex)';
    end
    
    tSigma = model.computeTemplateResponseSigma(tMatch, patchIndex, scaleFactor);

end

%% Get bin centers
binCenters = ImgStats.Settings.binCenters;

binCenters = zeros(nBins,nBins,nBins,nTargets,3);

for iTarget = 1:size(ImgStats.Settings.targetKey,2)
    for iLum = 1:nBins
        for iCon  = 1:nBins
            for iSim = 1:nBins
                binCenter(iLum,iCon,iSim,iTarget,:) = ...
                    [binCenters.L(iLum), binCenters.C(iCon), binCenters.Sa(iSim,Itarget)];
            end
        end
    end
end

                    
            
            k = 1;
