function [xL, yL, xC, yC, xSa, ySa] = buildLinearRegressionMatrix(ImgStats, targetTypeStr, expBinIndex, filePath)

if(nargin < 3)
    expBinIndex = [];
end

if(nargin < 4) 
    filePath = '';
end

%% Set up

targetIndex = lib.getTargetIndexFromString(ImgStats.Settings, targetTypeStr);
target = ImgStats.Settings.targets(:,:,targetIndex);

pTarget = 0.5;
nContrastSteps = 100;
maxContrast = 0.2;

nSamples = 100;

%% Randomly sample patches from bins 
if(~isempty(expBinIndex))
   
    samplePatchIndex = zeros(size(expBinIndex,1), nSamples);
    nBins = size(expBinIndex,1);
    
    % Sample from only specified bins
    for iB = 1:size(expBinIndex, 1)
        iL = expBinIndex(iB, 1);
        iC = expBinIndex(iB, 2);
        iS = expBinIndex(iB, 3);
        
        samplePatchIndex(iB, :) = ...
            randsample(ImgStats.patchIndex{targetIndex}{iL,iC,iS}, nSamples, 0);
    end
    
else
    
    nBins = length(ImgStats.Settings.binCenters.L);
    samplePatchIndex = zeros(nBins, nBins, nBins, nSamples);
    
    for iL = 1:nBins
       for iC = 1:nBins
            for iS = 1:nBins
                try
                    samplePatchIndex(iL, iC, iS, :) = ...
                      randsample(ImgStats.patchIndex{targetIndex}{iL,iC,iS}, nSamples, 0);
                catch
                    samplePatchIndex(iL, iC, iS, :) = ...
                    randsample(ImgStats.patchIndex{targetIndex}{iL,iC,iS}, nSamples, 1);
                end
            end
       end
    end
end
    % Sample from only experiment bins

%% Obtain surrounding 8 patches for each patch
k = 1;

%% Randomly sample a target contrast from the prior distribution and add a target
%       of that contrast to the center patch; if not possible add highest possible

iR = 1;

yL  = zeros(nBins*nSamples, 1);
yC  = zeros(nBins*nSamples, 1);
ySa = zeros(nBins*nSamples, 1);

xL = zeros(nBins*nSamples, 10);
xC = zeros(nBins*nSamples, 10);
xSa = zeros(nBins*nSamples, 10);

for iBin = 1:nBins
    for iSample = 1:nSamples
        
        thisIndex = samplePatchIndex(iBin,iSample);
        [thisSample, thisImage] = ind2sub(size(ImgStats.C), thisIndex);
        
        [statImgL, hwSize]  = getStatImg(ImgStats, thisImage, 'L',  targetIndex);
        statImgC            = getStatImg(ImgStats, thisImage, 'C',  targetIndex);
        statImgSa           = getStatImg(ImgStats, thisImage, 'Sa', targetIndex);
        statImgSs           = getStatImg(ImgStats, thisImage, 'Ss', targetIndex);
        
        [thisSampleRow, thisSampleCol] = ind2sub(hwSize, thisSample);

        thisLMat  = statImgL((thisSampleRow-2):(thisSampleRow+2), (thisSampleCol-2):(thisSampleCol+2));
        thisCMat  = statImgC((thisSampleRow-2):(thisSampleRow+2), (thisSampleCol-2):(thisSampleCol+2));
        thisSaMat = statImgSa((thisSampleRow-2):(thisSampleRow+2), (thisSampleCol-2):(thisSampleCol+2));
        thisSsMat = statImgSs((thisSampleRow-2):(thisSampleRow+2), (thisSampleCol-2):(thisSampleCol+2));
        
        thisSs = thisSsMat(3,3);
        
        % Determin whether or not a target should appear
        bTargetPresent = binornd(1, pTarget);
        
        if(bTargetPresent)
            
            % Get the patch
            [~, thisPatch] = lib.loadPatchAtIndex(ImgStats, thisIndex, filePath);
            
            % Generate the target at a random contrast
            thisContrast = pTarget./(randi(nContrastSteps, 1).*maxContrast);
            thisAmplitude = thisContrast.*thisL./100.*255;
            thisTarget = target.*thisAmplitude; 
            
            % Embed the target 
            thisPatch = lib.embedImageinCenter(thisPatch, thisTarget, 1);
            
            % Recompute center location stats
            thisL0  = stats.computeSceneLuminance(thisPatch, envelope, [51, 51]);
            thisC0  = stats.computeSceneContrast(thisPatch, envelope, [51, 51]);
            thisSa0  = stats.computeSceneSimilarityAmplitude(thisPatch, target, envelope, [51, 51]);
            thisSs0 = stats.computeSceneSimilaritySpatial(thisPatch, target, envelope, [51, 51]); 
            
            thisLMat(3,3)  = thisL0;
            thisCMat(3,3)  = thisC0;
            thisSaMat(3,3) = thisSa0;
            thisSs         = thisSs0;
            
        end
        yL(iR)  = thisLMat(3,3);
        yC(iR)  = thisCMat(3,3);
        ySa(iR) = thisSaMat(3,3);        
        
        xL(iR,:)  = [thisLMat(:) thisSs];
        xC(iR,:)  = [thisLMat(:) thisSs];
        xSa(iR,:) = [thisLMat(:) thisSs];
       
        iR = iR + 1;
    end
end


%%  Perform linear regression to estimate weights for each image property



