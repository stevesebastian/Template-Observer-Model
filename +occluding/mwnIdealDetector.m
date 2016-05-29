function response = mwnIdealDetector(I, T, a, sigma)

decisionVariable = a.*sum((T(:).*I(:))./(sigma(:).^2));
criterion = ((a.^2)./2).*sum((T(:).*T(:))./(sigma(:).^2));
        
if(decisionVariable > criterion)
    response = 1;
else
    response = 0;
end
