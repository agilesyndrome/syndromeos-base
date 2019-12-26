setup:
	echo "Setup Phase empty"

login:
	$$(aws ecr get-login --no-include-email --region $(AWS_DEFAULT_REGION))

publish: login
	docker push $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_DEFAULT_REGION).amazonaws.com/$(IMAGE_REPO_NAME):branch-$(BRANCH_NAME)

build: login
	docker build -t $(IMAGE_REPO_NAME):$(BRANCH_NAME)
	docker tag $(IMAGE_REPO_NAME):$(BRANCH_NAME) $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_DEFAULT_REGION).amazonaws.com/$(IMAGE_REPO_NAME):$(BRANCH_NAME)

new_project: clean
	moondocker-compose run base /app/new_project $(PROJECT_NAME)
