#define SEVENTEEN 17

typedef struct {
    int n;
    char *str;
} stuff;

typedef stuff *NetLDNS;

int seventeen();
size_t count(char *str);
NetLDNS new(char *class,char *str);
char *str(NetLDNS obj);