function t = found_t(time_0,time_t,shen_0,shen_t,zuobiao)
    % 坐标是一个四维数组

    for t = time_0:time_t
        for i = shen_0:shen_t
            if is_pong(zuobiao(1:4,:,t-350,1),zuobiao(1:4,:,t-350,i))
                return; % 找到了直接返回，返回结果是时间+1
            end
        end
    end
    
end

