load r_theta.mat
load x_y.mat
load sudu500.mat


%% 先用第一问代码跑500个点的位置
% % r = a + b * theta; 螺线方程, 初始a = 0, b = 0.55/2*pi, theta是相对于原点的
% 
% theta0 = 2*pi*16;
% b = 0.55/(2*pi); % b = 螺距/(2*pi)
% a = 0; % 起始半径（起始点距离原点的距离）
% s = 1; % 龙头1s内走过的弧长
% theta_upper = 16*2*pi;
% result1 = zeros(448,501); % 存放x，y坐标
% result_r = zeros(448,501); % 存放r和theta
% 
% % 初始化龙头的0时刻位置
% result_r(1,1) = 8.8;
% result_r(2,1) = 16*2*pi;
% result1(1,1) = 8.8 * cos(16*2*pi);
% result1(2,1) = 0;
% 
% 
% % 求解各时刻龙头的位置（理想的，有可能会相撞）
% for t = 1:500
% 
%     theta = f1(a,b,theta_upper,1);
%     r = a + b * theta;
%     result_r(1,t+1) = r;
%     result_r(2,t+1) = theta; 
% 
%     x = r * cos(theta);
%     y = r * sin(theta);
%     result1(1,t+1) = x;
%     result1(2,t+1) = y;
%     theta_upper = theta;
% 
% end
% 
% 
% %% 单独算出第一节龙身
% for t = 1:501
%     X = f2(result_r(1,t), result_r(2,t), b, 2.86);
% 
%     result_r(3,t) = X(1);
%     result_r(4,t) = X(2);
% 
%     x = X(1) * cos(X(2));
%     y = X(1) * sin(X(2));
%     result1(3,t) = x;
%     result1(4,t) = y;
% 
% end
% 
% %% 循环，利用前把手的位置算出下一个把手的位置
% for i = 2:223
%     for t = 1:501
%     X = f2(result_r(2*i-1,t), result_r(2*i,t), b, 1.65);
% 
%     result_r(2*i+1,t) = X(1);  
%     result_r(2*i+2,t) = X(2);
% 
%     x = X(1) * cos(X(2));
%     y = X(1) * sin(X(2));
%     result1(2*i+1,t) = x;
%     result1(2*i+2,t) = y;
%     end
% end

%% 用第一问代码跑500个点的速度
% load r_theta.mat
% load x_y.mat
% result2 = zeros(224,500);
% deta_t = 1;
% result2(1,:) = ones(1,500); 
% % t = 0s 时的速度
% for i = 2:224
%     x = x_y(2*i-1,2) - x_y(2*i-1,1);  % 1s-0s
%     y = x_y(2*i,2) - x_y(2*i,1); 
%     result2(i,1) = sqrt(x^2 + y^2)/deta_t;
% end
%
% for t = 2:500
%     for i = 2:224
%         x = x_y(2*i-1,t+1) - x_y(2*i-1,t-1);
%         y = x_y(2*i,t-1) - x_y(2*i,t+1);
%         result2(i,t) = sqrt(x^2 + y^2)/2*deta_t;
%     end
% 
% end
% 
% % 计算第500s的速度
% for i = 2:224
%     x = x_y(2*i-1,501) - x_y(2*i-1,500);  % 300s-299s
%     y = x_y(2*i,501) - x_y(2*i,500); 
%     result2(i,301) = sqrt(x^2 + y^2)/deta_t;
% end


%% 计算出每个时刻，各个龙身or龙头的长方形坐标
%% 考虑从第350秒开始，到第449秒会不会相撞，且若相撞，只有可能与前面（即内圈），越往内盘入，单个圈的龙身就越少
%% 第一问附带求出了0时刻时，龙身的分布情况，起始时刻在第16圈的入口，第143节龙身的弧度角为113.09，大于18*2*pi，所以只有可能与前143节龙身相碰，且不能算第二个龙头

qian = zeros(1,2); % 前把手坐标
hou = zeros(1,2);  % 后把手坐标
zhong = zeros(1,2); % 中心点坐标
zuobiao = zeros(5,2,100,223); % 得到坐标


% 先单独计算龙头
for t = 351:450   % 第351个数，对应的是第350秒
    qian = [x_y(1,t),x_y(2,t)];
    hou = [x_y(3,t),x_y(4,t)]; 

    % 计算直线斜率
    slope = (hou(2) - qian(2)) / (hou(1) - qian(1));
    degrees = 90 - atand(slope) ;   % 得到与x轴夹角，90 - 夹角就是需要转动的度数


    zhong = [(qian(1)+hou(1))/2,(qian(2)+hou(2))/2];

    % 创造与x轴和y轴平行的长方形（四个点）
    a = [zhong(1) - 0.15, zhong(2) + 1.705];
    b = [zhong(1) - 0.15, zhong(2) - 1.705];
    c = [zhong(1) + 0.15, zhong(2) - 1.705];
    d = [zhong(1) + 0.15, zhong(2) + 1.705];

    % 旋转长方形，得到原来龙头的四个点的坐标
    zuobiao(1:4,:,t - 350,1) = xuanzhuan([a;b;c;d],degrees,zhong);
    zuobiao(5,:,t - 350,1) = zuobiao(1,:,t - 350,1); % 把第一个点赋值一遍，方便可视化

end


for t = 351:450
    for i = 2:223
    qian = [x_y(2*i-1 ,t),x_y(2*i,t)];
    hou = [x_y(2*i+1,t),x_y(2*i+2,t)]; 

    % 计算直线斜率
    slope = (hou(2) - qian(2)) / (hou(1) - qian(1));
    degrees = 90 - atand(slope) ;   % 得到与x轴夹角，90 - 夹角就是需要转动的度数


    zhong = [(qian(1)+hou(1))/2,(qian(2)+hou(2))/2];

    % 创造与x轴和y轴平行的长方形（四个点）
    a = [zhong(1) - 0.15, zhong(2) + 1.1];
    b = [zhong(1) - 0.15, zhong(2) - 1.1];
    c = [zhong(1) + 0.15, zhong(2) - 1.1];
    d = [zhong(1) + 0.15, zhong(2) + 1.1];

    % 旋转长方形，得到原来龙头的四个点的坐标
    zuobiao(1:4,:,t - 350,i) = xuanzhuan([a;b;c;d],degrees,zhong);
    zuobiao(5,:,t - 350,i) = zuobiao(1,:,t - 350,i); % 把第一个点赋值一遍，方便可视化

    end
end

%% 遍历每个时刻下的长方形坐标，判断是否相撞，若果相撞则立刻返回时间

t_peng = found_t(351,450,3,143,zuobiao) - 1;

% 在表中搜索坐标和速度
x_y_s = zeros(224,3);
for i = 1:224
    x_y_s(i,1) = x_y(2*i-1,t_peng+1);
    x_y_s(i,2) = x_y(2*i,t_peng+1);
    x_y_s(i,3) = sudu500(i,t_peng+1);
end
