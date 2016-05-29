function maxPC = computeBestSingleCriterion(ImgStats, targetTypeStr, dPrime, binIndex)

% Get the template response standard deviations
tSigma = model.computeTemplateResponseSigma(ImgStats, targetTypeStr, 0);

cRange = 0:50:300;

for cItr = 1:length(cRange)
    % Set up range
    thisPc = zeros(1,size(binIndex,1));
    thisCriterion = cRange(cItr);
    
    for bItr = 1:size(binIndex,1)    
        % Get amplitude for d'
        thisAmp = dPrime.*tSigma(binIndex(bItr,1), binIndex(bItr,2), binIndex(bItr,3));
          
        thisPc(bItr) = normcdf(((thisAmp - thisCriterion)*dPrime)/thisAmp) + normcdf((thisCriterion*dPrime)/thisAmp);
        thisPc(bItr) = thisPc(bItr)/2;
        
        tA(bItr) = thisAmp;
    end
    pc(cItr) = mean(thisPc);
end

maxPC = max(pc);
