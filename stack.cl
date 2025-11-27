(*
 *  stack.cl
 *
 *  一个用COOL语言实现的通用栈数据结构。
 *  这个栈可以存储任何继承自Object的类型的元素，
 *  但为了演示，我们主要关注Int和String。
 *
 *)

(*
 *  StackNode 类
 *  代表栈中的一个节点。它包含一个数据项(item)和指向下一个节点的指针(next)。
 *  这是一个典型的链表节点实现。
 *)
class StackNode inherits Object {
    item : Object;          -- 节点存储的数据，类型为Object使其通用
    next : StackNode;       -- 指向栈中的下一个节点

    -- 初始化节点
    init(i : Object, n : StackNode) : StackNode {
        {
            item <- i;
            next <- n;
            self;
        }
    };

    -- 返回节点的数据
    getItem() : Object {
        item
    };

    -- 返回下一个节点
    getNext() : StackNode {
        next
    };
};


(*
 *  Stack 类
 *  实现了栈的核心功能。内部使用StackNode构成的链表来存储数据。
 *  栈顶由属性'top'表示。
 *)
class Stack inherits IO {
    top : StackNode;  -- 指向栈顶的节点，如果栈为空，则为 void

    -- isEmpty(): 检查栈是否为空
    -- 如果 top 是 void，说明栈里没有节点。
    isEmpty() : Bool {
        isvoid top
    };

    -- push(item: Object): 将一个元素压入栈顶
    -- 创建一个新节点，让它指向旧的栈顶，然后更新栈顶为这个新节点。
    push(item : Object) : SELF_TYPE {
        {
            let new_node : StackNode <- (new StackNode).init(item, top) in
                top <- new_node;
            self;
        }
    };

    -- peek(): 返回栈顶元素，但不移除它
    -- 如果栈为空，则中止程序并报错。
    peek() : Object {
        if isEmpty() then
            {
                out_string("Error: peek from an empty stack.\n");
                abort();
                new Object; -- abort()会中止程序, 这行是为了让类型检查器满意
            }
        else
            top.getItem()
        fi
    };

    -- pop(): 移除并返回栈顶元素
    -- 如果栈为空，则中止程序并报错。
    pop() : Object {
        if isEmpty() then
            {
                out_string("Error: pop from an empty stack.\n");
                abort();
                new Object; -- 同样，这行是为了通过类型检查
            }
        else
            let item_to_return : Object <- top.getItem() in
            {
                top <- top.getNext();
                item_to_return;
            }
        fi
    };

    -- print(): 打印栈内所有元素，从栈顶到栈底
    -- 使用一个循环遍历所有节点，并根据类型打印。
    print() : SELF_TYPE {
      { -- <--- 这里是修正的关键：添加了起始花括号
        if isEmpty() then
            out_string("Stack is empty.\n")
        else
            {
                out_string("---- Top of Stack ----\n");
                let current : StackNode <- top in
                -- 使用循环遍历链表
                while not (isvoid current) loop
                    {
                        -- 使用 case 语句判断元素的具体类型，并调用合适的打印方法
                        case current.getItem() of
                            s : String => { out_string(s); out_string("\n"); };
                            i : Int => { out_int(i); out_string("\n"); };
                            o : Object => out_string("Unprintable Object\n"); -- 兜底情况
                        esac;
                        current <- current.getNext();
                    }
                pool;
                out_string("---- Bottom of Stack ----\n");
            }
        fi;
        self; -- self 作为整个块的返回值，类型是 SELF_TYPE，符合方法签名
      }   -- <--- 这里是修正的关键：添加了结束花括号
    };
};


(*
 *  Main 类
 *  用于测试我们实现的Stack。
 *)
class Main inherits IO {
    main() : Object {
        let my_stack : Stack <- new Stack in
        {
            out_string("--- Stack Demo ---\n\n");

            -- 1. 测试初始状态
            out_string("Is stack empty? ");
            if my_stack.isEmpty() then out_string("Yes\n") else out_string("No\n") fi;
            my_stack.print();
            out_string("\n");

            -- 2. 推入一些元素 (字符串和整数)
            out_string("Pushing 'Alice', 100, 'Bob'...\n");
            my_stack.push("Alice");
            my_stack.push(100);
            my_stack.push("Bob");
            my_stack.print();
            out_string("\n");

            -- 3. 测试 peek
            out_string("Peeking top element: ");
            case my_stack.peek() of
                s : String => out_string(s);
                i : Int => out_int(i);
                o : Object => out_string("Object");
            esac;
            out_string("\n\n");

            -- 4. 弹出一个元素
            out_string("Popping an element...\n");
            my_stack.pop();
            my_stack.print();
            out_string("\n");

            -- 5. 再次检查是否为空
            out_string("Is stack empty? ");
            if my_stack.isEmpty() then out_string("Yes\n") else out_string("No\n") fi;
            out_string("\n");

            -- 6. 全部弹出
            out_string("Popping all elements...\n");
            my_stack.pop();
            my_stack.pop();
            my_stack.print();
            out_string("\n");

            -- 7. 测试在空栈上执行 pop (这将导致程序中止)
            out_string("Now trying to pop from an empty stack...\n");
            my_stack.pop();
            out_string("This line will not be reached.\n");
        }
    };
};

