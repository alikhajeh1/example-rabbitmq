#!/bin/sh
runjava com.rabbitmq.perf.PerfTest --uri "${RABBITMQ_URI}" ${RABBITMQ_PERF_ARGS}
