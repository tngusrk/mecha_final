clc;
clear all;

% function G01(x, y)  % G01 함수 동작 (X, Y만 사용)
% 
% global target_position_x;
% global target_position_y;
% global current_position_x;
% global current_position_y;
% global time_rate;
% 
time_rate = 0.2; 
current_position_x = 0;
current_position_y = 0;
end_position = [60, 40];

x_length = abs(end_position(1)-current_position_x);
y_length = abs(end_position(2)-current_position_y);

ratio = y_length / x_length; 

total_length = sqrt(x_length^2 + y_length^2);
total_time = 30; 
time = (0:0.001:total_time)'; 

t_acc = total_time * time_rate; 
t_dec = total_time * time_rate; 
t_flat = total_time - t_acc - t_dec; 

s_curve_acc_time = time(time <= t_acc);
s_curve_flat_time = time(time > t_acc & time <= t_acc + t_flat);
s_curve_dec_time = time(time > t_acc + t_flat);

% S-커브
v_max_x = x_length / (0.5 * t_acc + t_flat + 0.5 * t_dec); 
v_max_y = v_max_x / ratio; 

s_curve_acc_x = (10 * (s_curve_acc_time / t_acc).^3 - ...
                 15 * (s_curve_acc_time / t_acc).^4 + ...
                  6 * (s_curve_acc_time / t_acc).^5) * v_max_x;


flat_speed_x = ones(length(s_curve_flat_time), 1) * v_max_x;

% 감속 구간
s_curve_dec_x = (10 * ((total_time - s_curve_dec_time) / t_dec).^3 - ...
                 15 * ((total_time - s_curve_dec_time) / t_dec).^4 + ...
                  6 * ((total_time - s_curve_dec_time) / t_dec).^5) * v_max_x;




x_velocity = [s_curve_acc_x; flat_speed_x; s_curve_dec_x];
y_velocity = x_velocity * ratio;

%reference_position
target_position_x = cumtrapz(time, x_velocity) + current_position_x; % X축 위치
target_position_y = cumtrapz(time, y_velocity) + current_position_y; % Y축 위치

%현재 위치 최신화
current_position_x = end_position(1);
current_position_y = end_position(2);


figure;
plot(time, x_velocity, 'LineWidth', 2);
hold on;
plot(time, y_velocity, 'LineWidth', 2);
title('S-Curve Velocity Profile');
xlabel('Time [sec]');
ylabel('Velocity [units/sec]');
legend('X-axis Velocity', 'Y-axis Velocity');
grid on;

% 2. X축 이송계 위치
figure;
plot(time, target_position_x, 'LineWidth', 2);
title('X축 이송계 위치');
xlabel('Time [sec]');
ylabel('Position [units]');
grid on;

% 3. Y축 이송계 위치
figure;
plot(time, target_position_y, 'LineWidth', 2);
title('Y축 이송계 위치');
xlabel('Time [sec]');
ylabel('Position [units]');
grid on;

% 4. X-Y 
figure;
plot(target_position_x, target_position_y, 'LineWidth', 2);
title('X-Y Position Trajectory');
xlabel('X Position [units]');
ylabel('Y Position [units]');
grid on;

xlim([0 60]); 
ylim([0 40]); 


% 데이터 생성
data_x.time = time;
data_x.signals.values = target_position_x;
data_x.signals.dimensions = 1;

data_y.time = time;
data_y.signals.values = target_position_y;
data_y.signals.dimensions = 1;
% 가속도 계산 (속도의 시간에 대한 미분)
x_acceleration = gradient(x_velocity, time);
y_acceleration = gradient(y_velocity, time);
% 가속도 프로파일 시각화
figure;
plot(time, x_velocity, 'LineWidth', 2);
hold on;
title('Velocity Profile');
xlabel('Time [sec]');
ylabel('Velocity [mm/sec^2]');
legend('X-axis Velocity');
grid on;
% 가속도 프로파일 시각화
figure;
plot(time, x_acceleration, 'LineWidth', 2);
hold on;
title('Acceleration Profile');
xlabel('Time [sec]');
ylabel('Acceleration [mm/sec^2]');
legend('X-axis Acceleration');
grid on;

% Jerk 계산 (가속도의 시간에 대한 미분)
x_jerk = gradient(x_acceleration, time);
y_jerk = gradient(y_acceleration, time);

% Jerk 프로파일 시각화
figure;
plot(time, x_jerk, 'LineWidth', 2);
hold on;
title('Jerk Profile');
xlabel('Time [sec]');
ylabel('Jerk [mm/sec^3]');
legend('X-axis Jerk');
grid on;
