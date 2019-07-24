.PHONY: sync-charts package-chart
sync-charts:
	mkdir -p .build/helm-charts/pkg
	aws s3 sync s3://charts-jspc-pw .build/helm-charts/pkg --endpoint=https://nyc3.digitaloceanspaces.com

package-chart:
	true
