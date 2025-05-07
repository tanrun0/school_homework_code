%% 阿基米德螺线 + 画散点图（问题一可视化）
% % 参数设置，确保单位为米  
% a = 0; % 起始半径，单位为米  
% b_spacing = 0.55; % 螺线间距，单位为米  
% b = b_spacing / (2 * pi); % 螺线参数 b，单位为米/弧度  
% 
% % 定义极角范围，为了绘制完整的螺线，我们可以取一个较大的弧度范围  
% theta = linspace(0, 22 * 2 * pi, 1000);  % 从0到多个2π，1000个点，弧度为单位（注意这里你写了21*2*pi，但注释说是10π，根据需要调整）  
% 
% % 计算径向距离，单位为米  
% r = a + b * theta;  
% 
% % 将极坐标转换为笛卡尔坐标，单位为米  
% x = r .* cos(theta);  
% y = r .* sin(theta);  
% 
% % 绘制螺线图  
% figure;  
% plot(x, y, 'g', 'LineWidth', 1.5);  
% hold on; % 保持当前图形  
% 
% % 假设你的二维数组是data，其中第一列是横坐标，第二列是纵坐标  
% % 这里我们创建一个示例数据数组  
% load chu_x_y.mat
% 
% 
% % 绘制散点图  
% % scatter(chu_x_y(:,1), chu_x_y(:,2), 15, 'yo', 'filled'); % 使用黄色圆点填充,这个3是尺寸 
% plot(chu_x_y(:,1), chu_x_y(:,2), '-bo', 'MarkerSize', 6, 'MarkerFaceColor', 'none', 'LineWidth', 1.5); 
% scatter(chu_x_y(1,1), chu_x_y(1,2), 25, 'ro', 'filled'); % 使用红色圆点填充
% 
% % 设置图形标题和坐标轴标签  
% title('阿基米德螺线与散点图 (a = 0m, 螺线间距 = 0.55m)');  
% xlabel('x (m)');  
% ylabel('y (m)');  
% axis equal;  % 确保坐标轴比例正确，单位为米  
% grid on;  
% 
% % 设置坐标轴刻度，使其更易于阅读（可选）  
% % 根据螺线的范围和需要，您可以调整这些值  
% xticks(-10:1:10);  
% yticks(-10:1:10);  
% 
% hold off; % 释放当前图形保持



%% 问题二：某一秒，对应的整条龙（改时间300即可）（阿基米德螺线+画长方形）
% 
% zuobiaotest = zeros(5,2,223);
% t = 414;  % 表格第414个数据，是时间413
% % 第300秒时，对应的整条龙
% 
% % 先单独计算整条龙 
%     qian = [x_y(1,t),x_y(2,t)];
%     hou = [x_y(3,t),x_y(4,t)]; 
% 
%     % 计算直线斜率
%     slope = (hou(2) - qian(2)) / (hou(1) - qian(1));
%     degrees = 90 - atand(slope) ;   % 得到与x轴夹角，90 - 夹角就是需要转动的度数
% 
% 
%     zhong = [(qian(1)+hou(1))/2,(qian(2)+hou(2))/2];
% 
%     % 创造与x轴和y轴平行的长方形（四个点）
%     a = [zhong(1) - 0.15, zhong(2) + 1.705];
%     b = [zhong(1) - 0.15, zhong(2) - 1.705];
%     c = [zhong(1) + 0.15, zhong(2) - 1.705];
%     d = [zhong(1) + 0.15, zhong(2) + 1.705];
% 
%     % 旋转长方形，得到原来龙头的四个点的坐标
%     zuobiaotest(1:4,:,1) = xuanzhuan([a;b;c;d],degrees,zhong);
% 
%     zuobiaotest(5,:,1) = zuobiaotest(1,:,1); % 把第一个点赋值一遍，方便可视化
% 
% for i = 2:223
%     qian = [x_y(2*i-1 ,t),x_y(2*i,t)];
%     hou = [x_y(2*i+1,t),x_y(2*i+2,t)]; 
% 
%     % 计算直线斜率
%     slope = (hou(2) - qian(2)) / (hou(1) - qian(1));
%     degrees = 90 - atand(slope) ;   % 得到与x轴夹角，90 - 夹角就是需要转动的度数
% 
% 
%     zhong = [(qian(1)+hou(1))/2,(qian(2)+hou(2))/2];
% 
%     % 创造与x轴和y轴平行的长方形（四个点）
%     a = [zhong(1) - 0.15, zhong(2) + 1.1];
%     b = [zhong(1) - 0.15, zhong(2) - 1.1];
%     c = [zhong(1) + 0.15, zhong(2) - 1.1];
%     d = [zhong(1) + 0.15, zhong(2) + 1.1];
% 
%     % 旋转长方形，得到原来龙头的四个点的坐标
%     zuobiaotest(1:4,:,i) = xuanzhuan([a;b;c;d],degrees,zhong);
%     zuobiaotest(5,:,i) = zuobiaotest(1,:,i); % 把第一个点赋值一遍，方便可视化
% 
% end
% 
% 
% % 参数设置，确保单位为米  
% a = 0; % 起始半径，单位为米  
% b_spacing = 0.55; % 螺线间距，单位为米  
% b = b_spacing / (2 * pi); % 螺线参数 b，单位为米/弧度  
% 
% % 定义极角范围，为了绘制完整的螺线，我们可以取一个较大的弧度范围  
% theta = linspace(0, 21 * 2 * pi, 1000);  % 从0到多个2π，1000个点，弧度为单位  
% 
% % 计算径向距离，单位为米  
% r = a + b * theta;  
% 
% % 将极坐标转换为笛卡尔坐标，单位为米  
% x = r .* cos(theta);  
% y = r .* sin(theta);  
% 
% % 绘制螺线图  
% figure;  
% plot(x, y, 'b', 'LineWidth', 1.5);  
% hold on; % 保持当前图形  
% 
% 
% 
% for i = 1:223
%     plot(zuobiaotest(:,1,i), zuobiaotest(:,2,i), 'r-', 'LineWidth', 1.5);  
% end
% 
% % % 长方形的顶点坐标  
% % rectangle_points = [  
% %     8.5624    0.3033
% %     8.8979    2.4775
% %     8.6014    2.5233
% %     8.2659    0.3490  
% %     8.5624    0.3033; % 闭合长方形，重复第一个点  
% % ];  
% 
% % % 绘制长方形  
% % plot(rectangle_points(:,1), rectangle_points(:,2), 'r-', 'LineWidth', 1.5);  
% 
% % 设置图形标题和坐标轴标签  
% title('阿基米德螺线与长方形 (a = 0m, 螺线间距 = 0.55m)');  
% xlabel('x (m)');  
% ylabel('y (m)');  
% axis equal;  % 确保坐标轴比例正确，单位为米  
% grid on;  
% 
% % 设置坐标轴刻度，使其更易于阅读（可选）  
% % 根据螺线的范围和需要，您可以调整这些值  
% xticks(-10:1:10);  
% yticks(-10:1:10);  
% 
% hold off; % 释放当前图形保持


%%
% 
% 示例判断函数  
    
    wide = 0.4171376;
    b = wide / (2*pi); % 参数

    r_theta_3 = zeros(224,2); % 用来保存r和theta，每一行保存一组
    x_y_3 = zeros(224,2); % 用来保存x和y，每一行保存一组

    r_theta_3(1,:) = [r,r/b]; % 先保存龙头的r和theta
    x_y_3(1,:) = [r*cos(r_theta_3(1,2)), r*sin(r_theta_3(1,2))];  % 龙头前把手盘入极限点(笛卡尔坐标系)

    %% 生成坐标
    % 已知龙头前把手的坐标，利用question1建立的模型，求解龙身及龙尾的坐标
    for i = 1:223
        if i == 1
            r_theta_3(i+1,:) = f2(r_theta_3(i,1),r_theta_3(i,2), b, 2.86);
        else
            r_theta_3(i+1,:) = f2(r_theta_3(i,1),r_theta_3(i,2), b, 1.65);
        end
    end

    % 生成笛卡尔坐标系下的坐标
    for i = 1:224
        x_y_3(i,:) = [r_theta_3(i,1)*cos(r_theta_3(i,2)), r_theta_3(i,1)*sin(r_theta_3(i,2))];
    end
    
    

    %% 再利用第二问建立的模型，判断该时刻是否会相撞

    zuobiao3 = zeros(5,2,224); % 存放坐标

    % 龙头长度不一样，单独计算
    qian = [x_y_3(1,1),x_y_3(1,2)];
    hou = [x_y_3(2,1),x_y_3(2,2)]; 

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
    zuobiao3(1:4,:,1) = xuanzhuan([a;b;c;d],degrees,zhong);
    zuobiao3(5,:,1) = zuobiao3(1,:,1); % 把第一个点赋值一遍，方便可视化



    for i = 2:223
        qian = [x_y_3(i,1),x_y_3(i,2)];
        hou = [x_y_3(i+1,1),x_y_3(i+1,2)]; 
    
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
        zuobiao3(1:4,:,i) = xuanzhuan([a;b;c;d],degrees,zhong);
        zuobiao3(5,:,i) = zuobiao3(1,:,i); % 把第一个点赋值一遍，方便可视化

    end



