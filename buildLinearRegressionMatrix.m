function matOut = buildLinearRegressionMatrix(ImgStats, targetTypeStr)

%% Set up

targetIndex = lib.getTargetIndexFromString(ImgStats.Settings, targetTypeStr);
target = ImgStats.Settings.target(:,:,targetIndex);

pTarget = 0.5;
nContrastSteps = 100;
maxContrast = 0.4;

%% Randomly sample patches from all bins 


%% Obtain surrounding 8 patches for each patch


%% Randomly sample a target contrast from the prior distribution and add a target
%       of that contrast to the center patch; if not possible add highest possible

for iPatch = 1:nPatches
    bTargetPresent = binornd(1, pTarget);
    if(bTargetPresent)
        thisContrast = pTarget./(randi(nContrastSteps, 1).*maxContrast);
        thisTarget = target
        
        % Recompute center location stats
        
        % Get the image
        
        % Compute stats
        
       
    end



%%  Perform linear regression to estimate weights for each image property



