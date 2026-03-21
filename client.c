/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   client.c                                           :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: jkim2 <jkim2@student.42gyeongsan.kr>       +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/03/16 10:19:15 by jkim2             #+#    #+#             */
/*   Updated: 2026/03/20 16:31:42 by jkim2            ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minitalk.h"
#include "libft/libft.h"
#include <stdlib.h>

static int	is_valid_pid(char *str)
{
	int	value;
	int	i;

	value = 0;
	i = 0;
	if (!str[0])
		return (0);
	while (str[i])
	{
		if (str[i] < '0' || str[i] > '9')
			return (0);
		if (value > 214748364 || (value == 214748364
				&& str[i] > '7'))
			return (0);
		value = value * 10 + (str[i] - '0');
		i++;
	}
	if (value <= 0)
		return (0);
	return (1);
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
	i = 0;
	while (argv[2][i])
	{
		send_char(pid, argv[2][i]);
		i++;
	}
	send_char(pid, '\0');
	return (0);
}
