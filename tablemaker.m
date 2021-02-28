%fill in file names and stuff below
%parameters will be exported to an excel file
%graph will need to be manually saved
%this code does both, just run it and save what you need and delete what
%you don't

%names/paths of files
files = ["Room Brightness/Aggregate Room Brightness (N=7 as of 210217).csv", "7cm.csv", "14cm.csv"];
%titles of trials (ex Arnav Sunset Data) - will appear in exported excel
%file
titles = ["file1new", "file2", "file3"];
%led you looked at when taking data (use 2 for 60cm and 3 for 90cm)
middlearr=[2,3,3];
%colors for each trial in plot
plotcolors = ['r', 'b', 'c'];
%title of plot
plotTitle = 'meow';
%title of exported excel parameter file
exportFileTitle = 'quack.xlsx';
%plot legend labels
labels = {'thing thats supposed to have a middle at 0.9', 'other thing', 'other other thing'};
% end stuff to fill in

placeholder = {};
placeholder{1} = {"trial", "pos.slope", "pos.slopeErr", "neg.slope", "neg.slopeErr", "pos.intercept", "pos.interceptErr", "neg.intercept", "neg.interceptErr", "pos.chi2Val", "pos.redChiSquare", "neg.chi2Val", "neg.redChiSquare", "rpos", "rneg"};

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
    
    scatter(angles, meanarr,plotcolors(q), 'filled','HandleVisibility', 'off'); 
    hold on
    errorbar(angles, meanarr, sdarr,'o' , 'color' , plotcolors(q), 'CapSize', 0, 'HandleVisibility',...
    'off');
    plot(angles(1:middle), polyval(negparams,angles(1:middle)), 'color', plotcolors(q),'HandleVisibility', 'off');
    plot(angles(middle:end), polyval(posparams,angles(middle:end)), 'color', plotcolors(q), 'DisplayName',labels{q});

end
recycle on
delete(exportFileTitle);
writecell(placeholder{1},exportFileTitle);

for i = 2:length(placeholder)
    writematrix(placeholder{i},exportFileTitle, 'WriteMode','append');
end

xlim([0 270])
ylim([0 900])
xlabel('Distance (cm)');
xticks([30, 60, 90, 120, 160, 200, 250])
ylabel('Reaction Time (ms)');
title(plotTitle);
legend
