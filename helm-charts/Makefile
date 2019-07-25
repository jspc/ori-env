CHART_DIR = .build/helm-charts/pkg

.PHONY: publish sync-charts package-chart publish-charts deploy

publish: clean-charts sync-charts package-chart publish-charts

${CHART_DIR}:
	mkdir -p ${CHART_DIR}

clean-charts:
	-rm -rf ${CHART_DIR}

sync-charts: ${CHART_DIR}
	aws s3 sync s3://charts-jspc-pw ${CHART_DIR} --endpoint=https://nyc3.digitaloceanspaces.com

package-chart:
	cd ${CHART_DIR} && (                                             \
		helm package ../../../helm/${APP} &&                     \
		helm repo index . --url https://charts.jspc.pw           \
	)

publish-charts:
	aws s3 sync ${CHART_DIR} s3://charts-jspc-pw --endpoint=https://nyc3.digitaloceanspaces.com --acl=public-read

.build/kubeconfig:
	aws s3 cp s3://config-ori-jspc-pw/kubeconfig .build/kubeconfig --endpoint=https://nyc3.digitaloceanspaces.com

update:
	helm repo update

deploy: .build/kubeconfig
	helm --tiller-namespace=ori upgrade --namespace=ori ${APP} techtest/${APP}
