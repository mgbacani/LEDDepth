%{
LED Depth Group
Analysis 
2/28/2021 4:35pm

Table of important values will be automatically saved to the current
folder under the name "DataValues.csv". Manually save .png of graph by
clicking File >> Save As in the new window that will open with plot.
%}
clc; clear all; close all; 
                        % Make edits below this line!%
% ----------------------------------------------------------------------%
% FILE NAME (must be csv in current folder)
files = ["Michaela_BrightCovertBB_012621.csv", ...
        "7cm.csv", ...
        "14cm.csv"];
    
% TRIAL TITLE (ex: Arnav Sunset Data) - will appear as title of each row in excel file
titles = ["file1", "file2", "file3"];

% LEGEND LABELS (generally same as TRIAL TITLES)
labels = {'1', '2', '3'};

% CENTER LED (use 2 for 60cm and 3 for 90cm)
middlearr = [ 3, 3, 3];

%colors for each trial in plot
plotcolors = ['r', 'b', 'c'];

%title of plot
plotTitle = 'Michaela Bright Covert BB';
        % this will change the name of the exported xlsx file w/
        % parameters that will be saved to the current folder. If you do
        % note change this title, you will write over any xlsx files
        % currently in the folder

% ----------------------------------------------------------------------%

% title of exported excel parameter file
exportFileTitle = [plotTitle, ' Parameters.xlsx'];

placeholder = {};
placeholder{1} = {"trial", "pos.slope", "pos.slopeErr", "neg.slope", "neg.slopeErr", "pos.intercept", "pos.interceptErr", "neg.intercept", "neg.interceptErr", "pos.chi2Val", "pos.redChiSquare", "neg.chi2Val", "neg.redChiSquare", "rpos", "rneg"};


for q = 1:length(files)
    trial = titles(q);
    data = readtable(files(q));
    angles = [30 60 90 120 160 200 250];
    middle = middlearr(q);
    meanarr = zeros(0,length(angles));
    sdarr = zeros(0,length(angles));
    
    file = data{data{:,2} ~= 0, :};

    for m = 1:length(angles)
        temp =  file(file(:,2) == angles(m), 3);
        meanarr(m) = mean(temp); %means
        sdarr(m) = std(temp)/ sqrt(length(temp)); %standard error
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
    errorbar(angles, meanarr, sdarr,'o' , 'color' , plotcolors(q), 'CapSize', 0, 'HandleVisibility','off');
    plot(angles(1:middle), polyval(negparams,angles(1:middle)), 'color', plotcolors(q),'HandleVisibility', 'off');
    plot(angles(middle:end), polyval(posparams,angles(middle:end)), 'color', plotcolors(q), 'DisplayName',labels{q});

end

writecell(placeholder{1},exportFileTitle);

for b = 2:length(placeholder)
    writematrix(placeholder{b},exportFileTitle, 'WriteMode','append');
end

xlim([0 270])
ylim([200 550])
xlabel('Distance (cm)');
xticks([30, 60, 90, 120, 160, 200, 250])
ylabel('Reaction Time (ms)');
title(plotTitle);
legend