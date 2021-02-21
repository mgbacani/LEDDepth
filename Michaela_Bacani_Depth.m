%% Week 1 Post-Lab Assignment
% Michaela_Bacani_Depth

data = readtable('Week1_Sampledata.csv');

% Extracting each section

      Trial = table2array(data(:,1));
 Brightness = table2array(data(:,2));
   Response = table2array(data(:,3));
  interstim = table2array(data(:,4));
         RT = table2array(data(:,5));
       dist = table2array(data(:,6));
NumberofLED = table2array(data(:,7));

correctOrder = table(Trial, dist, RT, interstim, Brightness, Response, NumberofLED,'VariableNames', {'Trial', 'dist', 'RT', 'interstim', 'Brightness', 'Response', 'NumberofLED'});

writetable(correctOrder, 'Michaela_Bacani_Depth.xlsx')
