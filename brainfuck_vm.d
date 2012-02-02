#!/usr/bin/env dmd -run

import std.stdio;
import std.conv;
import std.array;

struct code {
  char op;
  int jump;
}

code[] parse(string source) {
  code[] codes;
  auto codeapp = appender(codes);
  int[] stack;
  
  foreach(op; source){
    code code;
    code.op=op;
    final switch(code.op){
      case '>', '<', '+', '-', '.', ',':
        codeapp.put(code);
        break;
      case '[':
        stack ~= to!int(codeapp.data.length);
        codeapp.put(code);
        break;
      case ']':
        auto start = stack.back();
        stack.popBack();
        codeapp.data[start].jump = to!int(codeapp.data.length);
        code.jump = start - 1;
        codeapp.put(code);
        break;
    }
  }
  code c;
  c.op='\0';
  codeapp.put(c);
  
  return codeapp.data;
}

void execute(code[] codes) {
  byte[30000] bytes;
  int ptr;
  
  for(int i=0;;++i) {
    code c = codes[i];
    final switch(c.op){
      case '>':
        ++ptr;
        break;
      case '<':
        --ptr;
        break;
      case '+':
        ++bytes[ptr];
        break;
      case '-':
        --bytes[ptr];
        break;
      case '.':
        write(to!char(bytes[ptr]));
        break;
      case ',':
        bytes[ptr] = to!byte(std.c.stdio.getchar());
        break;
      case '[':
        if (bytes[ptr] == 0) {
          i=c.jump;
        }
        break;
      case ']':
        if (bytes[ptr] != 0) {
          i=c.jump;
        }
        break;
      case '\0':
        return;
    }
  }
}

int main(string[] args) {
  if (args.length == 1) {
    writef("usage: %s <SOURCE FILE>\n",  "brainfuck_vm.d");
    return 1;
  }
  
  auto fpath = args[1];
  if (!std.file.exists(fpath)) {
    writef("file not found:%s\n", fpath);
    return 1;
  } 
  
  auto codes = parse(std.file.readText(fpath));
  execute(codes);

  return 0;
}