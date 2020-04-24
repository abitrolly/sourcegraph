BEGIN;

CREATE TABLE IF NOT EXISTS actions (
    id SERIAL PRIMARY KEY,
    name text NOT NULL,
    campaign integer REFERENCES campaigns(id) ON UPDATE CASCADE,
    schedule text,
    cancel_previous boolean NOT NULL DEFAULT false,
    saved_search integer REFERENCES saved_searches(id) ON UPDATE CASCADE,
    steps text NOT NULL,
    env json NOT NULL DEFAULT '[]'::json
);
CREATE UNIQUE INDEX IF NOT EXISTS actions_pkey ON actions(id int4_ops);

CREATE TABLE IF NOT EXISTS action_executions (
    id SERIAL PRIMARY KEY,
    steps text NOT NULL,
    env json,
    invocation_reason text NOT NULL CHECK (invocation_reason = ANY (ARRAY['MANUAL'::text, 'SAVED_SEARCH'::text, 'SCHEDULE'::text])),
    patch_set_id integer REFERENCES patch_sets(id) ON UPDATE CASCADE,
    action integer NOT NULL REFERENCES actions(id) ON UPDATE CASCADE
);
CREATE UNIQUE INDEX IF NOT EXISTS action_executions_pkey ON action_executions(id int4_ops);

CREATE TABLE IF NOT EXISTS action_jobs (
    id SERIAL PRIMARY KEY,
    log text,
    execution_start timestamp with time zone,
    execution_end timestamp with time zone,
    agent_seen_at timestamp with time zone,
    patch text,
    state text NOT NULL DEFAULT 'PENDING'::text CHECK (state = ANY (ARRAY['PENDING'::text, 'RUNNING'::text, 'COMPLETED'::text, 'ERRORED'::text, 'TIMEOUT'::text, 'CANCELED'::text])),
    repository integer NOT NULL REFERENCES repo(id) ON UPDATE CASCADE,
    execution integer NOT NULL REFERENCES action_executions(id) ON UPDATE CASCADE ON DELETE CASCADE,
    base_revision text NOT NULL,
    base_reference text NOT NULL
);
CREATE UNIQUE INDEX IF NOT EXISTS action_jobs_pkey ON action_jobs(id int4_ops);

COMMIT;