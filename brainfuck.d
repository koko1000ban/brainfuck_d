#!/usr/bin/env dmd -run

import std.stdio;
import std.conv;

void parse(string source){
  const ulong len = source.length;
  byte[30000] bytes;
  int ptr;
  int depth=-1;
  bytes=0;
  for(int i=0;i<len;++i){
    switch(source[i]){
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
          depth = 1;
          while(i<len  && depth != 0) {
            ++i;
            switch(source[i]){
              case '[': ++depth; break;
              case ']': --depth; break;
              default: break;
            }
          }
        }
        break;
      case ']':
        if (bytes[ptr] != 0) {
          depth = -1;
          while(i>0  && depth != 0) {
            --i;
            switch(source[i]){
              case '[': ++depth; break;
              case ']': --depth; break;
              default: break;
            }
          }
        }
        break;
      default:
        break;
    }
  }
}

int main(string[] args) {
  if (args.length == 1) {
    writef("usage: %s <SOURCE FILE>\n",  "brainfuck.d");
    return 1;
  }
  
  auto fpath = args[1];
  if (!std.file.exists(fpath)) {
    writef("file not found:%s\n", fpath);
    return 1;
  }
  
  parse(std.file.readText(fpath));
  return 0;
}