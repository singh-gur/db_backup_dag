from datetime import datetime
from airflow.models import DAG
from airflow.providers.docker.operators.docker import DockerOperator
from airflow.serialization.serialized_objects import SerializedDAG
from airflow.timetables.interval import CronTimetable

DOCKER_IMAGE = "regv2.gsingh.io/personal/pg-s3-backup:latest"

TIMETABLE = CronTimetable(
    schedule="0 2 * * *",
    timezone="UTC",
)

DEFAULT_ARGS = {
    "owner": "airflow",
    "depends_on_past": False,
    "email_on_failure": False,
    "email_on_retry": False,
    "retries": 2,
    "retry_delay": 300,
}

with DAG(
    dag_id="pg_s3_backup",
    description="Backup PostgreSQL database to S3 using Docker container",
    timetable=TIMETABLE,
    start_date=datetime(2025, 1, 1),
    catchup=False,
    tags=["backup", "postgres", "s3"],
    default_args=DEFAULT_ARGS,
) as dag:
    backup_postgres = DockerOperator(
        task_id="backup_postgres_to_s3",
        image=DOCKER_IMAGE,
        api_version="auto",
        auto_remove="success",
        docker_url="unix://var/run/docker.sock",
        environment={
            "AWS_ACCESS_KEY_ID": "{{ var.value.aws_access_key_id }}",
            "AWS_SECRET_ACCESS_KEY": "{{ var.value.aws_secret_access_key }}",
            "AWS_DEFAULT_REGION": "{{ var.value.aws_region | default('us-east-1') }}",
        },
        command=[
            "--bucket",
            "{{ var.value.s3_backup_bucket }}",
            "--host",
            "{{ var.value.pg_host }}",
            "--port",
            "{{ var.value.pg_port | default('5432') }}",
            "--dbname",
            "{{ var.value.pg_database }}",
            "--user",
            "{{ var.value.pg_user }}",
            "--password",
            "{{ var.value.pg_password }}",
            "--prefix",
            "{{ var.value.s3_backup_prefix | default('backups/') }}",
            "--compress",
        ],
        Mounts=[
            {
                "source": "/tmp",
                "target": "/tmp",
                "type": "bind",
            },
        ],
    )
