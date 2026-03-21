/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   client_bonus.c                                     :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: jkim2 <jkim2@student.42gyeongsan.kr>       +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/03/19 12:00:00 by jkim2             #+#    #+#             */
/*   Updated: 2026/03/21 19:44:35 by jkim2            ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minitalk_bonus.h"
#include "libft/libft.h"
#include <stdlib.h>

static void	sig_handler(int sig)
{
	static int	received = 0;

	if (sig == SIGUSR1)
		received++;
	else
	{
		ft_putnbr_fd(received, 1);
		write(1, " characters received\n", 21);
		exit(0);
	}
}

static void	send_char(int pid, char c)
{
	unsigned char	uc;
	int				bit;
	int				sig;

	uc = (unsigned char)c;
	bit = 0;
	while (bit < 8)
	{
		sig = SIGUSR1;
		if (uc & (1 << bit))
			sig = SIGUSR2;
		if (kill(pid, sig) == -1)
		{
			write(2, "Error: send failed\n", 19);
			exit(1);
		}
		usleep(500);
		bit++;
	}
}

static void	setup_signals(void)
{
	struct sigaction	sa;

	sa.sa_handler = sig_handler;
	sa.sa_flags = SA_RESTART;
	sigemptyset(&sa.sa_mask);
	sigaddset(&sa.sa_mask, SIGUSR1);
	sigaddset(&sa.sa_mask, SIGUSR2);
	sigaction(SIGUSR1, &sa, NULL);
	sigaction(SIGUSR2, &sa, NULL);
}

static int	is_valid_pid(char *str)
{
	int	i;

	i = 0;
	while (str[i])
	{
		if (str[i] < '0' || str[i] > '9')
			return (0);
		i++;
	}
	if (i == 0 || ft_atoi(str) <= 0)
		return (0);
	return (1);
}

int	main(int argc, char **argv)
{
	int	pid;
	int	i;

	if (argc != 3)
	{
		write(2, "Usage: ./client <PID> <message>\n", 32);
		return (1);
	}
	if (!is_valid_pid(argv[1]))
	{
		write(2, "Error: invalid PID\n", 19);
		return (1);
	}
	pid = ft_atoi(argv[1]);
	setup_signals();
	i = 0;
	while (argv[2][i])
	{
		send_char(pid, argv[2][i]);
		i++;
	}
	send_char(pid, '\0');
	while (1)
		pause();
	return (0);
}
