function [response, targetPresent, templateResp, criterion] = simulateTrialRandom(ImgStats, template, target, targetIndex, dPrime, w, patchIndex, filePath, binSigma)

criterion = dPrime./2; 
hwSize = [326, 182]; 
statSize = size(ImgStats.C);

envelope = ImgStats.Settings.envelope;

%% Randomly sample a patch from the patchIndex
% Remove patches that are at the bounds (ie don't have a valid surround)
patchIndexTemp = patchIndex;
[thisSample, ~] = ind2sub(size(ImgStats.C), patchIndex);
[patchSampleRow, patchSampleCol] = ind2sub(hwSize, thisSample);
%[patchSampleRow, patchSampleCol] = ind2sub(hwSize, patchIndex);

invalidIndex = [find(patchSampleRow >= hwSize(1)-10 | patchSampleRow <=10)' ...
                        find(patchSampleCol >= hwSize(2)-10 | patchSampleCol <= 10)'];
                    
patchIndex(invalidIndex) = [];

try
    thisIndex = randsample(patchIndex, 1);
catch 
    k = 1;
end
[thisSample, thisImage] = ind2sub(statSize, thisIndex);

%% Get the stat image and sample the surround 
statImgL            = getStatImg(ImgStats, thisImage, 'L',  targetIndex);
statImgC            = getStatImg(ImgStats, thisImage, 'C',  targetIndex);
statImgSa           = getStatImg(ImgStats, thisImage, 'Sa', targetIndex);
statImgSs           = getStatImg(ImgStats, thisImage, 'Ss', targetIndex);
        
[thisSampleRow, thisSampleCol] = ind2sub(hwSize, thisSample);

try
    thisLMat  = statImgL((thisSampleRow-10):10:(thisSampleRow+10), (thisSampleCol-10):10:(thisSampleCol+10));
    thisCMat  = statImgC((thisSampleRow-10):10:(thisSampleRow+10), (thisSampleCol-10):10:(thisSampleCol+10));
    thisSaMat = statImgSa((thisSampleRow-10):10:(thisSampleRow+10), (thisSampleCol-10):10:(thisSampleCol+10));
    thisSsMat = statImgSs((thisSampleRow-10):10:(thisSampleRow+10), (thisSampleCol-10):10:(thisSampleCol+10));
catch
    k = 1;
end

thisSs = thisSsMat(2,2);

%% Add target and compute statistics

bTargetPresent = binornd(1, 0.5);
[~, bgPatch] = lib.loadPatchAtIndex(ImgStats, thisIndex, filePath);

if(bTargetPresent)
           
    % Embed the target
    bgPatch = lib.embedImageinCenter(bgPatch, target, 1);
    
    % Recompute center location stats
    LStruct   = stats.computeSceneLuminance(bgPatch, envelope, [51, 51]);
    CStruct   = stats.computeSceneContrast(bgPatch, envelope, [51, 51]);
    SaStruct  = stats.computeSceneSimilarityAmplitude(bgPatch, template, envelope, [51, 51]);
    SsStruct  = stats.computeSceneSimilaritySpatial(bgPatch, template, envelope, [51, 51]);
    
    thisLMat(2,2)  = LStruct.L/(2^14-1)*100;
    thisCMat(2,2)  = CStruct.Crms;
    thisSaMat(2,2) = SaStruct.Smag;
    thisSs         = SsStruct.Smag;
           
end
   
x.L  = [thisLMat(:)' thisSs];
x.C  = [thisCMat(:)' thisSs];
x.Sa = [thisSaMat(:)' thisSs];
    
%% Compute the L, C and S estimates
lEst = sum(bsxfun(@times, x.L,  w.L'),2);
cEst = sum(bsxfun(@times, x.C,  w.C'),2);
sEst = sum(bsxfun(@times, x.Sa, w.S'),2);

% Use the estimates to get an estimate of sigma
sigmaEst = model.computeSigmaEstimate(lEst, cEst, sEst).*sum(template(:).*template(:));

%% Compute the template response, scale and compare the the criterion
templateResp = (sum(bgPatch(:).*template(:)))./sigmaEst;

response = templateResp > criterion;
targetPresent = bTargetPresent;

% if(bTargetPresent)
%     disp(['PRESENT: Template Response: ' num2str(templateResp) ' criterion: ' num2str(criterion)]);
% else
%     disp(['ABSENT:  Template Response: ' num2str(templateResp) ' criterion: ' num2str(criterion)]);
% end
