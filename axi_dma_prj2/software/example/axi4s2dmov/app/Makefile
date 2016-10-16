OBJS := a4s2d_app.o
a4s2d_app: $(OBJS)
	$(CC) -o a4s2d_app $(OBJS)
$(OBJS) : %.o : %.c
	$(CC) -c $(CFLAGS) $< -o $@
