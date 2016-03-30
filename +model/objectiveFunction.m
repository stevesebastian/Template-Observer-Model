function error = objectiveFunction(params, Lin,Cin,Sin, sigmaIn, modelFunction)

sigmaOut = modelFunction(params, Lin, Cin, Sin);

if(sum(sigmaOut(:) < 0) || sum(params(:) < 0))
    error = Inf;
else
    error = mean((sigmaOut(:) - sigmaIn(:)).^2);
end
