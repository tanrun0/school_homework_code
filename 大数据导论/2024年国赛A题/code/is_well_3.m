% 示例判断函数  
function is_well = is_well_3(wide,r)
    is_well = true;
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


    %% 代入函数，看是否会相撞
    for i = 3:224 % 排除第二个
        if is_pong(zuobiao3(1:4,:,1),zuobiao3(1:4,:,i))
            is_well = false;
            return;
        end
    end

end
    