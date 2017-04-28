## Deploying RabbitMQ

1. Create a new project
   ```
   oc new-project rabbitmq-test
   ```

2. Deploy rabbitmq
You can either deploy rabbitmq with the management console:
   ```
   oc new-app rabbitmq:3-management --name rabbitmq \
     --env RABBITMQ_DEFAULT_USER=<user> \
     --env RABBITMQ_DEFAULT_PASS=<password>
   ```
   Or without the management console:
   ```
   oc new-app rabbitmq:3 \
     --env RABBITMQ_DEFAULT_USER=<user> \
     --env RABBITMQ_DEFAULT_PASS=<password>
   ```

3. Create a PVC for the database:
   ```
   oc create -f - <<EOF
     apiVersion: "v1"
     kind: "PersistentVolumeClaim"
     metadata:
       name: "rabbitmq"
     spec:
       accessModes:
         - "ReadWriteOnce"
       resources:
         requests:
           storage: "2Gi"
   EOF
   ```

4. Attach the PVC to the rabbitmq deployment:
   ```
   oc volume dc/rabbitmq --remove --name rabbitmq-volume-1
   oc volume dc/rabbitmq --add --name rabbitmq-volume-1 --type persistentVolumeClaim --claim-name rabbitmq --mount-path /var/lib/rabbitmq
   ```

5. If using the management version you can expose the management service:
   ```
   oc expose svc/rabbitmq --port=15672
   oc patch route/rabbitmq -p '{"spec":{"tls":{"termination":"edge","insecureEdgeTerminationPolicy":"Redirect"}}}'
   ```
   Get the route name:
   ```
   oc get route rabbitmq
   ```
   Go to: https://<route> to log in

## Run the test helloworld client

This just tests you can connect and prints out some Hello World messages.

1. Deploy the test application using the service domain name of the rabbitmq service.
   ```
   oc new-app aliscott/rabbitmq-helloworld \
     --env RABBITMQ_URI=amqp://<user>:<password>@<service>.<project>.svc.cluster.local
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
