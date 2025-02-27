clc
clear all
close all
%% Initial variables
axis_coord = [400 1440 0 5500]; % Axis scaling coordinates

%% Read results from AMPL for the FULL model
X = x;
ESTADO = estado;

% Vectors
TS = X(:,1); 
Pdisp = X(:,2:end)*diag(ESTADO(:,2)); % Ignore index at X(:,1)
Ptotal = X(:,2:end)*ESTADO(:,2);

F = [1 1 0 0 0 0 0 0 0 0 0 0 0 0 0
     0 0 1 1 1 0 0 0 0 0 0 0 0 0 0
     0 0 0 0 0 1 0 0 0 0 0 0 0 0 0
     0 0 0 0 0 0 1 1 1 0 0 0 0 0 0
     0 0 0 0 0 0 0 0 0 1 1 1 1 0 0
     0 0 0 0 0 0 0 0 0 0 0 0 0 1 1];
 
K = F*diag(ESTADO(:,2));
Pdisp = X(:,2:end)*K';

%% Read results from AMPL for CO
X_co = x_co;
ESTADO_co = estado_co;

% Vectors
TS_co = X_co(:,1); 
Pdisp_co = X_co(:,2:end)*diag(ESTADO_co(:,2));
Ptotal_co = X_co(:,2:end)*ESTADO_co(:,2);

F_co = [1 1 0 0 0 0 0 0 0 0 0 0 0 0 0
     0 0 1 1 1 0 0 0 0 0 0 0 0 0 0
     0 0 0 0 0 1 0 0 0 0 0 0 0 0 0
     0 0 0 0 0 0 1 1 1 0 0 0 0 0 0
     0 0 0 0 0 0 0 0 0 1 1 1 1 0 0
     0 0 0 0 0 0 0 0 0 0 0 0 0 1 1];
 
K_co = F_co*diag(ESTADO_co(:,2));
Pdisp_co = X_co(:,2:end)*K_co';
%% Read ground truth data
DATA = csvread('ground_truth.csv');
time = 1:length(DATA);
CDE_P = DATA(:,1);
CDE_Q = DATA(:,2);
DWE_P = DATA(:,3);
DWE_Q = DATA(:,4);
FGE_P = DATA(:,5);
FGE_Q = DATA(:,6);
HPE_P = DATA(:,7);
HPE_Q = DATA(:,8);
WOE_P = DATA(:,9);
WOE_Q = DATA(:,10);
TV_P = DATA(:,11);
TV_Q = DATA(:,12);
ALL_P = DATA(:,13);
ALL_Q = DATA(:,14);

%% Read Pattern Recognition Results
names = {'onemin_dry.csv', 'onemin_dws.csv', 'onemin_refr.csv', 'onemin_htp.csv', 'onemin_unk.csv'};

PATREC = zeros(1440,5);
i = 1;
for name = names  
    appl = csvread(char(name));
    PATREC(:,i) = appl(:,2);
    i = i+1;    
end


%% Subplot Ground Truth Data
sp(1) = subplot(4,1,1);
bar(time, [CDE_P DWE_P FGE_P HPE_P WOE_P TV_P],1,'stacked');
hold on
P = bar(0); % Additional element in the legend for unknown loads
set(P(1),'facecolor',[0.5 0.5 0.5])
set(P(1),'facecolor',[0.5 0.5 0.5])
L = legend('CDE','DWE','FGE','HPE','WOE',' TV','Unkn');
ylabel(sprintf('(a)\nPower [W]'))
t(1) = title('(a) Ground Truth Data');
axis(axis_coord)
set(gca,'xtick',[],'fontsize',7)
%legend('Location','northwest')

%% Subplot CO data
sp(2) = subplot(4,1,2);
Pdisp_co = X_co(:,2:end)*K_co';
bar(TS_co, Pdisp_co,1,'stacked');
ylabel('Power [W]')
t(2) = title('(b) Combinatorial Optimization');
axis(axis_coord)
set(gca,'xtick',[],'fontsize',7)

% Add zoom plots
ssp(1) = axes('position',[.17 .6 .1 .07]); % Put subzoom
b = bar(Pdisp_co,1, 'stacked', 'EdgeColor', 'none');
%axis tight
axis([600 650 0 900])
%set(gca,'xtick',[],'ytick',[]);
set(gca,'fontsize',5)
xticks([600 650])
yticks([450 900])

ssp(2) = axes('position',[.43 .6 .1 .07]); % Put subzoom
b = bar(Pdisp_co,1, 'stacked', 'EdgeColor', 'none');
axis tight
%set(gca,'xtick',[],'ytick',[]);
axis([900 1000 0 1100])
set(gca,'fontsize',5)
xticks([900 1000])
%yticks([500 1000])
set(gca,'ytick',[]);

ssp(3) = axes('position',[.67 .6 .1 .07]); % Put subzoom
b = bar(Pdisp_co,1, 'stacked', 'EdgeColor', 'none');
axis tight
%set(gca,'xtick',[],'ytick',[]);
axis([1050 1100 0 4000])
set(gca,'fontsize',5)
xticks([1050 1100])
%yticks([2000 4000])
set(gca,'ytick',[]);



%% Subplot Full Model data
sp(3) = subplot(4,1,3);
Pdisp = X(:,2:end)*K';
bar(TS, Pdisp, 1,'stacked');
set(gca,'xtick',[],'fontsize',7)
ylabel('Power [W]')
t(3) = title('(c) This Work');
axis(axis_coord)


%% Subplot Pattern Recognition data
sp(4) = subplot(4,1,4);
P = bar(PATREC,1,'stacked');
C = [53 42 134;
    12 116 220;
    6 169 193;
    124 191 123
    127 127 127]/255;
for n=1:length(P) 
set(P(n),'facecolor',C(n,:));
end
set(gca,'fontsize',7)
xlabel('t (min)')
ylabel('Power [W]')
t(4) = title('(d) Pattern Recognition');
axis(axis_coord)


%% Post subplot config
% Size of the graph
x0=15;
y0=10;
width=17;
height=12;
set(gcf,'units','centimeters','position',[x0,y0,width,height])

% Position of the title

for i = 1:4
    t(i).Position(2) = t(i).Position(2) - 1250;
end

% Size of each subplot
for i = 1:4
    sp(i).Position(4) = sp(i).Position(4)*1.35;
    sp(i).Position(1) = 0.07;
    sp(i).Position(3) = 0.9;
end

% Position of the legend
L.Position = [0.09, 0.785, 0.0950, 0.1854];

% Size of the subplots adjusted
for i = 1:3
    ssp(i).Position(4) = 0.1;
end

ssp(1).Position(1) = 0.12;
ssp(2).Position(1) = 0.45;
ssp(3).Position(1) = 0.7;

% Plot lines on CO2
subplot(sp(2))
hold on;
plot([570 610], [1370 800], '-', 'Color', [0.5 0.5 0.5])
plot([900 900], [2000 800], '-', 'Color', [0.5 0.5 0.5])
plot([1080 1130], [1000 1370], '-', 'Color', [0.5 0.5 0.5])

% Middle zoom plot should be upper
ssp(2).Position(2) = 0.615;

%% Metrics for the FULL model

% TEE = \dfrac{|\sum_{t}{y_i(t)} - \sum_{t}{\hat{y}_i(t)}|}{\sum_{t} { y_i(t)}}
y_true_cde = CDE_P;
y_pred_cde = Pdisp(:,1);
TEE_cde = round(abs(sum(y_true_cde) - sum(y_pred_cde))/sum(y_true_cde)*100,1);

y_true_dwe = DWE_P;
y_pred_dwe = Pdisp(:,2);
TEE_dwe = round(abs(sum(y_true_dwe) - sum(y_pred_dwe))/sum(y_true_dwe)*100,1);

y_true_fge = FGE_P;
y_pred_fge = Pdisp(:,3);
TEE_fge = round(abs(sum(y_true_fge) - sum(y_pred_fge))/sum(y_true_fge)*100,1);

y_true_hpe = HPE_P;
y_pred_hpe = Pdisp(:,4);
TEE_hpe = round(abs(sum(y_true_hpe) - sum(y_pred_hpe))/sum(y_true_hpe)*100,1);

y_true_woe = WOE_P;
y_pred_woe = Pdisp(:,5);
TEE_woe = round(abs(sum(y_true_woe) - sum(y_pred_woe))/sum(y_true_woe)*100,1);

y_true_tv = TV_P;
y_pred_tv = Pdisp(:,6);
TEE_tv = round(abs(sum(y_true_tv) - sum(y_pred_tv))/sum(y_true_tv)*100,1);

% TIE = \dfrac{\sum_{t} { |y_i(t) - \hat{y}_i(t)|}}{\sum_{t} { y_i(t)}}
TIE_cde = round(sum(abs(y_true_cde(1:1435) - y_pred_cde))/sum(y_true_cde)*100,1); % adjust length to match with the prediction

TIE_dwe = round(sum(abs(y_true_dwe(1:1435) - y_pred_dwe))/sum(y_true_dwe)*100,1);

TIE_fge = round(sum(abs(y_true_fge(1:1435) - y_pred_fge))/sum(y_true_fge)*100,1);

TIE_hpe = round(sum(abs(y_true_hpe(1:1435) - y_pred_hpe))/sum(y_true_hpe)*100,1);

TIE_woe = round(sum(abs(y_true_woe(1:1435) - y_pred_woe))/sum(y_true_woe)*100,1);

TIE_tv = round(sum(abs(y_true_tv(1:1435) - y_pred_tv))/sum(y_true_tv)*100,1);

%% Metrics for CO

% TEE = \dfrac{|\sum_{t}{y_i(t)} - \sum_{t}{\hat{y}_i(t)}|}{\sum_{t} { y_i(t)}}
y_pred_cde = Pdisp_co(:,1);
TEE_cde_co = round(abs(sum(y_true_cde) - sum(y_pred_cde))/sum(y_true_cde)*100,1);

y_pred_dwe = Pdisp_co(:,2);
TEE_dwe_co = round(abs(sum(y_true_dwe) - sum(y_pred_dwe))/sum(y_true_dwe)*100,1);

y_pred_fge = Pdisp_co(:,3);
TEE_fge_co = round(abs(sum(y_true_fge) - sum(y_pred_fge))/sum(y_true_fge)*100,1);

y_pred_hpe = Pdisp_co(:,4);
TEE_hpe_co = round(abs(sum(y_true_hpe) - sum(y_pred_hpe))/sum(y_true_hpe)*100,1);

y_pred_woe = Pdisp_co(:,5);
TEE_woe_co = round(abs(sum(y_true_woe) - sum(y_pred_woe))/sum(y_true_woe)*100,1);

y_pred_tv = Pdisp_co(:,6);
TEE_tv_co = round(abs(sum(y_true_tv) - sum(y_pred_tv))/sum(y_true_tv)*100,1);

% TIE = \dfrac{\sum_{t} { |y_i(t) - \hat{y}_i(t)|}}{\sum_{t} { y_i(t)}}
TIE_cde_co = round(sum(abs(y_true_cde(1:1435) - y_pred_cde))/sum(y_true_cde)*100,1);

TIE_dwe_co = round(sum(abs(y_true_dwe(1:1435) - y_pred_dwe))/sum(y_true_dwe)*100,1);

TIE_fge_co = round(sum(abs(y_true_fge(1:1435) - y_pred_fge))/sum(y_true_fge)*100,1);

TIE_hpe_co = round(sum(abs(y_true_hpe(1:1435) - y_pred_hpe))/sum(y_true_hpe)*100,1);

TIE_woe_co = round(sum(abs(y_true_woe(1:1435) - y_pred_woe))/sum(y_true_woe)*100,1);

TIE_tv_co = round(sum(abs(y_true_tv(1:1435) - y_pred_tv))/sum(y_true_tv)*100,1);

%% Metrics for Patt. Rec.

% TEE = \dfrac{|\sum_{t}{y_i(t)} - \sum_{t}{\hat{y}_i(t)}|}{\sum_{t} { y_i(t)}}
y_pred_cde = PATREC(:,1);
TEE_cde_pr = round(abs(sum(y_true_cde) - sum(y_pred_cde))/sum(y_true_cde)*100,1);

y_pred_dwe = PATREC(:,2);
TEE_dwe_pr = round(abs(sum(y_true_dwe) - sum(y_pred_dwe))/sum(y_true_dwe)*100,1);

y_pred_fge = PATREC(:,3);
TEE_fge_pr = round(abs(sum(y_true_fge) - sum(y_pred_fge))/sum(y_true_fge)*100,1);

y_pred_hpe = PATREC(:,4);
TEE_hpe_pr = round(abs(sum(y_true_hpe) - sum(y_pred_hpe))/sum(y_true_hpe)*100,1);

% TIE = \dfrac{\sum_{t} { |y_i(t) - \hat{y}_i(t)|}}{\sum_{t} { y_i(t)}}
TIE_cde_pr = round(sum(abs(y_true_cde - y_pred_cde))/sum(y_true_cde)*100,1);

TIE_dwe_pr = round(sum(abs(y_true_dwe - y_pred_dwe))/sum(y_true_dwe)*100,1);

TIE_fge_pr = round(sum(abs(y_true_fge - y_pred_fge))/sum(y_true_fge)*100,1);

TIE_hpe_pr = round(sum(abs(y_true_hpe - y_pred_hpe))/sum(y_true_hpe)*100,1);

