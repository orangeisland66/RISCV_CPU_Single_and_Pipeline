#pragma GCC push_options
#pragma GCC optimize ("O0")
void start() {
asm("li\tsp,1024\n\t"
"call main");
}
__attribute__ ((noinline)) void wait(int instr_num) {
while (instr_num--) ;
}
void main() {
    int x = 1;
    int temp=0;
    int pre=0;
    (*((int*)0xE0000000)) = x;
    short sw_15 = (*((short*)0xF0000000))>>15;
    while (1) {
        wait(4000000);
        sw_15 = (*((short*)0xF0000000))>>15;
        if(sw_15)
        {
            temp=pre;
            pre = x;
            x = pre+temp;
            (*((int*)0xE0000000)) = x;
        }
    }
}
#pragma GCC pop_options