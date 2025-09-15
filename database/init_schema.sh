#!/bin/bash
# Initializes the MySQL schema for the To-Do List app.
# Reads CLI connection command from db_connection.txt if available.
# Executes one statement at a time; safe to re-run.

set -euo pipefail

WORKDIR="$(cd "$(dirname "$0")" && pwd)"

if [ -f "${WORKDIR}/db_connection.txt" ]; then
  DB_CLI="$(cat "${WORKDIR}/db_connection.txt" | tr -d '\r')"
else
  echo "db_connection.txt not found, falling back to default MySQL CLI..."
  # Default values must match startup.sh
  DB_NAME="myapp"
  DB_USER="appuser"
  DB_PASSWORD="dbuser123"
  DB_PORT="5000"
  DB_HOST="localhost"
  DB_CLI="mysql -u ${DB_USER} -p${DB_PASSWORD} -h ${DB_HOST} -P ${DB_PORT} ${DB_NAME}"
fi

# Extract a base CLI to run without specifying DB (for CREATE DATABASE)
BASE_CLI="$(echo "${DB_CLI}" | sed -E 's/ [A-Za-z0-9_\\-]+$//')"
DB_NAME_FROM_CLI="$(echo "${DB_CLI}" | awk '{print $NF}')"

echo "Using CLI: ${DB_CLI}"
echo "Ensuring database exists: ${DB_NAME_FROM_CLI}"

# 1) Ensure database exists
${BASE_CLI} -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME_FROM_CLI};"

# Define a function to run a one-line statement against the target DB
run_sql () {
  local stmt="$1"
  # shellcheck disable=SC2086
  ${DB_CLI} -e "$stmt"
}

echo "Creating/ensuring tables..."

# 2) categories
run_sql "CREATE TABLE IF NOT EXISTS categories (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  color VARCHAR(20) NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);"

# 3) tasks
run_sql "CREATE TABLE IF NOT EXISTS tasks (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  description TEXT NULL,
  category_id INT NULL,
  due_date DATETIME NULL,
  priority ENUM('low','medium','high') DEFAULT 'medium',
  is_completed BOOLEAN DEFAULT FALSE,
  sort_order INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL
);"

# 4) reminders
run_sql "CREATE TABLE IF NOT EXISTS reminders (
  id INT AUTO_INCREMENT PRIMARY KEY,
  task_id INT NOT NULL,
  remind_at DATETIME NOT NULL,
  method ENUM('email','push','sms','none') DEFAULT 'none',
  is_sent BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE
);"

# 5) user_settings
run_sql "CREATE TABLE IF NOT EXISTS user_settings (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id VARCHAR(64) NOT NULL,
  dark_mode BOOLEAN DEFAULT FALSE,
  notifications_enabled BOOLEAN DEFAULT TRUE,
  timezone VARCHAR(64) DEFAULT 'UTC',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY unique_user (user_id)
);"

echo "Schema initialization complete."
echo "Tables ensured: categories, tasks, reminders, user_settings"
