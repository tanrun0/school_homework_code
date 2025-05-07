%% 初始化种群  
% 目标函数：y = 2*r2*alpha1 + r2*alpha2（要求最小值）  
% 约束条件：sin(alpha1) = 1/2*sin(alpha2)  
% 变量范围：alpha1, alpha2 ∈ [0, 2*pi], r2 ∈ [0, 2.25]  
  
clc;  
clear;  
close all;  
  
f = @(alpha1, alpha2, r2) 2*r2.*alpha1 + r2.*alpha2; % 目标函数表达式  
penalty_factor = 1e3; % 罚函数因子  
  
N = 50; % 初始种群个数  
d = 3; % 空间维数（alpha1, alpha2, r2）  
ger = 100; % 最大迭代次数  
limit = [0, 2*pi, 0, 2*pi, 0, 2.25]; % 设置位置参数限制（alpha1, alpha2, r2）  
vlimit = [-1, 1]; % 设置速度限制  
w = 0.8; % 惯性权重  
c1 = 0.5; % 自我学习因子  
c2 = 0.5; % 群体学习因子  
  
% 初始化种群的位置和速度  
x = [limit(1) + (limit(2) - limit(1)) * rand(N, 1), ...  
     limit(3) + (limit(4) - limit(3)) * rand(N, 1), ...  
     limit(5) + (limit(6) - limit(5)) * rand(N, 1)];  
v = rand(N, d) * (vlimit(2) - vlimit(1)) + vlimit(1); % 初始种群的速度  
  
% 初始化个体和种群的历史最佳位置和适应度  
xm = x; % 每个个体的历史最佳位置  
ym = zeros(1, d); % 种群的历史最佳位置  
fxm = inf(N, 1); % 每个个体的历史最佳适应度（初始化为无穷大）  
fym = inf; % 种群历史最佳适应度（初始化为无穷大）  
  
% 绘制初始状态图  
figure(1);  
hold on;  
scatter3(x(:,1), x(:,2), x(:,3), 'ro');  
title('初始状态图');  
xlabel('alpha1');  
ylabel('alpha2');  
zlabel('r2');  
grid on;  

%% 群体更新  
iter = 1;  
record = zeros(ger, 1); % 记录器  
while iter <= ger  
    % 计算个体当前适应度（包括罚函数）  
    alpha1 = x(:, 1);  
    alpha2 = x(:, 2);  
    r2 = x(:, 3);  
    penalty = penalty_factor * abs(sin(alpha1) - 0.5 * sin(alpha2));  
    fx = f(alpha1, alpha2, r2) + penalty;  
      
    % 更新个体历史最佳位置和适应度  
    for i = 1:N  
        if fxm(i) > fx(i)  
            fxm(i) = fx(i);  
            xm(i,:) = x(i,:);  
        end  
    end  
      
    % 更新种群历史最佳位置和适应度  
    [min_fxm, nmin] = min(fxm);  
    if fym > min_fxm  
        fym = min_fxm;  
        ym = xm(nmin, :);  
    end  
      
    % 速度更新  
    v = v * w + c1 * rand(N, d) .* (xm - x) + c2 * rand(N, d) .* (repmat(ym, N, 1) - x);  
      
    % 边界速度处理  
    v(v > vlimit(2)) = vlimit(2);  
    v(v < vlimit(1)) = vlimit(1);  
      
    % 位置更新  
    x = x + v;  
      
    % 边界位置处理  
    x(:,1) = max(min(x(:,1), limit(2)), limit(1));  
    x(:,2) = max(min(x(:,2), limit(4)), limit(3));  
    x(:,3) = max(min(x(:,3), limit(6)), limit(5));  
      
    % 记录最大值（这里记录的是最小值，但由于我们之前将问题转化为求最大值的形式，所以这里仍然用record来存储）  
    record(iter) = fym;  
      
    % 绘制状态位置变化图（可选，根据需要决定是否绘制）  
    % ...（省略绘制代码，以提高运行效率）  
      
    iter = iter + 1;  
end  
  
% 绘制收敛过程图  
figure(2);  
plot(record);  
title('收敛过程');  
xlabel('迭代次数');  
ylabel('最佳适应度');  
grid on;  
  
% 绘制最终状态位置图  
figure(3);  
scatter3(x(:,1), x(:,2), x(:,3), 'ro');  
hold on;  
scatter3(ym(1), ym(2), ym(3), 'b*');  
title('最终状态位置');  
xlabel('alpha1');  
ylabel('alpha2');  
zlabel('r2');  
legend({'种群位置', '最佳位置'}, 'Location', 'Best');  
grid on;  
  
% 输出最大值和变量取值  
disp(['最小值：', num2str(fym)]);  
disp(['变量取值：', 'alpha1 = ' num2str(ym(1)), ' alpha2 = ' num2str(ym(2)), ' r2 = ' num2str(ym(3))]);
