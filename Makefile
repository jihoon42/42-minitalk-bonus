SERVER = server
CLIENT = client

CC = cc
CFLAGS = -Wall -Wextra -Werror

SERVER_SRCS = server.c
CLIENT_SRCS = client.c
SERVER_OBJS = $(SERVER_SRCS:.c=.o)
CLIENT_OBJS = $(CLIENT_SRCS:.c=.o)

SERVER_BSRCS = server_bonus.c
CLIENT_BSRCS = client_bonus.c
SERVER_BOBJS = $(SERVER_BSRCS:.c=.o)
CLIENT_BOBJS = $(CLIENT_BSRCS:.c=.o)

LIBFT_DIR = libft
LIBFT = $(LIBFT_DIR)/libft.a

all: $(SERVER) $(CLIENT)

$(LIBFT):
	$(MAKE) -C $(LIBFT_DIR)

$(SERVER): $(SERVER_OBJS) $(LIBFT)
	$(CC) $(CFLAGS) $(SERVER_OBJS) $(LIBFT) -o $(SERVER)

$(CLIENT): $(CLIENT_OBJS) $(LIBFT)
	$(CC) $(CFLAGS) $(CLIENT_OBJS) $(LIBFT) -o $(CLIENT)

bonus: $(SERVER_BOBJS) $(CLIENT_BOBJS) $(LIBFT)
	$(CC) $(CFLAGS) $(SERVER_BOBJS) $(LIBFT) -o $(SERVER)
	$(CC) $(CFLAGS) $(CLIENT_BOBJS) $(LIBFT) -o $(CLIENT)

$(SERVER_OBJS) $(CLIENT_OBJS): minitalk.h
$(SERVER_BOBJS) $(CLIENT_BOBJS): minitalk_bonus.h

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	$(MAKE) -C $(LIBFT_DIR) clean
	rm -f $(SERVER_OBJS) $(CLIENT_OBJS) $(SERVER_BOBJS) $(CLIENT_BOBJS)

fclean: clean
	$(MAKE) -C $(LIBFT_DIR) fclean
	rm -f $(SERVER) $(CLIENT)

re: fclean all

.PHONY: all clean fclean re bonus
