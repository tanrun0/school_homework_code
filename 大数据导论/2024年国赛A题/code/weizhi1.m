


% r = a + b * theta; 螺线方程, 初始a = 0, b = 0.55/2*pi, theta是相对于原点的

theta0 = 2*pi*16;
b = 0.55/(2*pi); % b = 螺距/(2*pi)
a = 0; % 起始半径（起始点距离原点的距离）
s = 1; % 龙头1s内走过的弧长
theta_upper = 16*2*pi;
result1 = zeros(448,301); % 存放x，y坐标
result_r = zeros(448,301); % 存放r和theta

% 初始化龙头的0时刻位置
result_r(1,1) = 8.8;
result_r(2,1) = 16*2*pi;
result1(1,1) = 8.8 * cos(16*2*pi);
result1(2,1) = 0;


% 求解各时刻龙头的位置（理想的，有可能会相撞）
for t = 1:300

    theta = f1(a,b,theta_upper,1);
    r = a + b * theta;
    result_r(1,t+1) = r;
    result_r(2,t+1) = theta; 

    x = r * cos(theta);
    y = r * sin(theta);
    result1(1,t+1) = x;
    result1(2,t+1) = y;
    theta_upper = theta;

end


%% 单独算出第一节龙身
for t = 1:301
    X = f2(result_r(1,t), result_r(2,t), b, 2.86);

    result_r(3,t) = X(1);
    result_r(4,t) = X(2);

    x = X(1) * cos(X(2));
    y = X(1) * sin(X(2));
    result1(3,t) = x;
    result1(4,t) = y;

end

%% 循环，利用前把手的位置算出下一个把手的位置
for i = 2:223
    for t = 1:301
    X = f2(result_r(2*i-1,t), result_r(2*i,t), b, 1.65);

    result_r(2*i+1,t) = X(1);  
    result_r(2*i+2,t) = X(2);

    x = X(1) * cos(X(2));
    y = X(1) * sin(X(2));
    result1(2*i+1,t) = x;
    result1(2*i+2,t) = y;
    end
end
