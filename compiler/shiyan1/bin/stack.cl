class StackNode {
    element : Object;
    next : StackNode;

    init(val : Object, n : StackNode) : StackNode {
        {
            element <- val;
            next <- n;
            self;
        }
    }
};

class Stack inherits IO {
    top : StackNode;
    size : Int;

    init() : Stack {
        {
            top <- void;
            size <- 0;
            self;
        }
    }

    push(item : Object) : Stack {
        {
            top <- (new StackNode).init(item, top);
            size <- size + 1;
            self;
        }
    }

    pop() : Object {
        if isEmpty() then
            {
                out_string("Error: Stack is empty, cannot pop.\n");
                void;
            }
        else
            let temp : StackNode <- top in {
                top <- top.next;
                size <- size - 1;
                temp.element;
            }
        fi
    }

    peek() : Object {
        if isEmpty() then
            {
                out_string("Error: Stack is empty, cannot peek.\n");
                void;
            }
        else
            top.element;
        fi
    }

    isEmpty() : Bool {
        size = 0
    }

    print() : Stack {
        {
            let current : StackNode <- top, count : Int <- 0 in
                while count < size loop {
                    out_string(current.element);
                    out_string("\n");
                    current <- current.next;
                    count <- count + 1;
                } pool;
            self;
        }
    }
};

class Main inherits IO {
    main() : Object {
        {
            let s : Stack <- (new Stack).init() in {
                s.push("A");
                s.push("B");
                s.push("C");

                out_string("Stack after pushing A, B, C:\n");
                s.print();

                out_string("Peek: ");
                out_string(s.peek());
                out_string("\n");

                out_string("Pop: ");
                out_string(s.pop());
                out_string("\n");

                out_string("Stack after popping:\n");
                s.print();
            }
        }
    }
};