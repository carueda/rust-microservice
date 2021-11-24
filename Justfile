set dotenv-load := true

# HTTP client program:
hc := "curlie 2> /dev/null"

_:
	#!/usr/bin/env bash
	if [ $(which fzf) ] && [ -x $(which fzf) ]; then
		just --choose
	else
		just --list --unsorted
	fi

# List recipes
list:
	@just --list --unsorted

# Run dockerized postgres
run-postgres:
	docker run --rm \
		--name postgres -e POSTGRES_PASSWORD=docker \
		-p 5432:5432 -v /tmp/postgress:/var/lib/postgresql/data \
		postgres

# Create/migrate database
db-create:
	(cd news-migrations && cargo run)

# Run the service
run-service:
	RUST_LOG=info cargo run --bin news-service

# See current news
db-news:
	{{hc}} http://localhost:8080/news

# Add some news
db-news-add-some:
	{{hc}} put "http://localhost:8080/news/foo/foo.com"
	{{hc}} put "http://localhost:8080/news/baz/baz.com"

# Delete a news
db-news-delete id:
	{{hc}} delete "http://localhost:8080/news/{{id}}"

# Run dockerized psql
psql:
	docker exec -it postgres sh -c "PGPASSWORD=docker /usr/bin/psql -h 127.0.0.1 -U postgres -d postgres"