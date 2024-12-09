file_name = "practice_6.csv"

% Header 작성
header = ["Time (s)", "X (mm)", "Y (mm)"];

% 데이터 결합
csvData = [simout.Time, simout.Data]; % [Time, X, Y] 형태

% CSV 파일로 저장
writematrix(header, file_name);       % 먼저 헤더를 저장
writematrix(csvData, file_name, 'WriteMode', 'append'); % 데이터 추가 저장

% 저장 완료 메시지
disp('CSV 파일이 {file_name}로 저장되었습니다.');
