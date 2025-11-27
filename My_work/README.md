# Simple COOL parser demo

This submission contains a simplified COOL parser and lexer to demonstrate building a parser using Bison and Flex.

Build and run:

```powershell
cd submission
make
./parser ..\good.cl
```

Files:
- `lexer.l` - Flex lexer
- `parser.y` - Bison grammar and parser
- `Makefile` - build script
- `report_final.tex` - filled-in report

Notes:
- This is a simplified parser for demonstration and educational purposes; it does not implement the entire COOL AST and runtime environment.
- We implemented a minimal AST and printing to validate parsing correctness on sample input files `good.cl`, `bad.cl`, `stack.cl`.
