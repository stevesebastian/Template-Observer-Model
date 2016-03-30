function matOut = buildLinearRegressionMatrix(ImgStats, targetTypeStr, expBinIndex, filePath)

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

for iBin = 1:nBins
    for iSample = 1:nSamples
        thisIndex = samplePatchIndex(iBin,iSample);
        
        thisL = ImgStats.L(thisIndex);
        thisC = ImgStats.C(thisIndex);
        thisS = ImgStats.S(thisIndex);
        
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
            thisS0  = stats.computeSceneSimilarityAmplitude(thisPatch, target, envelope, [51, 51]);
            thisSs0 = stats.computeSceneSimilaritySpatial(thisPatch, target, envelope, [51, 51]); 
        else
            thisL0  = thisL;
            thisC0  = thisC;
            thisS0  = thisS;
            thisSs0 = thisSs;
        end
        
    end
end


%%  Perform linear regression to estimate weights for each image property



