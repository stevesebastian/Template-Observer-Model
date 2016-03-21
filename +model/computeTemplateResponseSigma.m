function [tSigma, smallSample] = computeTemplateResponseSigma(tMatch, patchIndex, scaleFactor)


tSigma = zeros(size(patchIndex));
smallSample = zeros(size(patchIndex));

for iLum = 1:size(tSigma,1)
    for iCon = 1:size(tSigma,2)
        for iSim = 1:size(tSigma,1)
            tSigma(iLum, iCon, iSim) = std(tMatch(patchIndex{iLum, iCon, iSim}))./scaleFactor;
            if(size(patchIndex{iLum, iCon, iSim} < 300))
                smallSample(iLum, iCon, iSim) = 1;
            end
        end
    end
end
