#ifndef SUDOKU_H
#define SUDOKU_H

#include <string>

// 来着：https://blog.csdn.net/Solstice/article/details/2096209

std::string solveSudoku(const std::string& puzzle);
const int kCells = 81;
extern const char kNoSolution[];

#endif  // SUDOKU_H
