#include <stdio.h>
#include "heap.h"

void print_data(data d){
    printf("%d\n", d.key);
}

int main(){
    heap* myheap = heap_init();

    int maxKey = 100000; //100 to 100 thousand by power of 10
    for (int i = 0; i<maxKey; i+=5){
        heap_insert(&myheap, i, NULL);
    }
    for (int i = 1; i<maxKey; i+=5){
        heap_insert(&myheap, i, NULL);
    }
    for (int i = 2; i<maxKey; i+=5){
        heap_insert(&myheap, i, NULL);
    }
    for (int i = 3; i<maxKey; i+=5){
        heap_insert(&myheap, i, NULL);
    }
    for (int i = 4; i<maxKey; i+=5){
        heap_insert(&myheap, i, NULL);
    }
    while (!is_empty(myheap)){
        print_data(heap_extract_min(&myheap));
    }
    heap_free(&myheap);
    return 0;
}
