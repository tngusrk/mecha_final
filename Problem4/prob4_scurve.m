clf;
clc;
clear all;

dt = 0.001; 
acc_ratio = 0.2;

direction = false; %시계방향이면 true 반시계 false

start_position = [0, 0];
end_position = [60, 40];
radius = sqrt((60-30)^2 + (40-20)^2); 

% start_position = [0,0];
% end_position = [10,40];
% radius = 50;
function center = plot_center(x1, y1, x2, y2, radius, direction)
    % 두 점 간의 거리 계산
    d = sqrt((x2 - x1)^2 + (y2 - y1)^2);
    if d > 2 * radius
        error('주어진 반지름으로 두 점을 포함하는 원을 만들 수 없음 반지름 키우셈');
    end

    % 중점 계산
    mid_x = (x1 + x2) / 2;
    mid_y = (y1 + y2) / 2;
    
    % 중점에서 중심까지의 거리
    h = sqrt(radius^2 - (d / 2)^2);
    
    % 두 점을 잇는 직선의 수직 벡터 계산
    dx = x2 - x1;
    dy = y2 - y1;
    perpendicular_dx = -dy / d;
    perpendicular_dy = dx / d;
    
    % 중심 계산 (시계 방향 또는 반시계 방향 선택)
    if direction
        center_x = mid_x - h * perpendicular_dx;
        center_y = mid_y - h * perpendicular_dy;
    else
        center_x = mid_x + h * perpendicular_dx;
        center_y = mid_y + h * perpendicular_dy;
    end
    
    center = [center_x, center_y];

end


% cw = true ccw = false
center = plot_center(start_position(1), start_position(2), end_position(1), end_position(2), radius, direction);
start_angle = atan2(start_position(2) - center(2), start_position(1) - center(1)); 
end_angle = atan2(end_position(2) - center(2), end_position(1) - center(1));

% 중심각 계산
center_angle = end_angle - start_angle;

% 중심각이 180도를 초과하는 경우 처리
if direction
    if center_angle >= pi
        end_angle = end_angle - 2 * pi; % 시계 방향: 큰 각도 조정
    elseif center_angle < -pi
        end_angle = end_angle + 2 * pi; % 시계 방향: 작은 각도 조정
    end
else
    if center_angle > pi
        end_angle = end_angle - 2 * pi; % 반시계 방향: 큰 각도 조정
    elseif center_angle <= -pi
        end_angle = end_angle + 2 * pi; % 반시계 방향: 작은 각도 조정
    end
end



center_angle = end_angle - start_angle;

arc_length = abs(center_angle) * radius;

total_time = 30;
total_time = round(total_time, 3);

time = (0:dt:total_time)'; 
t_acc = total_time * acc_ratio; 
t_flat = total_time - 2 * t_acc; 
v_max = arc_length / (total_time*(1-acc_ratio)); 

s_curve_acc_time = time(time <= t_acc); 

s_curve_acc = (10 * (s_curve_acc_time / t_acc).^3 - ...
                 15 * (s_curve_acc_time / t_acc).^4 + ...
                  6 * (s_curve_acc_time / t_acc).^5) * v_max;

s_curve_dec_time = time(time >= total_time - t_acc); 
s_curve_dec = (10 * ((total_time - s_curve_dec_time) / t_acc).^3 - ...
                 15 * ((total_time - s_curve_dec_time) / t_acc).^4 + ...
                  6 * ((total_time - s_curve_dec_time) / t_acc).^5) * v_max;


flat_time = time(time > t_acc & time < total_time - t_acc); 
flat_speed = ones(length(flat_time), 1) * v_max;

velocity_profile = [s_curve_acc; flat_speed; s_curve_dec];



position = cumtrapz(time, velocity_profile); 

uniform_position = linspace(0, max(position), length(position));
uniform_theta = linspace(start_angle, end_angle, length(uniform_position));

theta = interp1(uniform_position, uniform_theta, position);
x = center(1) + radius * cos(theta);
y = center(2) + radius * sin(theta);

% linear_velocity
x_velocity = gradient(x, dt); 
x_acc = gradient(x_velocity,dt);
x_jerk = gradient(x_acc,dt);
y_velocity = gradient(y, dt); 


linear_velocity = sqrt(x_velocity.^2 + y_velocity.^2);

data_x.time = time;
data_x.signals.values = x; 
data_x.signals.dimensions = 1;

data_y.time = time;
data_y.signals.values = y;
data_y.signals.dimensions = 1;


% X-Y Trajectory
figure;
plot(x, y, 'r', 'LineWidth', 2);
hold on;
scatter(start_position(1), start_position(2), 'r', 'filled'); % Start point
scatter(end_position(1), end_position(2), 'b', 'filled'); % End point
scatter(center(1), center(2), 'g', 'filled'); % End point
title('X-Y Plane Trajectory');
xlabel('X Position [units]');
ylabel('Y Position [units]');
legend('Arc', 'Start', 'End', 'Center');
grid on;
axis equal;



