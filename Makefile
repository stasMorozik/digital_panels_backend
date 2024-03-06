build_core_test:
	docker build -f Dockerfile.core.test ./  -t core_test
core_test:
	docker run --rm --name core_test -v $(CURDIR)/apps/core/test:/app/apps/core/test -v $(CURDIR)/apps/core/lib:/app/apps/core/lib core_test
build_postgresql_adapters_test:
	docker build -f Dockerfile.postgresql_adapters.test ./  -t postgresql_adapters_test
postgresql_adapters_test:
	docker run --rm --name postgresql_adapters_test -v $(CURDIR)/apps/postgresql_adapters/test:/app/apps/postgresql_adapters/test -v $(CURDIR)/apps/postgresql_adapters/lib:/app/apps/postgresql_adapters/lib postgresql_adapters_test
build_http_adapters_test:
	docker build -f Dockerfile.http_adapters.test ./  -t http_adapters_test
http_adapters_test:
	docker run --rm --name http_adapters_test -v $(CURDIR)/apps/http_adapters/test:/app/apps/http_adapters/test -v $(CURDIR)/apps/http_adapters/lib:/app/apps/http_adapters/lib http_adapters_test
build_dev_node_logger:
	docker build -f Dockerfile.dev_node_logger ./  -t dev_node_logger
run_dev_node_logger:
	docker run --network host --rm --name dev_node_logger -v $(CURDIR)/apps/node_logger/test:/app/apps/node_logger/test -v $(CURDIR)/apps/node_logger/lib:/app/apps/node_logger/lib -v $(CURDIR)/apps/node_logger/config:/app/apps/node_logger/config dev_node_logger
build_dev_node_notifier:
	docker build -f Dockerfile.dev_node_notifier ./  -t dev_node_notifier
run_dev_node_notifier:
	docker run --network host --rm --name dev_node_notifier -v $(CURDIR)/apps/node_notifier/test:/app/apps/node_notifier/test -v $(CURDIR)/apps/node_notifier/lib:/app/apps/node_notifier/lib -v $(CURDIR)/apps/node_notifier/config:/app/apps/node_notifier/config dev_node_notifier
build_dev_api:
	docker build -f Dockerfile.dev_api ./  -t dev_api
run_dev_api:
	docker run --network host --rm --name dev_api -v $(CURDIR)/apps/api/test:/app/apps/api/test -v $(CURDIR)/apps/api/lib:/app/apps/api/lib -v $(CURDIR)/apps/api/config:/app/apps/api/config dev_api