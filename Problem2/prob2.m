clc;
clear all;

time = (0:0.001:30)';
target_position_x = linspace(0, 60, sum(time >= 0 & time <= 30))';
target_position_y = linspace(0, 40, sum(time >= 0 & time <= 30))';


plot(time, target_position_x, 'LineWidth', 2);
hold on
plot(time, target_position_y, 'LineWidth', 2);
title('Motor Position Trajectory');
grid on
xlabel('Time [sec]');
ylabel('Position [mm]');
xlim([0 30])
ylim([0 60])

data_x.time = time;
data_x.signals.values = target_position_x;
data_x.signals.dimensions = 1;

data_y.time = time;
data_y.signals.values = target_position_y;
data_y.signals.dimensions = 1;