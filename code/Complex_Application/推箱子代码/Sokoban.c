
#pragma GCC push_options
#pragma GCC optimize ("O0")
void start() {
asm("li\tsp,1024\n\t"
    "call main");
}

__attribute__ ((noinline)) void wait(int instr_num) {
    while (instr_num--) ; // 原for已为while，无需修改
}
 
#define BTN_SW_ADDR 0xE0000000
#define VRAM_BASE 0x80000000

#define ROW 8
#define COL 10
#define LEVELS 8



char dirKeys[5]; // 用户设置的上下左右重启按键（不用于实际控制，仅占位）

// 地图符号
#define WALL 0
#define EMPTY 1
#define PLAYER 2
#define BOX 3
#define GOAL 4




void drawMap(char map[ROW][COL]) {
    char* vram = (char*)(0x80000000);
        int k = 1; 
        while (k < 7) { 
            int j = 1; 
            while (j < 9) { 
                int index = (k-1) * 8 + j-1; // 线性偏移地址
                *(vram+index) = map[k][j]; // 写入 1 字节
                // (*((int*)(0xE0000000))) = map[k][j]; // 写入 1 字节
                // wait(100000);
                // *(vram+index) = (char)(k-1); // 写入 1 字节
                j=j+1; // 手动递增循环变量
            }
            k=k+1; // 手动递增循环变量
        }
    (*((int*)0xE0000000)) = 5;
    // wait(10000000);
}


// 判断胜利条件
int checkWin(char map[ROW][COL]) {
    int i = 0; 
    while (i < ROW) { 
        int j = 0; 
        while (j < COL) { 
            if (map[i][j] == GOAL)
                return 0;
            j++; 
        }
        i++; 
    }
    return 1;
}

// 查找人物位置
// void findPlayer(int* map, int* x, int* y) {
//     int i = 0;
//     while (i < ROW) { 
//         int j = 0; 
//         while (j < COL) { 
//             if ((map+COL*i + j) == PLAYER) { // 使用一维数组索引计算
//                 *x = i;
//                 *y = j;
//                 return;
//             }
//             j++; 
//         }
//         i++; 
//     }
// }
// 查找人物位置




//执行一次移动（无for循环，无需修改）
void movePlayer(char map[ROW][COL], int dir) {
    (*((int*)(0xE0000000))) = 6; // 写入 1 字节
    wait(1000000);
    int dx[4]; // 上下左右
    dx[0] = 0;
    dx[1] = 2;
    dx[2] = 1;
    dx[3] = 1;
    int dy[4];
    dy[0] = 1;
    dy[1] = 1;
    dy[2] = 0;
    dy[3] = 2;
    int x=0;
    int y=0;
    // (*((int*)(0xE0000000))) = 7; // 写入 1 字节
    // wait(10000000);
    int i = 0;
    int flag=0;
    while (i < ROW) {
        int j = 0;
        while (j < COL) {
            if (map[i][j] == PLAYER) {
                x = i;
                y = j;
                flag=1;
                break;
            }
            j++;
        }
        i++;
        if(flag==1)break;
    }    
    (*((int*)(0xE0000000))) = 7; // 写入 1 字节
    wait(1000000);
    int nx = x + dx[dir]-1;
    int ny = y + dy[dir]-1;
    int nnx = nx + dx[dir]-1;
    int nny = ny + dy[dir]-1;

    if (map[nx][ny] == WALL)
        return;
    if (map[nx][ny] == EMPTY || map[nx][ny] == GOAL) {
        map[x][y] = EMPTY;
        map[nx][ny] = PLAYER;
    } else if ((map[nx][ny] == BOX) &&
               (map[nnx][nny] == EMPTY || map[nnx][nny] == GOAL)) {
        map[x][y] = EMPTY;
        map[nx][ny] = PLAYER;
        map[nnx][nny] = BOX;
    }
    int k=1;
    while (k < 7) { 
        int j = 1; 
        while (j < 9) { 
            int index = (k-1) * 8 + j-1; // 线性偏移地址
            // (*(vram+index)) = map[k][j]; // 写入 1 字节
            (*((int*)(0xE0000000))) = map[k][j]; // 写入 1 字节
            wait(100000);
            // *(vram+index) = (char)(k-1); // 写入 1 字节
            j=j+1; // 手动递增循环变量
        }
        k=k+1; // 手动递增循环变量
    }
    (*((int*)0xE0000000)) = 7;
    wait(1000000);

}

// 主游戏循环
void playLevel(char level[ROW][COL]) {
    int k = 1; 
    // while (k < 7) { 
    //     int j = 1; 
    //     while (j < 9) { 
    //         int index = (k-1) * 8 + j-1; // 线性偏移地址
    //         // *(vram+index) = levels[i][k][j]; // 写入 1 字节
    //         (*((int*)(0xE0000000))) = level[k][j]; // 写入 1 字节
    //         wait(1000000);
    //         // *(vram+index) = (char)(k-1); // 写入 1 字节
    //         j=j+1; // 手动递增循环变量
    //     }
    //     k=k+1; // 手动递增循环变量
    // }
    char map[ROW][COL];
    for(int i=0;i<ROW;i++)
    {
        for(int j=0;j<COL;j++)
        {
            map[i][j]=level[i][j];
        }
    }
    // k=1;
    // while (k < 7) { 
    //     int j = 1; 
    //     while (j < 9) { 
    //         int index = (k-1) * 8 + j-1; // 线性偏移地址
    //         // *(vram+index) = levels[i][k][j]; // 写入 1 字节
    //         (*((int*)(0xE0000000))) = map[k][j]; // 写入 1 字节
    //         wait(1000000);
    //         // *(vram+index) = (char)(k-1); // 写入 1 字节
    //         j=j+1; // 手动递增循环变量
    //     }
    //     k=k+1; // 手动递增循环变量
    // }
    (*((int*)0xE0000000)) = 3;
    int* btn_sw_addr = (int *)BTN_SW_ADDR;
    drawMap(map);   
    while (1) {
        
        (*((int*)0xE0000000 )) = 4;
        // drawMap(map);
        // short sw_i15 = (*((short*)0xF0000000))>>15;
        // short sw_i14 = ((*((short*)0xF0000000))>>14)&0x1;
        // short sw_i13 = ((*((short*)0xF0000000))>>13)&0x1;
        int btn_sw = *btn_sw_addr; // 读取按钮状态
        short btn = (btn_sw >> 16) & 0x1F; // 取出5位按钮值
        short btn_up= (btn >> 0) & 0x1; // 上
        short btn_right= (btn >> 1) & 0x1; // 右
        short btn_down= (btn >> 2) & 0x1; // 下
        short btn_left= (btn >> 3) & 0x1; // 左
        short btn_mid= (btn >> 4) & 0x1; // 中间按钮
        if (checkWin(map)) {
            // printf("胜利！按中间按钮进入下一关...\n");
            // 等待中间按钮按下
            while(1)
            {
                int btn_sw = *btn_sw_addr; // 读取按钮状态
                short btn = (btn_sw >> 16) & 0x1F; // 取出5位按钮值
                short btn_mid= (btn >> 4) & 0x1; // 中间按钮
                if (btn_mid) break;
            }
            break;
        }

        // 检测方向按钮（高电平表示按下）
        int hasMove = 0;
        if (btn_up)    
        {   movePlayer(map, 0); // 上
            hasMove = 1;
        }
        if (btn_down)  
        {
            movePlayer(map, 1); // 下
            hasMove = 1;
        }
        if (btn_left)  
        {
            movePlayer(map, 2); // 左
            hasMove = 1;
        }
        if (btn_right) 
        {
            movePlayer(map, 3); // 右
            hasMove = 1;
        }
        if(hasMove)
        {
            drawMap(map); 
            (*((int*)0xE0000000)) = 8;
            wait(100000); 
        }
        // 检测中间按钮（用于重置或进入下一关）
        if (btn_mid) {
            // 如果关卡已完成，中间按钮进入下一关
            // 否则重置当前关卡
            if (checkWin(map)) {
                while (btn_mid != 0); // 等待释放
                break;
            } else {
                for(int i=0;i<ROW;i++)
                {
                    for(int j=0;j<COL;j++)
                    {
                        map[i][j]=level[i][j];
                    }
                }
                drawMap(map); // 重绘地图
            }
            
        }
    }
}

void main() {
 
    // 分配空间：LEVELS * ROW * COL 个 int
    char levels[LEVELS][ROW][COL];

    int i = 0;
    while (i < LEVELS) {
        int j = 0;
        while (j < ROW) {
            int k = 0;
            while (k < COL) {
                levels[i][j][k] = 0;
                k++;
            }
            j++;
        }
        i++;
    }
    // Level 1 - 基础入门
    // 第二行
    levels[0][1][1] = 1; levels[0][1][2] = 1; levels[0][1][3] = 1; levels[0][1][4] = 1; 
    levels[0][1][5] = 1; levels[0][1][6] = 1; levels[0][1][7] = 1; levels[0][1][8] = 1;
    
    // 第三行
    levels[0][2][1] = 1; levels[0][2][2] = 2; levels[0][2][3] = 1; levels[0][2][4] = 3; 
    levels[0][2][5] = 1; levels[0][2][6] = 1; levels[0][2][7] = 4; levels[0][2][8] = 1;
    
    // 第四行
    levels[0][3][1] = 1; levels[0][3][2] = 1; levels[0][3][3] = 1; levels[0][3][4] = 1; 
    levels[0][3][5] = 1; levels[0][3][6] = 1; levels[0][3][7] = 1; levels[0][3][8] = 1;
    
    // 第五行
    levels[0][4][1] = 1; levels[0][4][2] = 1; levels[0][4][3] = 1; levels[0][4][4] = 1; 
    levels[0][4][5] = 1; levels[0][4][6] = 1; levels[0][4][7] = 1; levels[0][4][8] = 1;

    // Level 2 - 双箱双目标
    // 第二行
    levels[1][1][1] = 2; levels[1][1][2] = 1; levels[1][1][3] = 1; levels[1][1][4] = 3; 
    levels[1][1][5] = 1; levels[1][1][6] = 1; levels[1][1][7] = 3; levels[1][1][8] = 1;
    
    // 第三行
    levels[1][2][1] = 1; levels[1][2][2] = 1; levels[1][2][3] = 1; levels[1][2][4] = 1; 
    levels[1][2][5] = 1; levels[1][2][6] = 1; levels[1][2][7] = 1; levels[1][2][8] = 1;
    
    // 第四行
    levels[1][3][1] = 1; levels[1][3][2] = 4; levels[1][3][3] = 1; levels[1][3][4] = 1; 
    levels[1][3][5] = 1; levels[1][3][6] = 1; levels[1][3][7] = 4; levels[1][3][8] = 1;
    
    // 第五行
    levels[1][4][1] = 1; levels[1][4][2] = 1; levels[1][4][3] = 1; levels[1][4][4] = 1; 
    levels[1][4][5] = 1; levels[1][4][6] = 1; levels[1][4][7] = 1; levels[1][4][8] = 1;

    // Level 3 - 三目标错位
    // 第二行
    levels[2][1][1] = 1; levels[2][1][2] = 1; levels[2][1][3] = 1; levels[2][1][4] = 1; 
    levels[2][1][5] = 1; levels[2][1][6] = 4; levels[2][1][7] = 1; levels[2][1][8] = 1;
    
    // 第三行
    levels[2][2][1] = 1; levels[2][2][2] = 2; levels[2][2][3] = 1; levels[2][2][4] = 1; 
    levels[2][2][5] = 3; levels[2][2][6] = 1; levels[2][2][7] = 1; levels[2][2][8] = 4;
    
    // 第四行
    levels[2][3][1] = 1; levels[2][3][2] = 1; levels[2][3][3] = 1; levels[2][3][4] = 1; 
    levels[2][3][5] = 1; levels[2][3][6] = 3; levels[2][3][7] = 1; levels[2][3][8] = 1;
    
    // 第五行
    levels[2][4][1] = 1; levels[2][4][2] = 1; levels[2][4][3] = 1; levels[2][4][4] = 1; 
    levels[2][4][5] = 1; levels[2][4][6] = 1; levels[2][4][7] = 1; levels[2][4][8] = 1;

    // Level 4 - 简单内墙
    // 第二行
    levels[3][1][1] = 1; levels[3][1][2] = 1; levels[3][1][3] = 1; levels[3][1][4] = 4; 
    levels[3][1][5] = 0; levels[3][1][6] = 1; levels[3][1][7] = 1; levels[3][1][8] = 1;
    
    // 第三行
    levels[3][2][1] = 2; levels[3][2][2] = 3; levels[3][2][3] = 1; levels[3][2][4] = 1; 
    levels[3][2][5] = 0; levels[3][2][6] = 3; levels[3][2][7] = 1; levels[3][2][8] = 4;
    
    // 第四行
    levels[3][3][1] = 1; levels[3][3][2] = 1; levels[3][3][3] = 1; levels[3][3][4] = 1; 
    levels[3][3][5] = 0; levels[3][3][6] = 1; levels[3][3][7] = 1; levels[3][3][8] = 1;

    // Level 5 - 三箱三目标
    // 第二行
    levels[4][1][1] = 1; levels[4][1][2] = 4; levels[4][1][3] = 1; levels[4][1][4] = 4; 
    levels[4][1][5] = 1; levels[4][1][6] = 4; levels[4][1][7] = 1; levels[4][1][8] = 1;
    
    // 第三行
    levels[4][2][1] = 2; levels[4][2][2] = 1; levels[4][2][3] = 3; levels[4][2][4] = 1; 
    levels[4][2][5] = 3; levels[4][2][6] = 1; levels[4][2][7] = 3; levels[4][2][8] = 1;
    
    // 第四行
    levels[4][3][1] = 1; levels[4][3][2] = 1; levels[4][3][3] = 1; levels[4][3][4] = 1; 
    levels[4][3][5] = 1; levels[4][3][6] = 1; levels[4][3][7] = 1; levels[4][3][8] = 1;

    // Level 6 - 增大地图挑战
    // 第二行
    levels[5][1][1] = 2; levels[5][1][2] = 1; levels[5][1][3] = 1; levels[5][1][4] = 1; 
    levels[5][1][5] = 1; levels[5][1][6] = 3; levels[5][1][7] = 1; levels[5][1][8] = 4; 
    levels[5][1][9] = 1;
    
    // 第三行
    levels[5][2][1] = 1; levels[5][2][2] = 1; levels[5][2][3] = 3; levels[5][2][4] = 1; 
    levels[5][2][5] = 4; levels[5][2][6] = 1; levels[5][2][7] = 1; levels[5][2][8] = 1; 
    levels[5][2][9] = 1;
    
    // 第四行到第六行
    levels[5][3][1] = 1; levels[5][3][2] = 1; levels[5][3][3] = 1; levels[5][3][4] = 1; 
    levels[5][3][5] = 1; levels[5][3][6] = 1; levels[5][3][7] = 1; levels[5][3][8] = 1; 
    levels[5][3][9] = 1;
    
    levels[5][4][1] = 1; levels[5][4][2] = 1; levels[5][4][3] = 1; levels[5][4][4] = 1; 
    levels[5][4][5] = 1; levels[5][4][6] = 1; levels[5][4][7] = 1; levels[5][4][8] = 1; 
    levels[5][4][9] = 1;

    // Level 7 - 死角挑战
    // 第二行
    levels[6][1][1] = 2; levels[6][1][2] = 1; levels[6][1][3] = 1; levels[6][1][4] = 3; 
    levels[6][1][5] = 1; levels[6][1][6] = 4; levels[6][1][7] = 1; levels[6][1][8] = 1;
    
    // 第三行
    levels[6][2][1] = 1; levels[6][2][2] = 1; levels[6][2][3] = 1; levels[6][2][4] = 1; 
    levels[6][2][5] = 1; levels[6][2][6] = 1; levels[6][2][7] = 3; levels[6][2][8] = 4;
    
    // 第四行
    levels[6][3][1] = 1; levels[6][3][2] = 1; levels[6][3][3] = 1; levels[6][3][4] = 1; 
    levels[6][3][5] = 1; levels[6][3][6] = 1; levels[6][3][7] = 1; levels[6][3][8] = 1;

    // Level 8 - 终极挑战
    // 第二行
    levels[7][1][1] = 2; levels[7][1][2] = 1; levels[7][1][3] = 1; levels[7][1][4] = 3; 
    levels[7][1][5] = 1; levels[7][1][6] = 3; levels[7][1][7] = 1; levels[7][1][8] = 4; 
    levels[7][1][9] = 1;
    
    // 第三行
    levels[7][2][1] = 1; levels[7][2][2] = 1; levels[7][2][3] = 1; levels[7][2][4] = 1; 
    levels[7][2][5] = 1; levels[7][2][6] = 1; levels[7][2][7] = 4; levels[7][2][8] = 1; 
    levels[7][2][9] = 1;
    
    // 第四行
    levels[7][3][1] = 1; levels[7][3][2] = 1; levels[7][3][3] = 1; levels[7][3][4] = 1; 
    levels[7][3][5] = 1; levels[7][3][6] = 1; levels[7][3][7] = 1; levels[7][3][8] = 1; 
    levels[7][3][9] = 1;
    
    // 第五行
    levels[7][4][1] = 1; levels[7][4][2] = 4; levels[7][4][3] = 1; levels[7][4][4] = 1; 
    levels[7][4][5] = 1; levels[7][4][6] = 1; levels[7][4][7] = 1; levels[7][4][8] = 1; 
    levels[7][4][9] = 1;
    
    // 第六行到第八行
    levels[7][5][1] = 1; levels[7][5][2] = 1; levels[7][5][3] = 1; levels[7][5][4] = 1; 
    levels[7][5][5] = 1; levels[7][5][6] = 1; levels[7][5][7] = 1; levels[7][5][8] = 1; 
    levels[7][5][9] = 1;
    
    levels[7][6][1] = 1; levels[7][6][2] = 1; levels[7][6][3] = 1; levels[7][6][4] = 1; 
    levels[7][6][5] = 1; levels[7][6][6] = 1; levels[7][6][7] = 1; levels[7][6][8] = 1; 
    levels[7][6][9] = 1;

    i = 0; // 新增循环变量初始化
    while (i < LEVELS) { // 将for改为while
        // playLevel(levels[i]);
        // drawMap(levels[i]);
        char* vram = (char*)(0x80000000);
        int k = 1; 
        while (k < 7) { 
            int j = 1; 
            while (j < 9) { 
                int index = (k-1) * 8 + j-1; // 线性偏移地址
                *(vram+index) = levels[i][k][j]; // 写入 1 字节
                (*((int*)(0xE0000000))) = levels[i][k][j]; // 写入 1 字节
                wait(100000);
                // *(vram+index) = (char)(k-1); // 写入 1 字节
                j=j+1; // 手动递增循环变量
            }
            k=k+1; // 手动递增循环变量
        }
        // wait(10000000);
        i++; // 手动递增循环变量S
        (*((int*)0xE0000000)) = i;
        wait(1000000);

    }
    (*((int*)0xE0000000)) = 10;
    wait(10000000);
    i=0;
    while (i<LEVELS) {
        playLevel(levels[i]);
        (*((int*)0xE0000000)) = 2;
        wait(100000);
        i++;
    }

    
    // printf("全部关卡通关！恭喜你！\n");
}
#pragma GCC pop_options
