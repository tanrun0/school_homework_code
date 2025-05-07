% 传入龙头的长方形和龙身的长方形，判断会不会相碰
% 传入的是坐标，每一行是一个点
function pong = is_pong(tou,shen)
    shen = [shen;shen(1,:)]; % 先把shen扩张成5行，方便后面投影判断
    pong = false;
    v_shen = [shen(2,:)-shen(1,:);shen(3,:)-shen(2,:);shen(4,:)-shen(3,:);shen(1,:)-shen(4,:)];  % 生成由龙身产生的向量
    for i = 1:4  % 一次循环判断一个点
        result = zeros(1,4); % 用来存放叉乘以后的结果
        v_tou = [tou(i,:)-shen(1,:);tou(i,:)-shen(2,:);tou(i,:)-shen(3,:);tou(i,:)-shen(4,:)];
        for j = 1:4
            result(j) = cross2D(v_tou(j,:),v_shen(j,:)); % 一次叉乘结果
            if result(j) == 0
                t = sum((tou(j,:)-shen(j,:)).*(tou(j,:)-shen(j+1,:)))/(norm(shen(j+1,:)-shen(j,:))^2);
                    if( t > 0 && t < 1)
                        pong = true;
                        return;
                    end
            end
        end
      
        if all(result > 0) || all(result < 0)
            pong = true;
            return;
        end
    end
end 


