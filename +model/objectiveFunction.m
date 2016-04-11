function error = objectiveFunction(params, Lin,Cin,Sin, sigmaIn, modelFunction,errorType)

sigmaOut = modelFunction(params, Lin, Cin, Sin);

if(strcmp(errorType, 'log'))
    error = mean((log(sigmaOut(:)) - log(sigmaIn(:))).^2);
else
    error = mean((sigmaOut(:) - sigmaIn(:)).^2);
end

