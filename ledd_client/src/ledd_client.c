/*
 * ledd_client.c
 *
 *  Created on: May 3, 2016
 *      Author: ncarrier
 */
#include <sys/socket.h>

#include <errno.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#include <libpomp.h>

#include <ledd_client.h>

#define LEDD_MSG_SET_PATTERN 0
#define LEDD_MSG_QUIT 1
#define LEDD_MSG_DUMP_CONFIG 2
#define LEDD_MSG_SET_VALUE 3

struct ledd_client {
	struct pomp_ctx *pomp;
	struct ledd_client_ops ops;
	void *userdata;
};

static void pomp_event_cb(struct pomp_ctx *ctx, enum pomp_event event,
		struct pomp_conn *conn, const struct pomp_msg *msg,
		void *userdata)
{
	struct ledd_client *client = userdata;

	if (event == POMP_EVENT_MSG)
		return;

	client->ops.connection_cb(client->userdata,
			event == POMP_EVENT_CONNECTED);
}

struct ledd_client *ledd_client_new(const char *address,
		const struct ledd_client_ops *ops, void *userdata)
{
	int old_errno;
	struct ledd_client *client;
	int ret;
	union {
		struct sockaddr_storage addr_str;
		struct sockaddr addr_sock;
	} addr;
	uint32_t addrlen = sizeof(addr.addr_str);

	client = calloc(1, sizeof(*client));
	if (client == NULL)
		return NULL;

	client->pomp = pomp_ctx_new(pomp_event_cb, client);
	if (client->pomp == NULL) {
		old_errno = errno;
		goto err;
	}
	if (address == NULL)
		address = "unix:@ledd.socket";
	ret = pomp_addr_parse(address, &addr.addr_sock, &addrlen);
	if (ret < 0) {
		old_errno = -ret;
		goto err;
	}
	/* must be done before connect because it can notify */
	client->ops = *ops;
	client->userdata = userdata;
	ret = pomp_ctx_connect(client->pomp, &addr.addr_sock, addrlen);
	if (ret < 0) {
		old_errno = -ret;
		goto err;
	}

	return client;
err:
	ledd_client_destroy(&client);
	errno = old_errno;

	return NULL;
}
int ledd_client_get_fd(struct ledd_client *client)
{
	if (client == NULL)
		return -EINVAL;

	return pomp_ctx_get_fd(client->pomp);
}

int ledd_client_process_events(struct ledd_client *client)
{
	if (client == NULL)
		return -EINVAL;

	return pomp_ctx_process_fd(client->pomp);
}


int ledd_client_set_pattern(struct ledd_client *client, const char *pattern,
		bool resume)
{
	return pomp_ctx_send(client->pomp, LEDD_MSG_SET_PATTERN, "%s%s",
			pattern, resume ? "true" : "false");
}

void ledd_client_destroy(struct ledd_client **client)
{
	struct ledd_client *c;

	if (client == NULL || *client == NULL)
		return;
	c = *client;

	if (c->pomp != NULL) {
		pomp_ctx_stop(c->pomp);
		pomp_ctx_destroy(c->pomp);
	}
	memset(c, 0, sizeof(*c));
	free(c);

	*client = NULL;
}