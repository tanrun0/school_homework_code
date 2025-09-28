class StackNode {
    -- 节点类，用于存储栈中的元素以及指向下一个节点的引用
    element : Object;  -- 存储栈中的元素
    next : StackNode;  -- 指向下一个节点

    -- 初始化节点的构造函数，接受元素值和下一个节点的引用作为参数
    init(val : Object, n : StackNode) : StackNode {
        {
            element <- val;
            next <- n;
            self;
        }
    };
};

class Stack inherits IO {
    top : StackNode;  -- 指向栈顶节点
    size : Int;  -- 记录栈中元素的数量

    -- 初始化栈的构造函数，创建一个空栈
    init() : Stack {
        {
            top <- null;
            size <- 0;
            self;
        }
    };

    -- 将元素压入栈顶的操作
    push(item : Object) : Stack {
        {
            -- 创建一个新节点，该节点的元素为传入的item，下一个节点为当前栈顶top
            top <- (new StackNode).init(item, top); 
            size <- size + 1;  -- 栈的元素数量加1
            self;  -- 返回当前栈对象，方便链式调用
        }
    };

    -- 从栈顶弹出元素的操作
    pop() : Object {
        if isEmpty() then
            -- 如果栈为空，输出错误信息并返回null（这里也可以根据具体需求做其他处理）
            {
                out_string("Error: Stack is empty, cannot pop.\n");
                null;
            }
        else {
            let temp : StackNode <- top in {
                -- 暂存当前栈顶节点
                top <- top.next;  -- 将栈顶指针指向下一个节点
                size <- size - 1;  -- 栈的元素数量减1
                temp.element;  -- 返回被弹出节点的元素
            }
        }
    };

    -- 查看栈顶元素，但不弹出元素的操作
    peek() : Object {
        if isEmpty() then
            -- 如果栈为空，输出错误信息并返回null
            {
                out_string("Error: Stack is empty, cannot peek.\n");
                null;
            }
        else
            top.element;  -- 返回栈顶节点的元素
    };

    -- 判断栈是否为空的操作
    isEmpty() : Bool {
        size = 0  -- 如果栈中元素数量为0，则返回true，否则返回false
    };

    -- 打印栈中所有元素的操作，用于调试和查看栈的内容
    print() : Stack {
        {
            let current : StackNode <- top,
                count : Int <- 0 in
                while count < size loop {
                    out_string(current.element.toString().concat("\n"));  -- 输出当前节点的元素并换行
                    current <- current.next;  -- 移动到下一个节点
                    count <- count + 1;  -- 计数加1
                } pool;
            self;  -- 返回当前栈对象，方便链式调用
        }
    };
};

class Main inherits IO {
    main() : Object {
        let s : Stack <- (new Stack).init() in {
            s.push("A");  -- 向栈中压入元素"A"
            s.push("B");  -- 向栈中压入元素"B"
            s.push("C");  -- 向栈中压入元素"C"

            out_string("Stack after pushing A, B, C:\n");
            s.print();  -- 打印当前栈的内容

            out_string("Peek: ").out_string(s.peek().toString()).out_string("\n");  -- 查看栈顶元素并输出
            out_string("Pop: ").out_string(s.pop().toString()).out_string("\n");  -- 弹出栈顶元素并输出

            out_string("Stack after popping:\n");
            s.print();  -- 打印弹出元素后的栈内容
        }
    };
};