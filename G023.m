function G023(x, y, r, clock)% G023 함수 동작 (X, Y, R 사용)

global target_position_x;
global target_position_y;
global current_position_x;
global current_position_y;
global time_lap;
global time_rate;

ref_x = x - current_position_x;
ref_y = y - current_position_y;

dt = 0.001; 

if clock==2 %시계방향
    direction = true; %시계방향이면 true 반시계 false
else
    direction = false;
end

start_position = [0, 0];
end_position = [ref_x, ref_y];
radius=r;

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

% 시간 재는 코드
arc_length = abs(center_angle) * radius;
total_time = (arc_length/3) - 1;
total_time = round(total_time, 3);
time = (0:dt:total_time)'; 

t_acc = total_time * time_rate; 
t_flat = total_time - 2 * t_acc; 
v_max = arc_length / (total_time*(1-time_rate)); 

s_curve_acc_time = time(time <= t_acc); 
s_curve_acc = (10 * (s_curve_acc_time / t_acc).^3 - 15 * (s_curve_acc_time / t_acc).^4 + 6 * (s_curve_acc_time / t_acc).^5) * v_max;


s_curve_dec_time = time(time >= total_time - t_acc); 
s_curve_dec = (10 * ((total_time - s_curve_dec_time) / t_acc).^3 - 15 * ((total_time - s_curve_dec_time) / t_acc).^4 + 6 * ((total_time - s_curve_dec_time) / t_acc).^5) * v_max;


flat_time = time(time > t_acc & time < total_time - t_acc); 
flat_speed = ones(length(flat_time), 1) * v_max;

velocity_profile = [s_curve_acc; flat_speed; s_curve_dec];
distance_covered = cumtrapz(time, velocity_profile); 

uniform_distance = linspace(0, max(distance_covered), length(distance_covered));
uniform_theta = linspace(start_angle, end_angle, length(uniform_distance));

theta = interp1(uniform_distance, uniform_theta, distance_covered);

xx = center(1) + radius * cos(theta);
yy = center(2) + radius * sin(theta);

target_position_x = [target_position_x; current_position_x + xx]; % x축 위치
target_position_y = [target_position_y; current_position_y + yy]; % y축 위치

% linear_velocity
x_velocity = gradient(xx, dt); 
y_velocity = gradient(yy, dt); 

linear_velocity = sqrt(x_velocity.^2 + y_velocity.^2);

current_position_x = x;
current_position_y = y;

% % X-Y Trajectory
% subplot(2, 2, 1);
% plot(x, y, 'r', 'LineWidth', 2);
% hold on;
% scatter(start_position(1), start_position(2), 'r', 'filled'); % Start point
% scatter(end_position(1), end_position(2), 'b', 'filled'); % End point
% scatter(center(1), center(2), 'g', 'filled'); % End point
% title('X-Y Plane Trajectory');
% xlabel('X Position [units]');
% ylabel('Y Position [units]');
% legend('Arc', 'Start', 'End', 'Center');
% grid on;
% axis equal;
% 
% % X Position Velocity
% subplot(2, 2, 2);
% plot(time, x, 'LineWidth', 1.5);
% title('X Position');
% xlabel('Time [s]');
% ylabel('Velocity [units/s]');
% grid on;
% 
% % Y Position Velocity
% subplot(2, 2, 3);
% plot(time, y, 'LineWidth', 1.5);
% title('Y Position');
% xlabel('Time [s]');
% ylabel('Velocity [units/s]');
% grid on;
% 
% % Linear Velocity
% subplot(2, 2, 4);
% plot(time, linear_velocity, 'LineWidth', 1.5);
% title('Linear Velocity Profile');
% xlabel('Time [s]');
% ylabel('Velocity [units/s]');
% grid on;

end
