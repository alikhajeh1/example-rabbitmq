## Deploying RabbitMQ

Follow the [guide in the AbarCloud docs](https://docs.abarcloud.com/additional-services/rabbitmq.html) to deploy RabbitMQ on AbarCloud.

## Run the test helloworld client

This just tests you can connect and prints out some Hello World messages.

1. Deploy the test application using the service domain name of the rabbitmq service.
   ```
   oc new-app aliscott/rabbitmq-helloworld \
     --env RABBITMQ_URI=amqp://<user>:<password>@<service>
   ```
2. Check it is working by tailing the logs:
   ```
   oc logs -f <pod>
   ```
   You should see messages like:
   ```
   MESSAGE: Hello world! - MESSAGE COUNT 1
   MESSAGE: Hello world! - MESSAGE COUNT 2
   MESSAGE: Hello world! - MESSAGE COUNT 3
   ```

## Benchmarking

This uses the RabbitMQ perf test tool: https://github.com/rabbitmq/rabbitmq-perf-test

1. Scale the rabbitmq server to what you want, e.g:
   ```
   oc patch dc/rabbitmq -p '{"spec":{"template":{"spec":{"containers":[{"name":"rabbitmq", "resources":{"requests":{"memory":"500Mi"}}}]}}}}'
   ```

   You also want to manually add the high watermark setting. By default this is set to 40% of the available memory, but will not get updated if you update the memory allocated to the pod, so you should set an absolute number.
   ```
   oc env dc/rabbitmq RABBITMQ_VM_MEMORY_HIGH_WATERMARK=200MiB
   ```

2. Run the benchmarking tool
   ```
   oc new-app aliscott/rabbitmq-perf  \
     --env RABBITMQ_URI=amqp://<user>:<password>@<service>.<project>.svc.cluster.local \
     --env RABBITMQ_PERF_ARGS="--producers 1 --consumers 1"
   ```

3. You can see some perf stats in the RabbitMQ management web app.
   Next step would be deploying https://github.com/rabbitmq/rabbitmq-perf-html.

## License

This project is licensed under the MIT license. See the `LICENSE` file for more information.
