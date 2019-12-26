setup:
	echo "No setup tasks"

login:
	$$(aws ecr get-login --no-include-email --region $(AWS_DEFAULT_REGION))

publish: login
	docker tag $(IMAGE_REPO_NAME):$(ARTIFACT_REF).amazonaws.com/$(IMAGE_REPO_NAME):$(ARTIFACT_REF)
	docker push $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_DEFAULT_REGION).amazonaws.com/$(IMAGE_REPO_NAME):$(ARTIFACT_REF)

publish_master: login
	docker tag $(IMAGE_REPO_NAME):$(ARTIFACT_REF) $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_DEFAULT_REGION).amazon    aws.com/$(IMAGE_REPO_NAME):latest
	docker push $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_DEFAULT_REGION).amazonaws.com/$(IMAGE_REPO_NAME):latest

build:
	docker build -t $(IMAGE_REPO_NAME):$(ARTIFACT_REF) .
