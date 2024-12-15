clc;
clear all;

% 시간 설정
time = (0:0.001:30)'; % 0초부터 30초까지 0.001초 간격

time_rate = 0.2; % 전체 시간대비 가속 구간 비율
T= 30; % 전체시간
ref_x = 60; %목표 위치 x
ref_y = 40; %목표 위치 y

% 최대 속도와 가속도 계산
a_x = ref_x / ((T^2)*time_rate*(1-time_rate)); % x축 가속도 
a_y = ref_y / ((T^2)*time_rate*(1-time_rate)); % y축 가속도 
v_max_x = a_x * time_rate * T ;
v_max_y = a_y * time_rate * T ;

% 가속/감속 시간 계산
t_acc_x = v_max_x / a_x; % x축 가속 시간
t_acc_y = v_max_y / a_y; % y축 가속 시간

% 일정 속도 유지 시간 계산
t_flat_x = max(0, 30 - 2 * t_acc_x); % x축 일정 속도 유지 시간
t_flat_y = max(0, 30 - 2 * t_acc_y); % y축 일정 속도 유지 시간

% 사다리꼴 속도 프로파일 생성
x_velocity = zeros(size(time));
y_velocity = zeros(size(time));

for i = 1:length(time)
    t = time(i);
    % x축 속도
    if t <= t_acc_x
        x_velocity(i) = a_x * t; % 가속 구간
    elseif t <= t_acc_x + t_flat_x
        x_velocity(i) = v_max_x; % 일정 속도 구간
    elseif t <= 2 * t_acc_x + t_flat_x
        x_velocity(i) = v_max_x - a_x * (t - t_acc_x - t_flat_x); % 감속 구간
    else
        x_velocity(i) = 0; % 정지
    end
    
    % y축 속도
    if t <= t_acc_y
        y_velocity(i) = a_y * t; % 가속 구간
    elseif t <= t_acc_y + t_flat_y
        y_velocity(i) = v_max_y; % 일정 속도 구간
    elseif t <= 2 * t_acc_y + t_flat_y
        y_velocity(i) = v_max_y - a_y * (t - t_acc_y - t_flat_y); % 감속 구간
    else
        y_velocity(i) = 0; % 정지
    end
end

% 위치 계산 (속도의 적분)
target_position_x = cumtrapz(time, x_velocity); % x축 위치
target_position_y = cumtrapz(time, y_velocity); % y축 위치

% 시각화

% % 1. 속도 프로파일
% figure;
% plot(time, x_velocity, 'LineWidth', 2);
% hold on;
% plot(time, y_velocity, 'LineWidth', 2);
% title('Velocity Profile');
% xlabel('Time [sec]');
% ylabel('Velocity [units/sec]');
% legend('X-axis Velocity', 'Y-axis Velocity');
% grid on;

% 2. x축 이송계 위치
figure;
plot(time, target_position_x, 'LineWidth', 2);
title('X축 이송계 위치');
xlabel('Time [sec]');
ylabel('Position [units]');
grid on;

% 3. y축 이송계 위치
figure;
plot(time, target_position_y, 'LineWidth', 2);
title('Y축 이송계 위치');
xlabel('Time [sec]');
ylabel('Position [units]');
grid on;

% x,y 2D
figure;
plot(target_position_x, target_position_y, 'LineWidth', 2);
title('X-Y Position Trajectory');
xlabel('X Position [units]');
ylabel('Y Position [units]');
grid on;

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
