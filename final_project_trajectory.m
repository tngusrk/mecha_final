clc;
clear all;

% 초기화
commands = cell(5, 1); % 최대 5개의 명령을 저장할 셀 배열
data = []; % 데이터를 저장할 행렬 (명령과 관련된 값들 저장)

global target_position_x; % 구조체에 전달할 포지션
global target_position_y; 
global current_position_x; % 현재 위치 최신화(각 함수 끝단에서)
global current_position_y;

% 시간 설정
global time_lap; 
global time_rate;

time_rate=0.2;      % 가속구간 비율
time_lap =30;       % 각 이동시간

current_position_x =0;
current_position_y =0;
target_position_x = 0;
target_position_y = 0;


% 최대 5번 입력 받기
for i = 1:5
    % 사용자 입력 받기
    userInput = input('Enter command (e.g., G01 X10 Y20;): ', 's');
    commands{i} = userInput; % 입력 명령 저장
    
    % G01 처리
    if startsWith(userInput, 'G01')
        tokens = regexp(userInput, 'G01 X(\d+) Y(\d+);', 'tokens');
        if ~isempty(tokens)
            x = str2double(tokens{1}{1});
            y = str2double(tokens{1}{2});
            data = [data; i, 1, x, y, NaN]; % i: 명령 순서, 1: G01, NaN: R 값 없음
        end
    
    % G02 처리
    elseif startsWith(userInput, 'G02')
        tokens = regexp(userInput, 'G02 X(\d+) Y(\d+) R(\d+);', 'tokens');
        if ~isempty(tokens)
            x = str2double(tokens{1}{1});
            y = str2double(tokens{1}{2});
            r = str2double(tokens{1}{3});
            data = [data; i, 2, x, y, r]; % i: 명령 순서, 2: G02
            % disp('CW'); % G02는 'CW' 출력
        end
    
    % G03 처리
    elseif startsWith(userInput, 'G03')
        tokens = regexp(userInput, 'G03 X(\d+) Y(\d+) R(\d+);', 'tokens');
        if ~isempty(tokens)
            x = str2double(tokens{1}{1});
            y = str2double(tokens{1}{2});
            r = str2double(tokens{1}{3});
            data = [data; i, 3, x, y, r]; % i: 명령 순서, 3: G03
            % disp('CCW'); % G03은 'CCW' 출력
        end
    else
        disp('Invalid command. Please try again.');
    end
end

% 결과 출력
disp('Commands received:');
disp(commands);

disp('Data stored (row format: [Order, CommandType, X, Y, R]):');
disp(data);


for i = 1:size(data, 1)
    commandType = data(i, 2); % 명령어 타입 (1: G01, 2: G02, 3: G03)
    x = data(i, 3);          % X 값
    y = data(i, 4);          % Y 값
    r = data(i, 5);          % R 값 (NaN일 수 있음)
    
    switch commandType
        case 1 % G01
            G01(x, y);
        case 2 % G02
            G023(x, y, r, 2);
        case 3 % G03
            G023(x, y, r, 3);
    end

end



all_time = (0:0.001:length(target_position_x)/1000-0.001)'; % plot 할때 쓰는 전체시간

% 1. 속도 프로파일
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
plot(all_time, target_position_x, 'LineWidth', 2);
title('X축 이송계 위치');
xlabel('Time [sec]');
ylabel('Position [units]');
grid on;

% 3. y축 이송계 위치
figure;
plot(all_time, target_position_y, 'LineWidth', 2);
title('Y축 이송계 위치');
xlabel('Time [sec]');
ylabel('Position [units]');
grid on;

x_point = data(:, 3);  % 각 행의 3번째 열 (x좌표)
y_point = data(:, 4);  % 각 행의 4번째 열 (y좌표)

colors = {'r', [1, 0.5, 0], 'y', 'g', 'b'};  % 빨강, 주황, 노랑, 초록, 파랑

% x,y 2D
figure;
plot(target_position_x, target_position_y, 'LineWidth', 2);
hold on;
% 점 추가 플로팅
for i = 1:length(x_point)
    plot(x_point(i), y_point(i), 'o', 'MarkerSize', 10, 'MarkerFaceColor', colors{i}, 'MarkerEdgeColor', 'k');
    % 레이블 추가
end

title('X-Y Position Trajectory');
xlabel('X Position [units]');
ylabel('Y Position [units]');
grid on;

% X-Y 궤적을 Simulink로 전송할 데이터 구조 생성
data_x.time = all_time;
data_x.signals.values = target_position_x;
data_x.signals.dimensions = 1;

data_y.time = all_time;
data_y.signals.values = target_position_y;
data_y.signals.dimensions = 1;

tot_time= (length(target_position_x)/1000-0.001);
% disp('Total Time: %.3f\n',tot_time);

tot_time