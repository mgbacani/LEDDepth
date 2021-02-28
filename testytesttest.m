

files = ["Michaela_BrightCovertBB_012621.csv", "Michaela_BrightCovertBB_012621.csv", "Michaela_BrightCovertBB_012621.csv"];
titles = ["file1", "file2", "file3"];
placeholder = {};
placeholder{1} = {"trial", "pos.slope", "pos.slopeErr", "neg.slope", "neg.slopeErr", "pos.intercept", "pos.interceptErr", "neg.intercept", "neg.interceptErr", "pos.chi2Val", "pos.redChiSquare", "neg.chi2Val", "neg.redChiSquare", "rpos", "rneg"};
middlearr=[3,3,3];

for q = 1:length(files)
    trial = titles(q);
    data = readtable(files(q));
    angles = [30 60 90 120 160 200 250];
    middle = middlearr(q);
    meanarr = [0 0 0 0 0 0 0];
    sdarr = [0 0 0 0 0 0 0];
    
    file = data{data{:,2} ~= 0, :};
    i = 1;
    for i = 1:7
        temp =  file(file(:,2) == angles(i), 3);
        meanarr(i) = mean(temp); %means
        sdarr(i) = std(temp)/ sqrt(length(temp)); %standard error
        i = i + 1;
    end

    r = corrcoef(angles, meanarr);
    weights = (1./sdarr).^2;
    
    %negative
    xVals = angles(1:middle);
    yVals = meanarr(1:middle);
    sdneg = sdarr(1:middle);
    w = weights(1:middle);
    f = @(x, xPoints, yPoints, w)sum(w.*((yPoints- ((xPoints.*x(1))+x(2))).^2));
    optFun = @(x)f(x, xVals, yVals, w);
    ms = MultiStart;
    OLSFit = polyfit(xVals, yVals, 1);
    guessParams = [OLSFit(1), OLSFit(2)];
    problem = createOptimProblem('fmincon', 'x0', guessParams, ...
        'objective', optFun, 'lb', [-10, 200], 'ub', [10, 600]);
    params = run(ms, problem, 25);
    slope = params(1);
    intercept = params(2);
    chiSquareFit.slope = slope;
    chiSquareFit.intercept = intercept;
    chi2Val = optFun(params);
    chiSquareFit.chi2Val = chi2Val;
    syms sErr;
    slopeErr = solve(f([sErr, intercept], xVals, yVals, w)==...
        chi2Val + 1, sErr);
    chiSquareFit.slopeErr = double(slopeErr(2) - slope);
    syms iErr;
    intErr = solve(f([slope, iErr], xVals, yVals, w) == chi2Val+1, iErr);
    chiSquareFit.interceptErr = double(intErr(2)-intercept);
    chiSquareFit.redChiSquare = chi2Val/ (length(xVals) - 2);
    chisqfneg = chiSquareFit;
    disp(chisqfneg);
    rneg = corrcoef(xVals, yVals);
    negparams = params;
    
    
    %------------------------------------------
    %positive
    xVals = angles(middle:end);
    yVals = meanarr(middle:end);
    sdneg = sdarr(middle:end);
    w = weights(middle:end);
    optFun = @(x)f(x, xVals, yVals, w);
    ms = MultiStart;
    OLSFit = polyfit(xVals, yVals, 1);
    guessParams = [OLSFit(1), OLSFit(2)];
    problem = createOptimProblem('fmincon', 'x0', guessParams, ...
        'objective', optFun, 'lb', [-10, 200], 'ub', [10, 600]);
    params = run(ms, problem, 25);
    posparams = params;
    slope = params(1);
    intercept = params(2);
    chiSquareFit.slope = slope;
    chiSquareFit.intercept = intercept;
    chi2Val = optFun(params);
    chiSquareFit.chi2Val = chi2Val;
    syms sErr;
    slopeErr = solve(f([sErr, intercept], xVals, yVals, w)==...
        chi2Val + 1, sErr);
    chiSquareFit.slopeErr = double(slopeErr(2) - slope);
    syms iErr;
    intErr = solve(f([slope, iErr], xVals, yVals, w) == chi2Val+1, iErr);
    chiSquareFit.interceptErr = double(intErr(2)-intercept);
    chiSquareFit.redChiSquare = chi2Val/ (length(xVals) - 2);
    chisqfpos = chiSquareFit;

    rpos = corrcoef(xVals, yVals);
    w = [trial, chisqfpos.slope chisqfpos.slopeErr chisqfneg.slope chisqfneg.slopeErr chisqfpos.intercept chisqfpos.interceptErr chisqfneg.intercept chisqfneg.interceptErr chisqfpos.chi2Val chisqfpos.redChiSquare chisqfneg.chi2Val chisqfneg.redChiSquare rpos(1,2) rneg(1,2)];
    placeholder{q+1} = w;

end
recycle on
delete('rip.xslx');
writecell(placeholder{1},'rip.xlsx');

for i = 2:length(placeholder)
    writematrix(placeholder{i},'rip.xlsx', 'WriteMode','append');
end



