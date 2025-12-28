// 在 class_ 类中添加的方法
List<Expression> class_::GetActuals() {
    return this->actuals;
}

// 在 typcase_class 中添加的方法
List<branch_class*> typcase_class::GetCases() {
    return cases;
}

// 在 branch_class 中添加的方法
Symbol branch_class::GetType() {
    return type_decl;
}

Symbol branch_class::GetName() {
    return name;
}

Expression branch_class::GetExpr() {
    return expr;
}