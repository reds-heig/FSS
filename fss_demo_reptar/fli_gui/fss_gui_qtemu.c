/*
 * REPTAR Spartan6 FPGA emulation
 * Emulation "logic" part. Gateway between the emulation code and the backend.
 *
 * Copyright (c) 2013 HEIG-VD / REDS
 * Written by Romain Bornet
 *
 * This code is licensed under the GPL.
 */

#include <stddef.h>
#include <errno.h>
#include <pthread.h>
#include <stdio.h>
#include <string.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>

/* queue implementation */
#include <gdsl.h>

#include "fss_gui_qtemu.h"
#include "fss_utils_fli.h"
#include "fss_gui_fli.h"
#include "cJSON.h"

typedef struct SP6EmulState {
    int sock;                               			/* Socket to command server */

    gdsl_queue_t cmd_list;                                      /* Outgoing packets (commands) */
    gdsl_queue_t event_list;                                    /* Incoming packets (events) */

    pthread_mutex_t cmd_mutex;
    pthread_cond_t cmd_cond;                                    /* Condition variable and associated mutex */

    pthread_t eventThreadId;                   		        /* Command thread sending commands to the GUI */
    pthread_t cmdThreadId;                   			/* Command thread sending commands to the GUI */

    int thread_terminate;                  		        /* Flag to indicate that the the threads should terminate */
} SP6EmulState;

static SP6EmulState sp6_state;

static void close_gui_socket(void)
{
    close(sp6_state.sock);
}

/*
 * This function adds the cJSON pointer in the queue
 */
void *sp6_emul_cmd_post(cJSON *packet)
{
    if(sp6_state.thread_terminate)
    {
        cJSON_Delete(packet);
        return NULL;
    }

    DBG("%s\n", __FUNCTION__);

    pthread_mutex_lock(&sp6_state.cmd_mutex);

    DBG("%s Inserting into queue...\n", __FUNCTION__);
    gdsl_queue_insert(sp6_state.cmd_list, packet);
    pthread_cond_signal(&sp6_state.cmd_cond);
    DBG("%s ...done\n", __FUNCTION__);

    pthread_mutex_unlock(&sp6_state.cmd_mutex);

    return NULL;
}

/*
 * This loop empties the queue as fast as it can, sending the stringified
 * JSON through the socket.
 */
static void *sp6_emul_cmd_process(void *arg) {

  SP6EmulState *sp6 = arg;
  cJSON *packet;
  char *rendered;
  unsigned int len;


  while (!sp6->thread_terminate)
  {
    /* Wait on command to process */
    pthread_mutex_lock(&sp6->cmd_mutex);
    pthread_cond_wait(&sp6->cmd_cond, &sp6->cmd_mutex);
    pthread_mutex_unlock(&sp6->cmd_mutex);

    if (sp6->thread_terminate)
        break;

    /* while not empty */
    while (!sp6->thread_terminate && !gdsl_queue_is_empty(sp6->cmd_list))
    {
        pthread_mutex_lock(&sp6->cmd_mutex);
        packet = (cJSON *)gdsl_queue_remove(sp6->cmd_list);

        rendered = cJSON_Print(packet);
        cJSON_Minify(rendered);
        len = strlen(rendered);

        rendered[len] 	= '\n';
        rendered[len+1] = '\0';

        if (write(sp6->sock, rendered, strlen(rendered)) != strlen(rendered))
        {
            fprintf(stderr, "%s: Write error on socket.\n", __FUNCTION__);
            sp6->thread_terminate = 1;
        }
        free(rendered);

        pthread_mutex_unlock(&sp6->cmd_mutex);
        cJSON_Delete(packet);
    }
  }

  /* Empty queue on exit */
  while(!gdsl_queue_is_empty(sp6->cmd_list))
  {
      pthread_mutex_lock(&sp6->cmd_mutex);

      /* Flush queue's memory */
      gdsl_queue_flush(sp6->cmd_list);
      cJSON_Delete(packet);

      pthread_mutex_unlock(&sp6->cmd_mutex);
  }

  /* Close connection to server here ... */
  DBG("%s thread exits!\n", __FUNCTION__);
  return NULL;

}

/*
 * This loop receives and parses data from the socket, to cJSON objects.
 * Then the right driver callback is called.
 */
static void *sp6_emul_event_handle(void *arg)
{
    char inBuffer[1024]; 	/* Must be big enough to contain a least one json object */
    int readBytes;
    cJSON *root, *perifnode;

    int alreadyReadBytes = 0;
    SP6EmulState *sp6 = arg;

    while(!sp6->thread_terminate)
    {
        /* Read from the socket. */
        readBytes = read(sp6->sock,inBuffer+alreadyReadBytes,sizeof(inBuffer)-alreadyReadBytes);

        if(readBytes == 0)
        {
            DBG("%s: Socket error %d \n", __FUNCTION__, errno);

            sp6->thread_terminate=1;
            pthread_cond_signal(&sp6_state.cmd_cond);
        }
        /* If something has been read. */
        if(readBytes > 0)
            alreadyReadBytes+=readBytes;

        /* If something is present in the FIFO  */
        if(alreadyReadBytes)
        {
            /* For each newLine delimited string */
            while(1)
            {
                char * newLine = memchr(inBuffer,'\n',alreadyReadBytes);

                if(!newLine)
                {
                    /* If FIFO is full, but there is no newline, something went wrong. We discard the whole FIFO. */
                    if(alreadyReadBytes == sizeof(inBuffer))
                        alreadyReadBytes = 0;

                    break;
                }


                /* Replace newline by 0, so cJSON parses only one object */
                *newLine		= '\0';

                root 			= cJSON_Parse(inBuffer);

                if(root)
                {
                    perifnode 	= cJSON_GetObjectItem(root,"perif");

                    if(strcmp(perifnode->valuestring,PERID_BTN) == 0)
                          set_switches_state(cJSON_GetObjectItem(root, "status")->valueint);
                    else
                    {
                        DBG("%s: Error, unknow perif: %s \n", __FUNCTION__,perifnode->valuestring);
                        cJSON_Delete(root);
                    }
                }
                else
                    DBG("%s: Error, not valid JSON: %s \n", __FUNCTION__,inBuffer);

                /*
                * Update alreadyReadBytes. The +1 is for the discarded null char
                */
                alreadyReadBytes -= newLine-inBuffer+1;

                /* Move the fifo:
                * - Destination in inBuffer, base of the FIFO
                * - Copy from newLine+1, so we discard the newLine
                * - Copy the rest of the FIFO (alreadyReadBytes is up to date)
                */
                memmove(inBuffer,newLine+1,alreadyReadBytes);
            }
        }
    }
    DBG("%s thread exits!\n", __FUNCTION__);
    return NULL;
}

int sp6_emul_init(void)
{
    DBG("%s\n", __FUNCTION__);

    struct sockaddr_in server;

    sp6_state.sock = socket(AF_INET, SOCK_STREAM, 0);
    if (sp6_state.sock < 0) {
        fprintf(stderr, "%s: failed to connect to SP6 server\n", __FUNCTION__);
        fprintf(stderr, "%s: terminate thread\n", __FUNCTION__);
        return -1;
    }

    server.sin_addr.s_addr = inet_addr("127.0.0.1");
    server.sin_family = AF_INET;
    server.sin_port = htons(FLI_QT_PORT);

    /* Connect to remote server */
    if (connect(sp6_state.sock, (struct sockaddr *)&server, sizeof(server)) < 0)
    {
        perror("connect failed. Error");
        return -1;
    }
    DBG("** [%s] CONNECTED TO QTEMU**\n", __FUNCTION__);

    /* Initialize queue. We will allocate packets ourselves (cJSON lib), hence NULL parameters. */
    sp6_state.event_list = gdsl_queue_alloc("Outgoing packets", NULL, NULL);
    sp6_state.cmd_list = gdsl_queue_alloc("Incoming packets", NULL, NULL);

    pthread_mutex_init(&sp6_state.cmd_mutex, NULL);
    pthread_cond_init(&sp6_state.cmd_cond, NULL);

    sp6_state.thread_terminate = 0;

    /* Thread for output commands */
    pthread_create(&sp6_state.cmdThreadId, NULL, sp6_emul_cmd_process, &sp6_state);

    /* Thread for input events */
    pthread_create(&sp6_state.eventThreadId, NULL, sp6_emul_event_handle, &sp6_state);

    return 0;
}

int sp6_emul_exit(void)
{
    /* Stop the cmd processing thread */
    sp6_state.thread_terminate = 1;

    pthread_cond_signal(&sp6_state.cmd_cond);
    pthread_join(sp6_state.cmdThreadId, NULL);
    pthread_join(sp6_state.eventThreadId, NULL);

    close_gui_socket();

    return 0;
}
