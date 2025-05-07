a = 0;  
num_turns = 20; % 螺线绕的圈数  
arc_length = 1.65; % 每两个点之间的弧长，单位为米  

% 初始化  
theta_start_17th_turn = (num_turns - 4) * 2 * pi; % 第17圈起始点的极角

b = 0.55; % 螺线距

% 存储点的坐标
points_theta = [];  
points_r = [];  

% 从第17圈的起始点开始计算
current_theta = theta_start_17th_turn;  
current_r = a + b * current_theta; % 计算当前半径  

% 初始化第一个点
points_theta = [points_theta, current_theta];  
points_r = [points_r, current_r];  

% 循环添加点，直到达到所需的螺线长度或极角限制
while true

    increment_theta = acosd((current_r^2 + arc_length^2 - (current_r + b)^2) / (2 * current_r * arc_length));   
    if current_theta + increment_theta > num_turns * 2 * pi  
        break; % 如果超出第num_turns圈，则停止添加点  
    end  

    next_theta = current_theta + increment_theta;  
    next_r = a + b * next_theta;  

    % 添加下一个点到列表中  
    points_theta = [points_theta, next_theta];  
    points_r = [points_r, next_r];  

    % 更新当前点的信息为下一个点  
    current_theta = next_theta;  
    current_r = next_r;  
end

% 绘制螺线和点  
theta = linspace(0, num_turns * 2 * pi, 1000); % 用于绘制螺线的极角数组  
r = a + b * theta; % 计算螺线的极径数组
polarplot(theta, r, 'LineWidth', 1.5); % 绘制螺线  
hold on; % 保持当前图形，以便在同一幅图上绘制点
scatter(points_theta, points_r, 'filled'); % 绘制点，使用实心标记 

ax = gca;

ax.RLim = [0 max(r)]; % 设置极径的范围  
ax.ThetaTickLabel = {}; % 隐藏极角的刻度标签

hold on;



