function [xL, yL, xC, yC, xSa, ySa] = buildLinearRegressionMatrix(ImgStats, targetTypeStr, expBinIndex, filePath)

if(nargin < 3)
    expBinIndex = [];
end

if(nargin < 4) 
    filePath = '';
end

%% Set ups

targetIndex = lib.getTargetIndexFromString(ImgStats.Settings, targetTypeStr);
target = ImgStats.Settings.targets(:,:,targetIndex);
envelope = ImgStats.Settings.envelope;

pTarget = 0.5;
nContrastSteps = 100;
minContrast = 0.01;
maxContrast = 0.35;
contrastLvls = linspace(minContrast, maxContrast, nContrastSteps);
nSamples = 100;
hwSize = [326, 182]; 

%% Randomly sample patches from bins 
if(~isempty(expBinIndex))
   
    samplePatchIndex = zeros(size(expBinIndex,1), nSamples);
    nBins = size(expBinIndex,1);
    
    % Sample from only specified bins
    for iB = 1:size(expBinIndex, 1)
        iL = expBinIndex(iB, 1);
        iC = expBinIndex(iB, 2);
        iS = expBinIndex(iB, 3);
        
        thisIndex = ImgStats.patchIndex{targetIndex}{iL,iC,iS};
        [thisSample, ~] = ind2sub(size(ImgStats.C), thisIndex);
        [thisSampleRow, thisSampleCol] = ind2sub([326, 182], thisSample);

        invalidIndex = [find(thisSampleRow == hwSize(1) | thisSampleRow == 1)' ...
                        find(thisSampleCol == hwSize(2) | thisSampleCol == 1)'];
                    
        thisIndex(invalidIndex) = [];
        
        % Check for valid patches
        
        samplePatchIndex(iB, :) = ...
            randsample(thisIndex, nSamples, 0);
    end
    
else
    
    nBins = length(ImgStats.Settings.binCenters.L);
    samplePatchIndex = zeros(nBins*nBins*nBins, nSamples);
    
    iB = 1;
    for iL = 1:nBins
       for iC = 1:nBins
            for iS = 1:nBins
                thisIndex = ImgStats.patchIndex{targetIndex}{iL,iC,iS};
                [thisSample, ~] = ind2sub(size(ImgStats.C), thisIndex);
                [thisSampleRow, thisSampleCol] = ind2sub([326, 182], thisSample);
                
                invalidIndex = [find(thisSampleRow >= (hwSize(1)-10) | thisSampleRow <= 10)' ...
                    find(thisSampleCol  >= (hwSize(2)-10) | thisSampleCol <= 10)'];
                
                thisIndex(invalidIndex) = [];
                
                samplePatchIndex(iB, :) = ...
                    randsample(thisIndex, nSamples, 1);
                
                iB = iB + 1;
            end
       end
    end
    nBins = nBins*nBins*nBins;
end
    % Sample from only experiment bins

%% Obtain surrounding 8 patches for each patch
k = 1;

%% Randomly sample a target contrast from the prior distribution and add a target
%       of that contrast to the center patch; if not possible add highest possible

yL  = zeros(nBins,nSamples, 1);
yC  = zeros(nBins,nSamples, 1);
ySa = zeros(nBins,nSamples, 1);

xL = zeros(nBins,nSamples, 10);
xC = zeros(nBins,nSamples, 10);
xSa = zeros(nBins,nSamples, 10);

statSize = size(ImgStats.C);

parfor iBin = 1:nBins
    disp(['Bin: ' num2str(iBin) '/' num2str(nBins)]);
    
    for iSample = 1:nSamples
        
        thisIndex = samplePatchIndex(iBin,iSample);
        [thisSample, thisImage] = ind2sub(statSize, thisIndex);
        
        [statImgL, hwSize]  = getStatImg(ImgStats, thisImage, 'L',  targetIndex);
        statImgC            = getStatImg(ImgStats, thisImage, 'C',  targetIndex);
        statImgSa           = getStatImg(ImgStats, thisImage, 'Sa', targetIndex);
        statImgSs           = getStatImg(ImgStats, thisImage, 'Ss', targetIndex);
        
        [thisSampleRow, thisSampleCol] = ind2sub(hwSize, thisSample);

        thisLMat  = statImgL((thisSampleRow-10):10:(thisSampleRow+10), (thisSampleCol-10):10:(thisSampleCol+10));
        thisCMat  = statImgC((thisSampleRow-10):10:(thisSampleRow+10), (thisSampleCol-10):10:(thisSampleCol+10));
        thisSaMat = statImgSa((thisSampleRow-10):10:(thisSampleRow+10), (thisSampleCol-10):10:(thisSampleCol+10));
        thisSsMat = statImgSs((thisSampleRow-10):10:(thisSampleRow+10), (thisSampleCol-10):10:(thisSampleCol+10));
        
        thisSs = thisSsMat(2,2);
        
        yL(iBin, iSample)  = thisLMat(2,2);
        yC(iBin, iSample)  = thisCMat(2,2);
        ySa(iBin, iSample) = thisSaMat(2,2);  
        
        % Determin whether or not a target should appear
        bTargetPresent = binornd(1, pTarget);
        
        if(bTargetPresent)
            
            % Get the patch
            [~, thisPatch] = lib.loadPatchAtIndex(ImgStats, thisIndex, filePath);
            
            % Generate the target at a random contrast
            thisContrast = randsample(contrastLvls, 1);
            thisAmplitude = thisContrast.*thisLMat(2,2)./100.*(2^14-1);
            thisTarget = target.*thisAmplitude; 
            
            % Embed the target 
            thisPatch = lib.embedImageinCenter(thisPatch, thisTarget, 1);
            
            % Recompute center location stats
            LStruct   = stats.computeSceneLuminance(thisPatch, envelope, [51, 51]);
            CStruct   = stats.computeSceneContrast(thisPatch, envelope, [51, 51]);
            SaStruct  = stats.computeSceneSimilarityAmplitude(thisPatch, target, envelope, [51, 51]);
            SsStruct  = stats.computeSceneSimilaritySpatial(thisPatch, target, envelope, [51, 51]); 
            
            thisLMat(2,2)  =LStruct.L/(2^14-1)*100;
            thisCMat(2,2)  = CStruct.Crms;
            thisSaMat(2,2) = SaStruct.Smag;
            thisSs         = SsStruct.Smag;
            
        end      
        
        xL(iBin, iSample,:)  = [thisLMat(:)' thisSs];
        xC(iBin, iSample,:)  = [thisCMat(:)' thisSs];
        xSa(iBin, iSample,:) = [thisSaMat(:)' thisSs];
    
    end
end


%%  Perform linear regression to estimate weights for each image property
yL = yL(:);
xL = reshape(xL, [size(yL, 1) 10]);

yC = yC(:);
xC = reshape(xC, [size(yC, 1) 10]);

ySa = ySa(:);
xSa = reshape(xSa, [size(ySa, 1) 10]);

