close all, clc, format long

formatSpec = '%f';

% fileID = fopen('simulation_data_fart.txt','r');
% Data0 = fscanf(fileID,formatSpec);
% fclose(fileID);

fileID = fopen('simulation_data_vinkel.txt','r');
Data0 = fscanf(fileID,formatSpec);
fclose(fileID);
% 
% fileID = fopen('simulation_data_40.txt','r');
% Data40 = fscanf(fileID,formatSpec);
% fclose(fileID);
% 
% fileID = fopen('simulation_data_80.txt','r');
% Data80 = fscanf(fileID,formatSpec);
% fclose(fileID);




% figure('Position', [100 100 300 350])
figure
hold on
plot(TimeStamps, Data0, 'LineWidth', 2);
% plot(TimeStamps, Data40, 'LineWidth', 1);
% plot(TimeStamps, Data80, 'LineWidth', 1);

yline(1, 'k', 'LineWidth', 1);
yline(0.95, 'k--', 'LineWidth', 1);
% yline(Bot_radius, 'k','LineWidth', 1);

xlim([0 2])
ylim([-0.1 1.1])

xlabel('t [s]')
ylabel('Riktningsvinkel [rad]')

% legend('v_{g} = 0','v_{g} = 40% v_{max}','v_{g} = 80% v_{max}');