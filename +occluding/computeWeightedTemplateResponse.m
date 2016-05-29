function [scaledResponse, response] = computeWeightedTemplateResponse(template, imgIn, alpha, cMap)

% Compute the template match
tMatch = template.*imgIn;

% Scale each point by the inverse of the contrast squared
weightMap = 1./(cMap.^2 + alpha.^2);
weightMap = weightMap./sum(weightMap(:));

scaledResponse  = numel(tMatch(:)).*sum(tMatch(:).*weightMap(:));
response        = sum(tMatch(:));

