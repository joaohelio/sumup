# Job Processor

Processes job tasks with dependencies and returns them in the correct execution order.

## Features

- HTTP API for job processing
- Accepts JSON payload with tasks and their dependencies
- Returns ordered tasks in JSON format or as a bash script

## Requirements

- Elixir 1.14 or higher
- Erlang/OTP 25 or higher
- Phoenix 1.7.10 or higher

## Installation
1. Set up environment variables:

Create the following files and populate them with the respective environment variables:

**.env**
```bash
SECRET_KEY_BASE=SECRET
PHX_HOST=http://localhost
PORT=4000
MIX_ENV=prod
```

**.env.test**
```bash
MIX_ENV=test
```

Make sure to replace `SECRET` with the output of the `mix phx.gen.secret` command for the `SECRET_KEY_BASE` value.

2. Clone the repository:
   ```bash
   git clone git@github.com:joaohelio/sumup.git
   cd sumup
   ```

3. Build the application:
   ```bash
   docker compose -f docker-compose.yml build sumup
   ```

4. Run tests to ensure everything is working:
   ```bash
   alias dc-test='docker compose -f docker-compose.yml -f docker-compose-test.yml'

   dc-test run sumup mix test
   ```

5. Start the server:
   ```bash
   docker compose -f docker-compose.yml up
   ```

The server will be available at [http://localhost:4000](http://localhost:4000).

## API Usage

### Process Jobs (JSON Response)

**POST /api/jobs**

Process a job and return the ordered tasks in JSON format.

Request body:
```json
{
  "tasks": [
    {
      "name": "task-1",
      "command": "touch /tmp/file1"
    },
    {
      "name": "task-2",
      "command": "cat /tmp/file1",
      "requires": [
        "task-3"
      ]
    },
    {
      "name": "task-3",
      "command": "echo 'Hello World!' > /tmp/file1",
      "requires": [
        "task-1"
      ]
    },
    {
      "name": "task-4",
      "command": "rm /tmp/file1",
      "requires": [
        "task-2",
        "task-3"
      ]
    }
  ]
}
```

Example Response:
```json
[
  {
    "name": "task-1",
    "command": "touch /tmp/file1"
  },
  {
    "name": "task-3",
    "command": "echo 'Hello World!' > /tmp/file1"
  },
  {
    "name": "task-2",
    "command": "cat /tmp/file1"
  },
  {
    "name": "task-4",
    "command": "rm /tmp/file1"
  }
]
```

### Process Jobs (Bash Script Response)

**POST /api/jobs/script**

Process a job and return the commands as a bash script.

The request body is the same as above.

Example Response:
```bash
#!/usr/bin/env bash
touch /tmp/file1
echo 'Hello World!' > /tmp/file1
cat /tmp/file1
rm /tmp/file1
```

You can pipe this directly to bash:
```bash
curl -d @tasks.json -H 'content-type: application/json' -X POST http://localhost:4000/api/jobs_to_script | bash
```

## Design Decisions

1. **Topological Sorting**: I implemented a topological sort algorithm to determine the correct order of task execution based on dependencies.

2. **Error Handling**: The system provides clear error messages for common issues like circular dependencies and missing tasks.

3. **API Design**: The API is designed to be simple and RESTful, with clear endpoints for different output formats.

4. **Performance**: The sorting algorithm is optimized to handle complex dependency graphs efficiently.

5. **No Database**: This application doesn't require a database as it processes job requests on-the-fly without needing to store any state.

## Continuous Integration (CI)
The project uses GitHub Actions for continuous integration. Every pull request triggers automated tests to ensure code quality and prevent regressions.