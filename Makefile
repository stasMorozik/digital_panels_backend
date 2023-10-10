build_core_test:
	docker build -f Dockerfile.core.test ./  -t core_test
core_test:
	docker run --rm --name core_test -v $(CURDIR)/apps/core/test:/app/apps/core/test -v $(CURDIR)/apps/core/lib:/app/apps/core/lib core_test
build_postgresql_adapters_test:
	docker build -f Dockerfile.postgresql_adapters.test ./  -t postgresql_adapters_test
postgresql_adapters_test:
	docker run --rm --name postgresql_adapters_test -v $(CURDIR)/apps/postgresql_adapters/test:/app/apps/postgresql_adapters/test -v $(CURDIR)/apps/postgresql_adapters/lib:/app/apps/postgresql_adapters/lib postgresql_adapters_test
build_admin_panel_dev:
	docker build -f Dockerfile.admin_panel.dev ./  -t admin_panel_dev
run_admin_panel_dev:
	docker run --network host --rm --name admin_panel_dev -v $(CURDIR)/apps/admin_panel/test:/app/apps/admin_panel/test -v $(CURDIR)/apps/admin_panel/lib:/app/apps/admin_panel/lib -v $(CURDIR)/apps/admin_panel/config:/app/apps/admin_panel/config -v $(CURDIR)/apps/admin_panel/assets:/app/apps/admin_panel/assets -v $(CURDIR)/apps/admin_panel/priv:/app/apps/admin_panel/priv admin_panel_dev
build_api_dev:
	docker build -f Dockerfile.api.dev ./  -t api_dev
run_api_dev:
	docker run --network host --rm --name api_dev -v $(CURDIR)/apps/api/test:/app/apps/api/test -v $(CURDIR)/apps/api/lib:/app/apps/api/lib -v $(CURDIR)/apps/api/config:/app/apps/api/config api_dev