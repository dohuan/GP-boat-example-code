close all
clear
clc
set(0,'defaultfigurecolor',[1 1 1]);
%% Apply GMPL package to boat data with observation

addpath(genpath('./gpml'))

% data = xlsread('./data/August 18_Boat_Test.csv','August 18_Boat_Test');
% % --- Clear data to 1s sample period
% ix = [];
% for i=1:size(data,1)
%     if (data(i,11)==0||isnan(data(i,11))==1 ...
%         ||data(i,8)==0||data(i,9)==0)
%         ix = [ix,i];
%     end
% end
% data(ix,:) = [];

load ./data/data_refined

opt.gridsize = 50;
X = [data(:,9) data(:,8)]; % [long lat]

% feature(1).f = data(:,10);
% feature(1).ID = 'Temperature';
% feature(2).f = data(:,11);
% feature(2).ID = 'Electrical Conductivity';
% feature(3).f = data(:,12);
% feature(3).ID = 'Dissolved Solids';
% feature(4).f = data(:,13);
% feature(4).ID = 'Salinity';
% feature(5).f = data(:,15);
% feature(5).ID = 'pH';
% feature(6).f = data(:,16);
% feature(6).ID = 'ORP';
% feature(7).f = data(:,17);
% feature(7).ID = 'DO';
% feature(8).f = data(:,18);
% feature(8).ID = 'DO Sat';

feature(1).f = data(:,10);
feature(1).ID = 'Temperature';
feature(2).f = data(:,12);
feature(2).ID = 'Dissolved Solids';
feature(3).f = data(:,15);
feature(3).ID = 'pH';
feature(4).f = data(:,17);
feature(4).ID = 'DO';

opt.fnum = size(feature,2);



% ---- convert to meter coordinate, origin at min([Long Lat]) -----

origin_m = [min(X(:,1)) min(X(:,2))]; %gps coor of the origin of meter coor
for i=1:size(X,1)
    % --- lldistkm([lat1 long1],[lat2 long2])
    [Long_m,~] = lldistkm([origin_m(1,2) X(i,1)],...
        [origin_m(2) origin_m(1)]);
    [Lat_m,~]  = lldistkm([X(i,2) origin_m(1,1)],...
        [origin_m(2) origin_m(1)]);
    X(i,:)  = 1000*[Long_m Lat_m];
end

ix = [];
for i=1:size(X,1)
    if (X(i,1)<20||X(i,2)<15)
        ix = [ix,i];
    end
end
X(ix,:) = [];
for i=1:opt.fnum
    feature(i).f(ix) = [];
    feature(i).f = zscore(feature(i).f);
end
% --- Standardize the location
X(:,1) = zscore(X(:,1));
X(:,2) = zscore(X(:,2));

s1 = linspace(min(X(:,1)), max(X(:,1)), opt.gridsize);
s2 = linspace(min(X(:,2)), max(X(:,2)), opt.gridsize);
[S1, S2] = meshgrid(s1, s2);
S = [S1(:), S2(:)];

for i=1:opt.fnum
    temp = GP(X,feature(i).f,S,opt);
    result(i) = temp;
    
    subplot(2,2,i)
    pcolor(s1, s2, result(i).meanest);
    shading interp;
    colorbar;
    hold on;
    plot(X(:,1),X(:,2),'wx');
    title(feature(i).ID);
end
