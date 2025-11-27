(*
 * COOL (Classroom Object-Oriented Language) 综合语法测试程序
 *
 * 这个文件旨在覆盖CS143课程中COOL语言的大部分语法特性，
 * 以便对编译器（词法分析、语法分析、语义分析、代码生成）进行全面的测试。
 *
 * 它包含了嵌套注释 (* 这是一个嵌套注释 *)。
 *)

-- 定义一个基础的 Shape 类
class Shape {
    x : Int <- 0;
    y : Int <- 0;
    name : String <- "Generic Shape";

    -- 初始化方法，返回 SELF_TYPE 以支持链式调用或子类正确返回
    init(newX : Int, newY : Int, newName : String) : SELF_TYPE {
        {
            x <- newX;
            y <- newY;
            name <- newName;
            self; -- 返回当前对象
        }
    };

    -- 一个将被子类覆盖的方法
    get_type_name() : String {
        name
    };

    -- 打印形状信息的方法，使用了IO中的方法
    print_info(io : IO) : IO {
        {
            io.out_string("Shape<").out_string(name).out_string(">");
            io.out_string(" at (").out_int(x).out_string(", ").out_int(y).out_string(")\n");
        }
    };
};

-- Circle 类继承自 Shape 类
class Circle inherits Shape {
    radius : Int; -- 未初始化的属性，默认为 0

    -- 覆盖父类的 get_type_name 方法
    get_type_name() : String {
        "Circle"
    };

    -- Circle 特有的方法，用于计算面积
    -- 这里使用了 let 绑定来定义一个局部变量 pi
    area() : Int {
        let pi_times_100 : Int <- 314 in
            (pi_times_100 * radius * radius) / 100
    };

    -- Circle 的初始化方法，它调用了父类的初始化方法
    init_circle(newX : Int, newY : Int, newR : Int) : SELF_TYPE {
        {
            init(newX, newY, "A Circle Object"); -- 调用父类的 init 方法
            radius <- newR;
            self;
        }
    };
};

-- Main 类是程序的入口，它继承了 IO 类以使用输入输出功能
class Main inherits IO {

    -- 这是一个未初始化的属性，它的值将是 void
    void_object : Object;

    main() : Object {
        {
            out_string("--- COOL Comprehensive Syntax Test Start ---\n\n");

            -- 1. 测试类的创建、let绑定、动态分派和方法覆盖
            out_string("1. Testing Class, Let, Dispatch, and Overriding...\n");
            let my_circle : Circle <- (new Circle).init_circle(10, 20, 5) in {
                my_circle.print_info(self); -- 动态分派，调用 Shape 的方法
                out_string("  - My dynamic type is: ").out_string(my_circle.get_type_name()).out_string("\n"); -- 动态分派，调用 Circle 的方法
                
                -- 2. 测试静态分派
                out_string("  - My static type (as Shape) is: ").out_string(my_circle@Shape.get_type_name()).out_string("\n\n"); -- 静态分派，强制调用 Shape 的方法
            };

            -- 3. 测试循环、条件语句和算术运算
            out_string("2. Testing While loop, If-Else, and Arithmetic...\n");
            let counter : Int <- 5, result : Int <- 1 in {
                while 0 < counter loop {
                    result <- result * counter;
                    counter <- counter - 1;
                } pool;
                out_string("  - Factorial of 5 is: ").out_int(result).out_string("\n");

                if result = 120 then
                    out_string("  - Factorial test PASSED.\n\n")
                else
                    out_string("  - Factorial test FAILED.\n\n")
                fi;
            };

            -- 4. 测试 case 表达式，用于运行时类型识别
            out_string("3. Testing Case expression...\n");
            let s : Shape <- new Shape,
                c : Circle <- new Circle,
                o : Object <- self -- o 是一个 Main 类型的对象
            in {
                test_object_type(s);
                test_object_type(c);
                test_object_type(o);
            };

            -- 5. 测试 isvoid 和 not 运算符
            out_string("\n4. Testing 'isvoid' and 'not' operators...\n");
            if isvoid void_object then
                out_string("  - 'void_object' is void, as expected.\n")
            else
                out_string("  - 'void_object' is not void. (Error)\n")
            fi;

            if not (isvoid self) then
                out_string("  - 'self' is not void, as expected.\n\n")
            else
                out_string("  - 'self' is void. (Error)\n\n")
            fi;

            -- 6. 测试其他表达式：块、整数取反
            out_string("5. Testing other expressions (blocks, negation)...\n");
            let x : Int <- {
                out_string("  - This is inside a block expression.\n");
                100; -- 块的值是最后一个表达式的值
            } in {
                out_string("  - Block evaluated to: ").out_int(x).out_string("\n");
                out_string("  - Negative of 10 is: ").out_int(~10).out_string("\n");
            };

            out_string("\n--- Test End ---\n");
        }
    };

    -- 一个辅助方法，用来演示 case 表达式
    test_object_type(obj : Object) : Object {
        {
            out_string("  - Analyzing an object's type: ");
            case obj of
                circ : Circle => out_string("It is a Circle.\n");
                shp : Shape => out_string("It is a Shape (but not a Circle).\n");
                mn : Main => out_string("It is the Main object.\n");
                obj : Object => out_string("It is some other generic Object.\n");
            esac;
        }
    };
};